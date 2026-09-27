-- Run this in terminal/session A, isolation level REPEATABLE READ (the default)
USE mvcc_lab;

START TRANSACTION;
SELECT balance FROM accounts WHERE id = 1;
-- Expect 1000.00. Now switch to session B and run session_b.sql fully
-- (it updates balance to 500 and commits).
-- Come back here and run the SELECT again:
SELECT balance FROM accounts WHERE id = 1;
-- Still 1000.00 -- this transaction's Read View was created at START TRANSACTION
-- (really: at the first SELECT) and is reused for every SELECT until COMMIT,
-- so B's committed change is invisible here.
COMMIT;
SELECT balance FROM accounts WHERE id = 1;
-- Now 500.00 -- a new transaction gets a fresh Read View.
