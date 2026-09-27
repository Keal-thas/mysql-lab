-- ALGORITHM=COPY, LOCK=EXCLUSIVE: forces the old-style rebuild -- MySQL
-- builds a whole new copy of the table and holds an exclusive metadata lock
-- against it for (most of) the duration. Run this in session A, then
-- immediately switch to session B and run session_b.sql while this is still
-- running (it takes a few seconds on 2,000,000 rows -- you have time).
USE ddl_lab;

SELECT NOW(6) AS t0;
ALTER TABLE big_table ADD COLUMN note2 VARCHAR(50) NULL, ALGORITHM=COPY, LOCK=EXCLUSIVE;
SELECT NOW(6) AS t1;
