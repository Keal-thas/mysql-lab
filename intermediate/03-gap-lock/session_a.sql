-- Run this in terminal/session A
USE gap_lock_lab;

START TRANSACTION;
-- 锁住 val 在 [10, 20] 之间的行，同时锁住这个区间的"间隙"（防止幻读插入）
SELECT * FROM points WHERE val BETWEEN 10 AND 20 FOR UPDATE;
-- 先别提交，切到 session B 尝试往这个区间里插入一行
-- 观察完之后回到这里执行：
-- ROLLBACK;
