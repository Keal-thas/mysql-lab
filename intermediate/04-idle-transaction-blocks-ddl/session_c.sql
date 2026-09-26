-- Run this in terminal/session C, right after session B starts running (while it's blocked)
USE mdl_lab;

SET SESSION lock_wait_timeout = 5;

-- 这只是一条普通的 SELECT，跟 session A/B 都没有数据上的交集，
-- 但因为它排在 session B 那条排队中的 ALTER TABLE 后面，
-- 同样会被卡住——这是这个 demo 最反直觉的地方
SELECT * FROM orders LIMIT 1;
