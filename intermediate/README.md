# Intermediate

| # | 主题 | 你会学到什么 |
|---|------|--------------|
| 01 | [死锁](01-deadlock/) | 两个事务如何在行锁上互相等待形成死锁 |
| 02 | [死锁发生后怎么排查](02-deadlock-analysis/) | 用 sys.innodb_lock_waits 和 SHOW ENGINE INNODB STATUS 分析死锁 |
| 03 | [间隙锁导致意外阻塞](03-gap-lock/) | REPEATABLE READ 下范围锁定读为什么会锁住"还不存在的数据" |
| 04 | [忘了提交的事务堵住一整张表](04-idle-transaction-blocks-ddl/) | 空闲事务持有的元数据锁，如何连带卡住无关的 DDL 和 SELECT |
| 05 | [MVCC / Read View](05-mvcc-read-view/) | REPEATABLE READ 和 READ COMMITTED 下，同一事务两次 SELECT 看到的数据为什么不一样 |
| 06 | [隔离级别对比：脏读 / 幻读](06-isolation-levels/) | READ UNCOMMITTED 才会脏读；READ COMMITTED 会幻读，REPEATABLE READ 的快照读天然不会 |
| 07 | [Next-Key Lock 范围判断](07-next-key-lock-ranges/) | 等值命中已有值会锁住两侧间隙，等值未命中只锁一个间隙，开区间会一路锁到 supremum |
