# Intermediate

| # | 主题 | 你会学到什么 |
|---|------|--------------|
| 01 | [死锁](01-deadlock/) | 两个事务如何在行锁上互相等待形成死锁 |
| 02 | [死锁发生后怎么排查](02-deadlock-analysis/) | 用 sys.innodb_lock_waits 和 SHOW ENGINE INNODB STATUS 分析死锁 |
| 03 | [间隙锁导致意外阻塞](03-gap-lock/) | REPEATABLE READ 下范围锁定读为什么会锁住"还不存在的数据" |
| 04 | [忘了提交的事务堵住一整张表](04-idle-transaction-blocks-ddl/) | 空闲事务持有的元数据锁，如何连带卡住无关的 DDL 和 SELECT |
