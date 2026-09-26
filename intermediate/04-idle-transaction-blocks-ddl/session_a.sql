-- Run this in terminal/session A
-- 模拟"忘了提交"：开了事务、读了一下，然后什么也不做，一直挂着
USE mdl_lab;

START TRANSACTION;
SELECT * FROM orders LIMIT 1;
-- 故意不 COMMIT/ROLLBACK，切到 session B、session C 观察现象
-- 看完之后回到这里执行：
-- COMMIT;
