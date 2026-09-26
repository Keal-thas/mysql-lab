-- 大 OFFSET 分页为什么越翻越慢 demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS pagination_lab;
CREATE DATABASE pagination_lab;
USE pagination_lab;

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    created_at DATE NOT NULL
) ENGINE = InnoDB;

SET SESSION cte_max_recursion_depth = 60000;
INSERT INTO orders (customer_id, created_at)
SELECT (n % 500) + 1, DATE_ADD('2024-01-01', INTERVAL (n % 365) DAY)
FROM (
    WITH RECURSIVE seq AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1 FROM seq WHERE n < 50000
    )
    SELECT n FROM seq
) s;

-- 1) 第一页/靠前的页：OFFSET 很小，很快
EXPLAIN ANALYZE SELECT * FROM orders ORDER BY id LIMIT 20 OFFSET 100;

-- 2) 翻到很靠后的页：OFFSET 很大
--    MySQL 仍然要按顺序扫过前面全部 49000 行再丢弃，只是为了跳到第 49000 行
EXPLAIN ANALYZE SELECT * FROM orders ORDER BY id LIMIT 20 OFFSET 49000;

-- 3) 换成"游标"/keyset 分页：记住上一页最后一条的 id，用条件直接定位，
--    不管翻到第几页，性能都和第一页一样
EXPLAIN ANALYZE SELECT * FROM orders WHERE id > 49000 ORDER BY id LIMIT 20;
