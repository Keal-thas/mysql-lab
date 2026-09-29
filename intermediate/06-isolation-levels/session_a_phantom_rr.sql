-- Run in session A, isolation level REPEATABLE READ (the default)
USE iso_lab;

START TRANSACTION;
SELECT COUNT(*) FROM items WHERE val BETWEEN 10 AND 30;
-- Expect 3. Switch to session B, run session_b_phantom.sql fully (inserts a
-- new row inside the range and commits). Come back here and run again:
SELECT COUNT(*) FROM items WHERE val BETWEEN 10 AND 30;
-- Still 3 -- no phantom this time. This is a plain (snapshot) read, so it
-- reuses the transaction's Read View, same as the MVCC demo -- it never
-- needed a range lock to get this guarantee.
COMMIT;
SELECT COUNT(*) FROM items WHERE val BETWEEN 10 AND 30;
-- Now 4 -- a fresh transaction sees the committed insert.
