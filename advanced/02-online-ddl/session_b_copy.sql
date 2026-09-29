-- Run in session B, right after session A's ALGORITHM=COPY ALTER starts.
USE ddl_lab;
SET SESSION innodb_lock_wait_timeout = 10;

SELECT NOW(6) AS insert_start;
INSERT INTO big_table (val, payload) VALUES (999999, 'concurrent-insert');
SELECT NOW(6) AS insert_done;
-- insert_done lands right around when session A's ALTER finishes (t1 in
-- session_a_copy.sql), not right after insert_start -- this INSERT was
-- queued behind the ALTER's exclusive metadata lock the whole time.

DELETE FROM big_table WHERE val = 999999;
