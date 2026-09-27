-- Run in session B, right after (or even overlapping with) session A's
-- ALGORITHM=INPLACE ALTER.
USE ddl_lab;

SELECT NOW(6) AS insert_start;
INSERT INTO big_table (val, payload) VALUES (999999, 'concurrent-insert');
SELECT NOW(6) AS insert_done;
-- insert_done should be milliseconds after insert_start, even while
-- session A's ALTER is still running in the background -- LOCK=NONE means
-- no metadata lock is held against DML for the bulk of the operation.

DELETE FROM big_table WHERE val = 999999;
