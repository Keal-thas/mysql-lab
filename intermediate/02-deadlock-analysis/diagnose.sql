-- 死锁排查用的诊断查询
-- 配合 README.md 的时间线，在合适的时机分别执行下面两段

-- === 第一段：死锁真正触发之前，session B 正卡在锁等待时执行 ===
-- sys.innodb_lock_waits 是比 SHOW ENGINE INNODB STATUS 更好读的"当前锁等待"视图：
-- 谁在等（waiting_pid/waiting_query），等的锁被谁占着（blocking_pid/blocking_query)
SELECT
    waiting_trx_id, waiting_pid, waiting_query,
    blocking_trx_id, blocking_pid, blocking_query
FROM sys.innodb_lock_waits;

-- === 第二段：死锁触发之后执行 ===
-- LATEST DETECTED DEADLOCK 只保留"最近一次"的死锁详情：两个事务分别持有/等待
-- 哪些锁，以及最后 InnoDB 选择回滚了哪一个（"WE ROLL BACK TRANSACTION"）
SHOW ENGINE INNODB STATUS\G
