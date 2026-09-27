-- ALGORITHM=INSTANT: adding a column doesn't touch existing rows at all,
-- MySQL just records the new column in the table's metadata. No session B
-- needed for this one -- the point is how fast it returns regardless of
-- table size.
USE ddl_lab;

SELECT NOW(6) AS t0;
ALTER TABLE big_table ADD COLUMN note VARCHAR(50) NULL, ALGORITHM=INSTANT;
SELECT NOW(6) AS t1;
-- t1 - t0 is a few milliseconds, even though the table has 2,000,000 rows.
