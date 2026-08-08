-- Run this in terminal/session A
USE deadlock_lab;

START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
-- Pause here, then run session_b.sql fully (it will block).
-- After session B is blocked, run the next line in this session to trigger the deadlock:
-- UPDATE accounts SET balance = balance + 100 WHERE id = 2;
