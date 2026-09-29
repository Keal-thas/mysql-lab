-- Run in session A, isolation level READ COMMITTED
USE iso_lab;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
SELECT COUNT(*) FROM items WHERE val BETWEEN 10 AND 30;
-- Expect 3. Switch to session B, run session_b_phantom.sql fully (inserts a
-- new row inside the range and commits). Come back here and run again:
SELECT COUNT(*) FROM items WHERE val BETWEEN 10 AND 30;
-- Now 4 -- a phantom row appeared inside the same transaction, same query.
COMMIT;
