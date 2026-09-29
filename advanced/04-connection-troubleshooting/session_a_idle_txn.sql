-- Run in session A. This opens a transaction and then goes idle -- exactly
-- the "left a transaction open and walked away" scenario that shows up as
-- mysterious blocking elsewhere in the app (see
-- ../../intermediate/04-idle-transaction-blocks-ddl/ for the blocking side).
USE mysql;

START TRANSACTION;
SELECT 1;
-- Don't COMMIT or ROLLBACK yet -- switch to another session and run
-- check_idle_txn.sql to find this connection. When you're done inspecting:
-- COMMIT;
