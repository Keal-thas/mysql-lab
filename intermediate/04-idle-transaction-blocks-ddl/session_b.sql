-- Run this in terminal/session B, while session A's transaction is still open
USE mdl_lab;

SET SESSION lock_wait_timeout = 5;

-- 这条 DDL 需要拿到 orders 表的排他元数据锁（MDL），
-- 但 session A 那个"忘了提交"的事务还占着共享 MDL，会一直卡到超时报错
ALTER TABLE orders ADD COLUMN note VARCHAR(20);
