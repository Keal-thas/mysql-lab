-- ORDER BY 平局(tie)顺序 demo
-- 建议配合 README.md 逐段执行，对照每一步的 EXPLAIN 和结果

DROP DATABASE IF EXISTS order_by_lab;
CREATE DATABASE order_by_lab;
USE order_by_lab;

CREATE TABLE t (
    id INT PRIMARY KEY,
    k  INT,
    label VARCHAR(20)
) ENGINE = InnoDB;

INSERT INTO t (id, k, label) VALUES
    (1, 10, 'a'),
    (2, 10, 'b'),
    (3, 10, 'c'),
    (4, 20, 'd'),
    (5, 20, 'e');

-- 1) k 上还没有索引：走全表扫描 + filesort
--    观察 Extra: Using filesort，以及 k=20 的两行 (d, e) 谁先谁后
EXPLAIN SELECT * FROM t ORDER BY k DESC;
SELECT * FROM t ORDER BY k DESC;

-- 2) 给 k 建索引
ALTER TABLE t ADD INDEX idx_k (k);

-- 3) 强制走索引的倒序扫描，不再需要 filesort
--    观察 Extra: Backward index scan
--    二级索引里，重复的 k 内部按主键升序排列；倒序扫描 => 平局按主键降序：e, d
EXPLAIN SELECT * FROM t FORCE INDEX (idx_k) ORDER BY k DESC;
SELECT * FROM t FORCE INDEX (idx_k) ORDER BY k DESC;

-- 4) 即使已经有索引，也强制忽略它，回到 filesort
--    对比第 3 步：同一张表、同一条逻辑查询，k=20 的平局顺序变回了 d, e
EXPLAIN SELECT * FROM t IGNORE INDEX (idx_k) ORDER BY k DESC;
SELECT * FROM t IGNORE INDEX (idx_k) ORDER BY k DESC;

-- 5) 正确写法：加主键做 tiebreaker，任何执行计划下结果顺序都确定
SELECT * FROM t ORDER BY k DESC, id;
