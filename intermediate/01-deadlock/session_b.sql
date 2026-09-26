-- Run this in terminal/session B, after session_a's first UPDATE has executed
USE deadlock_lab;

START TRANSACTION;
UPDATE accounts SET balance = balance - 50 WHERE id = 2;
-- This will block waiting for session A's lock on id=2.
UPDATE accounts SET balance = balance + 50 WHERE id = 1;
-- Once session A runs its second UPDATE, MySQL detects the deadlock
-- and one of the two transactions is rolled back automatically.
