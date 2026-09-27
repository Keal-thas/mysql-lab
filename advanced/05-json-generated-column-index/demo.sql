-- JSON 类型的索引方式（生成列 + 索引）demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS json_lab;
CREATE DATABASE json_lab;
USE json_lab;

CREATE TABLE seed_nums (n INT PRIMARY KEY);
SET SESSION cte_max_recursion_depth = 2000;
INSERT INTO seed_nums
WITH RECURSIVE seq AS (SELECT 0 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 1999)
SELECT n FROM seq;

-- 200 万行，attrs 是一个 JSON 对象，brand 有 5 种取值
CREATE TABLE products_no_index (
    id INT PRIMARY KEY AUTO_INCREMENT,
    attrs JSON NOT NULL
);
INSERT INTO products_no_index (attrs)
SELECT JSON_OBJECT(
    'brand', ELT((a.n * 2000 + b.n) % 5 + 1, 'acme', 'globex', 'initech', 'umbrella', 'hooli'),
    'price', (a.n * 2000 + b.n) % 1000
)
FROM seed_nums a JOIN seed_nums b ON b.n < 1000;

-- 同样的数据，但多一个"虚拟"生成列 brand，从 JSON 里算出来，加了索引
CREATE TABLE products_indexed LIKE products_no_index;
ALTER TABLE products_indexed
    ADD COLUMN brand VARCHAR(50) GENERATED ALWAYS AS (attrs ->> '$.brand') STORED,
    ADD INDEX idx_brand (brand);
INSERT INTO products_indexed (attrs) SELECT attrs FROM products_no_index;

DROP TABLE seed_nums;

-- 1) 没有索引的表，按 JSON 字段过滤：只能整表扫描，每一行都要现算一次
--    JSON_EXTRACT
EXPLAIN ANALYZE SELECT COUNT(*) FROM products_no_index WHERE attrs ->> '$.brand' = 'acme';

-- 2) 有生成列索引的表，但 WHERE 里写的还是原始 JSON 表达式（不是生成列名）：
--    优化器能识别出这个表达式和生成列的定义一致，自动换成走 idx_brand，
--    不需要改查询语句——这是 MySQL 8.0.13+ 的"表达式索引识别"能力
EXPLAIN ANALYZE SELECT COUNT(*) FROM products_indexed WHERE attrs ->> '$.brand' = 'acme';

-- 3) 直接按生成列名过滤：同一个索引，但这次是覆盖索引扫描（Covering index
--    lookup），比 (2) 更快——(2) 虽然也用上了索引，但优化器保守地把它当成
--    "索引里查到候选行，还需要回表验证 JSON 表达式"，只有显式用生成列名，
--    才会被当作纯粹的索引列比较
EXPLAIN ANALYZE SELECT COUNT(*) FROM products_indexed WHERE brand = 'acme';
