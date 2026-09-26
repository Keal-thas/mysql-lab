-- EXPLAIN 基础 demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS explain_lab;
CREATE DATABASE explain_lab;
USE explain_lab;

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    status VARCHAR(10) NOT NULL,
    created_at DATE NOT NULL
) ENGINE = InnoDB;

-- 造 5 万行测试数据，让扫描行数的差异有意义
SET SESSION cte_max_recursion_depth = 60000;
INSERT INTO orders (customer_id, status, created_at)
SELECT (n % 500) + 1,
       ELT((n % 3) + 1, 'paid', 'pending', 'cancelled'),
       DATE_ADD('2024-01-01', INTERVAL (n % 365) DAY)
FROM (
    WITH RECURSIVE seq AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1 FROM seq WHERE n < 50000
    )
    SELECT n FROM seq
) s;

CREATE INDEX idx_customer_id ON orders (customer_id);

-- 1) 走索引精确查找：type=ref，rows 估算很小
--    type 从好到差大致是：system/const > eq_ref > ref > range > index > ALL
EXPLAIN SELECT * FROM orders WHERE customer_id = 10;

-- 2) 没有索引的列：type=ALL，全表扫描，rows 估算就是全表行数
EXPLAIN SELECT * FROM orders WHERE status = 'paid';

-- 3) 覆盖索引（covering index）：只查 id，二级索引 idx_customer_id 内部本来就
--    带着主键，不用回表查聚簇索引，Extra 里会出现 "Using index"
EXPLAIN SELECT id FROM orders WHERE customer_id = 10;

-- 4) EXPLAIN 只是优化器的"估算"，EXPLAIN ANALYZE 会真的执行一遍，
--    给出真实耗时(actual time)和真实行数(rows)，两者都要看
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 10;
EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'paid';
