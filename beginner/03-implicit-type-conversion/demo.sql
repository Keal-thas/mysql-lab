-- 隐式类型转换导致索引失效 demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS type_conversion_lab;
CREATE DATABASE type_conversion_lab;
USE type_conversion_lab;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    phone VARCHAR(20) NOT NULL
) ENGINE = InnoDB;

SET SESSION cte_max_recursion_depth = 60000;
INSERT INTO users (phone)
SELECT CONCAT('138', LPAD(n, 8, '0'))
FROM (
    WITH RECURSIVE seq AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1 FROM seq WHERE n < 50000
    )
    SELECT n FROM seq
) s;

CREATE INDEX idx_phone ON users (phone);

-- 挑一个真实存在的号码，方便两条查询对比同一行（id=12345 -> phone='13800012345'）
SELECT phone FROM users WHERE id = 12345;

-- 1) 字符串字面量：类型和列一致，走索引直接定位
EXPLAIN ANALYZE SELECT * FROM users WHERE phone = '13800012345';

-- 2) 数字字面量：MySQL 需要把 phone 转成数字才能比较，
--    等价于 CAST(phone AS DOUBLE) = 13800012345，索引列被函数包了一层，
--    没法再用索引做等值查找，只能把整个索引/表扫一遍逐行转换比较
EXPLAIN ANALYZE SELECT * FROM users WHERE phone = 13800012345;
