-- Scenario 3: open-ended range (val > 20). Run in session A.
USE nk_lab;

START TRANSACTION;
SELECT * FROM points WHERE val > 20 FOR UPDATE;
-- Locks the next-key lock on val=30 (covers gap (20, 30] plus the record)
-- and the gap above the last row, (30, +infinity) -- the "supremum" pseudo
-- record InnoDB uses to represent "past the end of the index".
-- Switch to session B and run session_b_range.sql. Come back here when done:
-- ROLLBACK;
