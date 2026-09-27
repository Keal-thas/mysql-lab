-- Scenario 2: equality on a value that does NOT exist (val=15). Run in
-- session A.
USE nk_lab;

START TRANSACTION;
SELECT * FROM points WHERE val = 15 FOR UPDATE;
-- No row matches, so this only locks the single gap the value would have
-- landed in: (10, 20). Nothing to the left of 10, nothing to the right of 20.
-- Switch to session B and run session_b_miss.sql. Come back here when done:
-- ROLLBACK;
