-- Run in session B, after session A's SELECT ... FOR UPDATE (val > 20 case).
USE nk_lab;
SET SESSION innodb_lock_wait_timeout = 5;

INSERT INTO points VALUES (92, 15);
-- Succeeds immediately -- 15 is in the gap (10, 20), below the range,
-- never touched.

INSERT INTO points VALUES (93, 25);
-- Blocks -- 25 is inside the locked gap (20, 30).

INSERT INTO points VALUES (94, 35);
-- Blocks -- 35 falls in the (30, +infinity) supremum gap, also locked
-- because the range is open-ended.
