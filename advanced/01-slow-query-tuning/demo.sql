-- 慢查询定位与调优思路 demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS tuning_lab;
CREATE DATABASE tuning_lab;
USE tuning_lab;

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    status VARCHAR(10) NOT NULL,
    created_at DATE NOT NULL,
    -- 占位列：模拟真实表里"业务需要但排序/过滤用不上"的字段，
    -- 让 SELECT * 无法只靠下面的二级索引覆盖，必须回表——这是第 7 步
    -- 选择性差时优化器放弃索引的关键前提，真实业务表基本都是这样
    note VARCHAR(100) NOT NULL DEFAULT ''
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

-- 1) 打开慢查询日志。生产上一般写文件（log_output=FILE），这里为了能直接用 SQL
--    查结果，写到 mysql.slow_log 表里。long_query_time 调到 0 只是为了让这个
--    demo 里本来就很快的查询也能被记下来，生产环境不要这么设。
SET GLOBAL slow_query_log = 1;
SET GLOBAL log_output = 'TABLE';
SET GLOBAL long_query_time = 0;

-- 2) 跑一条没有合适索引、条件命中很少数据的查询
SELECT * FROM orders WHERE status = 'paid' AND created_at = '2024-06-02';

-- 3) 去慢查询日志里找到刚才这条，重点看 rows_examined 和 rows_sent 的差距：
--    扫了很多行，最后只返回了一点点，说明多半是在做无谓的全表扫描
SELECT query_time, rows_examined, rows_sent, sql_text
FROM mysql.slow_log
WHERE sql_text LIKE 'SELECT * FROM orders%'
ORDER BY start_time DESC LIMIT 1\G

-- 4) EXPLAIN ANALYZE 确认：全表扫描
EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'paid' AND created_at = '2024-06-02';

-- 5) 针对性加索引
CREATE INDEX idx_status_created ON orders (status, created_at);

-- 6) 再跑一次，验证效果：应该变成走索引的精确查找
EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'paid' AND created_at = '2024-06-02';

-- 7) 对照组：条件命中了表里相当一部分数据（选择性差）时，
--    即使有索引，优化器也可能主动放弃它——因为走这个二级索引意味着命中的每一行
--    都要回表查一次聚簇索引，行数一多，反而比直接顺序扫全表更慢
EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'paid' AND created_at > '2024-06-01';

-- 用 FORCE INDEX 强制走索引对比一下，验证优化器不是"偷懒"，是真的算过更优
EXPLAIN ANALYZE SELECT * FROM orders FORCE INDEX (idx_status_created)
    WHERE status = 'paid' AND created_at > '2024-06-01';

-- 8) 收尾：关掉慢查询日志，避免影响这个容器里的其他 demo
SET GLOBAL slow_query_log = 0;
SET GLOBAL log_output = 'FILE';
