-- 覆盖索引 / index-only scan demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS covering_index_lab;
CREATE DATABASE covering_index_lab;
USE covering_index_lab;

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    status VARCHAR(10) NOT NULL,
    amount DECIMAL(10,2) NOT NULL
) ENGINE = InnoDB;

SET SESSION cte_max_recursion_depth = 60000;
INSERT INTO orders (customer_id, status, amount)
SELECT (n % 500) + 1,
       ELT((n % 3) + 1, 'paid', 'pending', 'cancelled'),
       (n % 1000) + 0.5
FROM (
    WITH RECURSIVE seq AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1 FROM seq WHERE n < 50000
    )
    SELECT n FROM seq
) s;

-- 联合索引 (customer_id, status)
CREATE INDEX idx_customer_status ON orders (customer_id, status);

-- 1) 只查索引里就有的列（customer_id, status）：Extra 里出现 "Using index"，
--    整条查询不用回表读聚簇索引，直接在这个二级索引上就能拿到全部结果
EXPLAIN SELECT customer_id, status FROM orders WHERE customer_id = 10;

-- 2) 多查一个不在索引里的列（amount）：一模一样的 WHERE 条件，但 Extra 里
--    "Using index" 消失了——因为等值查找已经精确定位到行，不需要再用索引过滤，
--    只是需要顺着主键回到聚簇索引把 amount 取出来
EXPLAIN SELECT customer_id, status, amount FROM orders WHERE customer_id = 10;

-- 3) SELECT *，并且第二列 status 用的是范围条件（LIKE 'p%'）：Extra 变成
--    "Using index condition"——这是索引条件下推（ICP）：先在索引里用 status
--    这个条件筛一遍，只对通过筛选的少数行才去回表，减少不必要的回表次数，
--    但因为最终要取 amount 等不在索引里的列，还是得回表，所以不是 "Using index"
EXPLAIN SELECT * FROM orders WHERE customer_id = 10 AND status LIKE 'p%';

-- 4) 同样的范围条件，但只查索引里有的列：Extra 变成
--    "Using where; Using index"——range 条件在索引内部就筛完了，
--    而且完全不用回表，是覆盖索引 + 范围过滤的组合
EXPLAIN SELECT customer_id, status FROM orders WHERE customer_id = 10 AND status LIKE 'p%';
