-- Run in a second session, after session_a_idle_txn.sql has gone idle.

-- Plain SHOW PROCESSLIST tells you a connection is idle (Command = Sleep),
-- but NOT whether it's holding an open transaction -- most idle connections
-- are perfectly harmless (just a pooled connection with nothing to do).
SHOW PROCESSLIST;

-- To find only the dangerous ones -- idle AND sitting inside an open
-- transaction -- join the process list against Performance Schema's
-- transaction table:
SELECT p.id, p.time AS idle_seconds, p.state, t.STATE AS trx_state
FROM information_schema.processlist p
JOIN performance_schema.threads th ON th.PROCESSLIST_ID = p.id
JOIN performance_schema.events_transactions_current t ON t.THREAD_ID = th.THREAD_ID
WHERE p.command = 'Sleep' AND t.STATE = 'ACTIVE';
-- idle_seconds is how long the connection has been sitting there since its
-- last statement -- this is what you'd alert on (e.g. idle_seconds > 60 AND
-- trx_state = 'ACTIVE') to catch forgotten transactions before they block
-- something else, the way ../../intermediate/04-idle-transaction-blocks-ddl/
-- demonstrates.
