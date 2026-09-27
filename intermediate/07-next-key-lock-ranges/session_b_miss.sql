-- Run in session B, after session A's SELECT ... FOR UPDATE (val = 15 case).
USE nk_lab;
SET SESSION innodb_lock_wait_timeout = 5;

INSERT INTO points VALUES (92, 12);
-- Blocks -- 12 is inside the locked gap (10, 20).

INSERT INTO points VALUES (93, 25);
-- Succeeds immediately -- 25 is in the gap (20, 30), which was never
-- touched. A miss only ever locks the one gap the searched value falls in.
