-- Run in session B, after session A's first SELECT.
-- Run only these first two lines, then go back to session A -- do NOT let
-- the client auto-run past START TRANSACTION/UPDATE; execute statement by
-- statement.
USE iso_lab;
START TRANSACTION;
UPDATE accounts SET balance = 999.00 WHERE id = 1;
-- Pause here. After session A has done its dirty (or non-dirty) read,
-- come back and run:
ROLLBACK;
