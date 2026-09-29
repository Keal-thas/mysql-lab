-- ALGORITHM=INPLACE, LOCK=NONE: adding a secondary index rebuilds the index
-- structure but does not lock the table against reads or writes. Run this in
-- session A, then immediately switch to session B and run session_b.sql
-- before this finishes (it takes under a second on 2,000,000 rows, so be
-- quick, or just run both roughly at the same time in two terminals).
USE ddl_lab;

SELECT NOW(6) AS t0;
ALTER TABLE big_table ADD INDEX idx_val (val), ALGORITHM=INPLACE, LOCK=NONE;
SELECT NOW(6) AS t1;
