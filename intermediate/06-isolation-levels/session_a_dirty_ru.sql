-- Run in session A, isolation level READ UNCOMMITTED
USE iso_lab;
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;
SELECT balance FROM accounts WHERE id = 1;
-- Expect 100.00. Now switch to session B and run the first two lines of
-- session_b_dirty.sql (UPDATE, no COMMIT yet). Come back here and run:
SELECT balance FROM accounts WHERE id = 1;
-- 999.00 -- a dirty read: B's change was never committed, we still see it.
-- Now go back to session B and run ROLLBACK. Then run this again:
SELECT balance FROM accounts WHERE id = 1;
-- Back to 100.00 -- the value we "read" a moment ago never actually existed.
COMMIT;
