-- COUNT(*) 优化 demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS count_lab;
CREATE DATABASE count_lab;
USE count_lab;

CREATE TABLE seed_nums (n INT PRIMARY KEY);
SET SESSION cte_max_recursion_depth = 2000;
INSERT INTO seed_nums
WITH RECURSIVE seq AS (SELECT 0 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 1999)
SELECT n FROM seq;

-- 200 万行，status 没建索引，10% 是 'c'
CREATE TABLE events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    status VARCHAR(10) NOT NULL,
    payload VARCHAR(100) NOT NULL
) ENGINE = InnoDB;

INSERT INTO events (status, payload)
SELECT ELT((a.n * 2000 + b.n) % 10 + 1, 'a','a','a','a','a','a','a','a','b','c'),
       CONCAT('row-', a.n, '-', b.n)
FROM seed_nums a JOIN seed_nums b ON b.n < 1000;

DROP TABLE seed_nums;

-- 1) 不带 WHERE 的 COUNT(*)：InnoDB 没有 MyISAM 那种维护好的总行数，
--    但优化器会挑最小的索引整个扫一遍，比扫整张表（含所有列）快不少
EXPLAIN ANALYZE SELECT COUNT(*) FROM events;

-- 2) 带 WHERE 条件、且这个列没有索引：只能全表扫描 + 逐行判断，
--    实测耗时是 (1) 的十几倍
EXPLAIN ANALYZE SELECT COUNT(*) FROM events WHERE status = 'c';

-- 3) 近似值：让优化器根据统计信息猜一个数，不用真的扫表，几乎零成本，
--    代价是不准确（这里预计误差在 1% 以内，数据分布越不均匀统计信息越容易过期）
ANALYZE TABLE events;
SELECT TABLE_ROWS AS approx_count
FROM information_schema.tables
WHERE table_schema = 'count_lab' AND table_name = 'events';
SELECT COUNT(*) AS exact_count FROM events;

-- 4) 维护计数表：用触发器在 INSERT/DELETE 时增减一个计数器，
--    读的时候直接查这一行，天生 O(1)，代价是每次写入多了一次 UPDATE
CREATE TABLE counters (
    name VARCHAR(20) PRIMARY KEY,
    cnt BIGINT NOT NULL
);
INSERT INTO counters VALUES ('events_total', (SELECT COUNT(*) FROM events));

DELIMITER //
CREATE TRIGGER trg_events_ai AFTER INSERT ON events FOR EACH ROW
BEGIN
    UPDATE counters SET cnt = cnt + 1 WHERE name = 'events_total';
END//
CREATE TRIGGER trg_events_ad AFTER DELETE ON events FOR EACH ROW
BEGIN
    UPDATE counters SET cnt = cnt - 1 WHERE name = 'events_total';
END//
DELIMITER ;

INSERT INTO events (status, payload) VALUES ('a', 'x'), ('b', 'y'), ('c', 'z');
DELETE FROM events WHERE id = 1;

-- 两边应该始终相等，但左边是瞬间返回，右边是全表扫描
SELECT cnt FROM counters WHERE name = 'events_total';
SELECT COUNT(*) FROM events;
