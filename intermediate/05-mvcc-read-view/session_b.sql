-- Run this in terminal/session B, after session A's first SELECT has executed
USE mvcc_lab;

START TRANSACTION;
UPDATE accounts SET balance = 500.00 WHERE id = 1;
COMMIT;
