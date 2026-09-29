-- Run in session A, isolation level READ COMMITTED (for comparison)
USE iso_lab;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
SELECT balance FROM accounts WHERE id = 1;
-- Expect 100.00. Switch to session B and run the first two lines of
-- session_b_dirty.sql (UPDATE, no COMMIT yet). Come back here and run:
SELECT balance FROM accounts WHERE id = 1;
-- Still 100.00 -- READ COMMITTED never shows another transaction's
-- uncommitted changes, no dirty read.
-- Go back to session B and run ROLLBACK (nothing to clean up either way).
COMMIT;
