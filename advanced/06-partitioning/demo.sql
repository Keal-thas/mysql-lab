-- 分区表：适用场景与注意事项 demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS partition_lab;
CREATE DATABASE partition_lab;
USE partition_lab;

-- 按年份 RANGE 分区，典型的"日志表按时间分区，定期删旧数据"场景。
-- 主键必须包含分区键（created_at）——这是 MySQL 分区表的硬性要求：
-- 每个唯一索引都必须包含分区表达式里用到的所有列。
CREATE TABLE logs (
    id INT NOT NULL AUTO_INCREMENT,
    created_at DATE NOT NULL,
    msg VARCHAR(100) NOT NULL,
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION pmax VALUES LESS THAN MAXVALUE
);

CREATE TABLE seed_nums (n INT PRIMARY KEY);
SET SESSION cte_max_recursion_depth = 2000;
INSERT INTO seed_nums
WITH RECURSIVE seq AS (SELECT 0 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 1999)
SELECT n FROM seq;

-- 200 万行，均匀分布在 2023-01-01 ~ 2026-12-30 之间（四个分区各 50 万行左右）
INSERT INTO logs (created_at, msg)
SELECT DATE_ADD('2023-01-01', INTERVAL ((a.n * 2000 + b.n) % 1460) DAY),
       CONCAT('log-', a.n, '-', b.n)
FROM seed_nums a JOIN seed_nums b ON b.n < 1000;

DROP TABLE seed_nums;

SELECT PARTITION_NAME, TABLE_ROWS
FROM information_schema.partitions
WHERE table_schema = 'partition_lab' AND table_name = 'logs';

-- 1) 分区裁剪（partition pruning）：条件直接写在分区键的列上，
--    EXPLAIN 的 partitions 列只会列出真正需要扫的分区
EXPLAIN SELECT COUNT(*) FROM logs WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31';

-- 2) 分区裁剪失效：把分区键包在一个函数里（哪怕这个函数和建分区时用的
--    YEAR() 一模一样），优化器就没法再推断出只需要哪个分区了，
--    partitions 列会列出全部四个分区——这跟"隐式类型转换让索引失效"是
--    同一类坑：包裹列的表达式让优化器没法做本来能做的裁剪
EXPLAIN SELECT COUNT(*) FROM logs WHERE YEAR(created_at) = 2024;

-- 3) 整分区删除 vs 普通 DELETE：DROP PARTITION 直接丢弃整个分区对应的
--    物理文件，跟这个分区有多少行没关系，是毫秒级操作
SELECT NOW(6) AS drop_partition_t0;
ALTER TABLE logs DROP PARTITION p2023;
SELECT NOW(6) AS drop_partition_t1;

-- 4) 删同样量级的一批数据，但用普通 DELETE（对比组，删 p2024 那部分数据）：
--    要逐行找到、加锁、删除、写 undo log，耗时是 (3) 的几十倍
SELECT NOW(6) AS delete_t0;
DELETE FROM logs WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31';
SELECT NOW(6) AS delete_t1;
