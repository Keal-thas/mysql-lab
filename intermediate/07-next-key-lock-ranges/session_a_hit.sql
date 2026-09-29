-- Scenario 1: equality on a value that EXISTS (val=20). Run in session A.
USE nk_lab;

START TRANSACTION;
SELECT * FROM points WHERE val = 20 FOR UPDATE;
-- Locks the record val=20 AND both neighboring gaps: (10, 20) and (20, 30).
-- The gap on the right is needed too, otherwise another session could insert
-- a second row with val=20 right after this one -- a phantom for this exact
-- equality condition.
-- Switch to session B and run session_b_hit.sql. Come back here when done:
-- ROLLBACK;
