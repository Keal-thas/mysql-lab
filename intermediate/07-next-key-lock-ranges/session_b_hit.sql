-- Run in session B, after session A's SELECT ... FOR UPDATE (val = 20 case).
-- Run these one at a time, observing each result before running the next.
USE nk_lab;
SET SESSION innodb_lock_wait_timeout = 5;

INSERT INTO points VALUES (91, 9);
-- Succeeds immediately -- 9 is in the gap before 10, outside the locked range.

INSERT INTO points VALUES (92, 15);
-- Blocks -- 15 is in the gap (10, 20), which is locked.
-- Ctrl+C or wait for the 1205 timeout, then continue.

INSERT INTO points VALUES (93, 25);
-- Blocks -- 25 is in the gap (20, 30), also locked (the "extra" gap that
-- makes this an equality-aware next-key lock, not just a plain range lock).

INSERT INTO points VALUES (94, 35);
-- Succeeds immediately -- 35 is beyond 30, outside the locked range.
