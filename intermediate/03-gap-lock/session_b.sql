-- Run this in terminal/session B, after session A's SELECT ... FOR UPDATE
USE gap_lock_lab;

SET SESSION innodb_lock_wait_timeout = 5;

-- val=15 落在 session A 锁住的 (10, 20) 间隙里，即使这一行原来不存在、
-- 也没有和 session A 更新同一行数据，这条 INSERT 依然会被阻塞，
-- 直到超时报错 1205，或者 session A 提交/回滚
INSERT INTO points VALUES (4, 15);
