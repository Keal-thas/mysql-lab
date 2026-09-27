-- Run this in terminal/session A, isolation level READ COMMITTED
USE mvcc_lab;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
SELECT balance FROM accounts WHERE id = 1;
-- Expect 500.00 if you ran the RR demo first (reset with setup.sql to get 1000.00).
-- Now switch to session B and run session_b.sql fully (it flips the balance
-- and commits). Come back here and run the SELECT again, still inside this
-- same uncommitted transaction:
SELECT balance FROM accounts WHERE id = 1;
-- Changed already, even though this transaction never committed -- READ
-- COMMITTED builds a brand new Read View for every single SELECT statement,
-- not once per transaction like REPEATABLE READ does.
COMMIT;
