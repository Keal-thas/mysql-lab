CREATE DATABASE IF NOT EXISTS ddl_lab;
USE ddl_lab;

DROP TABLE IF EXISTS seed_nums;
CREATE TABLE seed_nums (n INT PRIMARY KEY);
SET SESSION cte_max_recursion_depth = 2000;
INSERT INTO seed_nums
WITH RECURSIVE seq AS (SELECT 0 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 1999)
SELECT n FROM seq;

-- 200 万行，让 ALGORITHM=COPY 的重建耗时肉眼可见（几秒级），
-- 用两个 1000 值的数字表做笛卡尔积快速生成，比逐行 INSERT 快得多
DROP TABLE IF EXISTS big_table;
CREATE TABLE big_table (
    id INT PRIMARY KEY AUTO_INCREMENT,
    val INT NOT NULL,
    payload VARCHAR(100) NOT NULL
) ENGINE = InnoDB;

INSERT INTO big_table (val, payload)
SELECT a.n * 2000 + b.n, CONCAT('row-', a.n, '-', b.n)
FROM seed_nums a JOIN seed_nums b ON b.n < 1000;

DROP TABLE seed_nums;
