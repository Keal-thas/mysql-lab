-- 联合索引最左前缀原则 demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS leftmost_prefix_lab;
CREATE DATABASE leftmost_prefix_lab;
USE leftmost_prefix_lab;

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    status VARCHAR(10) NOT NULL,
    created_at DATE NOT NULL
) ENGINE = InnoDB;

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

-- 联合索引 (customer_id, status)：只对"从第一列开始连续"的查询条件有效
CREATE INDEX idx_customer_status ON orders (customer_id, status);

-- 1) 只用第一列 customer_id：能用索引，key_len 只包含 customer_id 那部分
EXPLAIN SELECT * FROM orders WHERE customer_id = 10;

-- 2) 第一列 + 第二列都用上：还是走同一个索引，但 key_len 更长，
--    说明 MySQL 用索引定位得更精确（rows 估算更小）
EXPLAIN SELECT * FROM orders WHERE customer_id = 10 AND status = 'paid';

-- 3) 只用第二列 status，跳过了第一列：这个索引整个用不上，
--    退化成全表扫描——(customer_id, status) 这个组合索引，
--    在物理上是先按 customer_id 排序、customer_id 相同时再按 status 排序，
--    脱离了 customer_id，status 在索引里并不是有序/可定位的
EXPLAIN SELECT * FROM orders WHERE status = 'paid';
