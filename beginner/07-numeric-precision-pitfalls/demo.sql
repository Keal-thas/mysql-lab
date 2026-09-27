-- 长数字/长字符串"看起来不一样、比出来却一样"的四种原因 demo
-- 建议配合 README.md 逐段执行

DROP DATABASE IF EXISTS numeric_precision_lab;
CREATE DATABASE numeric_precision_lab;
USE numeric_precision_lab;

-- =====================================================================
-- 1) FLOAT/DOUBLE 精度丢失：超过有效数字位数的长整数，存进去会被四舍五入，
--    两个不同的数可能被舍成同一个值
-- =====================================================================
CREATE TABLE t_float (id INT PRIMARY KEY AUTO_INCREMENT, col_float FLOAT, col_double DOUBLE);

-- FLOAT 大约 7 位有效数字：17 位的数字早就超了
INSERT INTO t_float (col_float) VALUES (12345678901234562), (12345678901234563);
SELECT id, col_float FROM t_float;
SELECT (SELECT col_float FROM t_float WHERE id=1) = (SELECT col_float FROM t_float WHERE id=2) AS float_eq;

-- DOUBLE 大约 15~17 位有效数字：18 位的数字压过临界点
INSERT INTO t_float (col_double) VALUES (123456789012345678), (123456789012345679);
SELECT id, col_double FROM t_float WHERE id IN (3, 4);
SELECT (SELECT col_double FROM t_float WHERE id=3) = (SELECT col_double FROM t_float WHERE id=4) AS double_eq;

-- 直接查询也能看出问题：查一个具体值，本该只中一行，结果两行都出来了
SELECT id FROM t_float WHERE col_double = 123456789012345678;

-- =====================================================================
-- 2) INT 溢出截断：列的整数范围不够，超出范围的值会被"夹"到边界值。
--    这个仓库默认开着 STRICT_TRANS_TABLES，普通 INSERT 遇到这种情况会直接
--    报错拦下来；这里用 INSERT IGNORE 把错误降级成警告，模拟没开严格模式
--    时会发生的情况（MySQL 5.6 及更早版本默认就是非严格模式）
-- =====================================================================
CREATE TABLE t_int (id INT PRIMARY KEY AUTO_INCREMENT, col INT);
INSERT IGNORE INTO t_int (col) VALUES (12345678901234), (12345678901235);
SELECT id, col FROM t_int;
SELECT (SELECT col FROM t_int WHERE id=1) = (SELECT col FROM t_int WHERE id=2) AS int_eq;

-- =====================================================================
-- 3) VARCHAR 截断：列的长度不够，超出长度的部分直接被砍掉。同样需要
--    非严格模式或 INSERT IGNORE 才会发生
-- =====================================================================
CREATE TABLE t_varchar_short (id INT PRIMARY KEY AUTO_INCREMENT, col VARCHAR(10));
INSERT IGNORE INTO t_varchar_short (col) VALUES ('12345678901234562'), ('12345678901234563');
SELECT id, col FROM t_varchar_short;
SELECT id FROM t_varchar_short WHERE col = '1234567890';

-- =====================================================================
-- 4) VARCHAR 本身存对了、没截断，但查询时数字没加引号，触发隐式类型转换：
--    MySQL 把整列的值都转成 DOUBLE 再比较，(1) 里的精度丢失问题在这里
--    重新出现——即使列里存的是精确的字符串
-- =====================================================================
CREATE TABLE t_varchar_ok (id INT PRIMARY KEY AUTO_INCREMENT, col VARCHAR(20));
INSERT INTO t_varchar_ok (col) VALUES ('123456789012345678'), ('123456789012345679');
SELECT id, col FROM t_varchar_ok;

-- 带引号：字符串对字符串，逐字符精确比较，只应该中一行
SELECT id FROM t_varchar_ok WHERE col = '123456789012345678';

-- 不带引号：列被转成 DOUBLE 比较，精度丢失，两行都中
SELECT id FROM t_varchar_ok WHERE col = 123456789012345678;
