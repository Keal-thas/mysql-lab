# 案例索引

所有 demo 的一句话简述，方便扫一眼找相关的案例。想看原理和复现步骤，点进对应链接。

| 级别 | 案例 | 一句话简述 |
|------|----|-----------|
| 初级 | [ORDER BY 平局顺序](beginner/01-order-by-tie-order/) | 排序列有相同值时，谁先谁后不保证固定，靠索引/filesort 的实现细节决定 |
| 初级 | [EXPLAIN 怎么读](beginner/02-explain-basics/) | 执行计划的 type/key/rows/Extra 分别在说什么，EXPLAIN 只是估算、EXPLAIN ANALYZE 才是真跑一遍 |
| 初级 | [隐式类型转换让索引失效](beginner/03-implicit-type-conversion/) | 字符串列拿数字字面量比较，索引基本失效，实测慢了近 800 倍 |
| 初级 | [联合索引最左前缀原则](beginner/04-index-leftmost-prefix/) | 联合索引 (a,b) 只能加速 a、a+b，跳过 a 单独查 b 完全用不上 |
| 初级 | [大 OFFSET 分页越翻越慢](beginner/05-offset-pagination/) | OFFSET 越大，被扫描又丢弃的行越多；游标分页翻到哪页都一样快 |
| 初级 | [覆盖索引 / index-only scan](beginner/06-covering-index/) | 查询的列只要都在索引里就不用回表；Using index 是覆盖索引，Using index condition 还是要回表 |
| 中级 | [死锁](intermediate/01-deadlock/) | 两个事务交叉锁不同行，互相等待形成死锁环，InnoDB 自动回滚一方 |
| 中级 | [死锁发生后怎么排查](intermediate/02-deadlock-analysis/) | sys.innodb_lock_waits 看进行中的锁等待，SHOW ENGINE INNODB STATUS 看已发生的死锁详情 |
| 中级 | [间隙锁导致意外阻塞](intermediate/03-gap-lock/) | REPEATABLE READ 下范围锁定读连"还不存在的数据"的间隙也锁住，插入新行会被卡住 |
| 中级 | [忘了提交的事务堵住一整张表](intermediate/04-idle-transaction-blocks-ddl/) | 空闲事务占着元数据锁，别人一跑 DDL，连无关的 SELECT 都要排队 |
| 中级 | [MVCC / Read View](intermediate/05-mvcc-read-view/) | REPEATABLE READ 的事务只在第一条 SELECT 时生成一次快照，READ COMMITTED 每条 SELECT 都重新生成 |
| 中级 | [隔离级别对比：脏读 / 幻读](intermediate/06-isolation-levels/) | READ UNCOMMITTED 能读到别人没提交的数据；REPEATABLE READ 的快照读比标准要求更强，天然不会幻读 |
| 中级 | [Next-Key Lock 范围判断](intermediate/07-next-key-lock-ranges/) | 等值命中已有值锁两侧间隙、等值未命中只锁一个间隙、开区间锁到 supremum，三种情况范围完全不同 |
| 高级 | [慢查询定位与调优思路](advanced/01-slow-query-tuning/) | 慢查询日志 + EXPLAIN ANALYZE 定位问题；索引选择性差时优化器可能主动放弃索引 |
| 高级 | [Online DDL：ALGORITHM 和 LOCK](advanced/02-online-ddl/) | INSTANT 加列跟行数无关都是毫秒级；INPLACE+LOCK=NONE 不挡并发写；COPY+LOCK=EXCLUSIVE 会让并发写硬等到 ALTER 结束 |
| 高级 | [COUNT(*) 优化](advanced/03-count-star/) | InnoDB 的 COUNT(*) 是真扫描，不是查现成的行数；近似值几乎零成本但不准，维护计数表精确但要多付出写入代价 |
| 高级 | [SHOW PROCESSLIST / Performance Schema 排查连接问题](advanced/04-connection-troubleshooting/) | Sleep 状态分不出连接有没有未提交事务，得联查 Performance Schema；root 因为管理员预留连接能在 Too many connections 时多连进去一个 |
| 高级 | [JSON 类型的索引方式（生成列 + 索引）](advanced/05-json-generated-column-index/) | JSON 列不能直接建索引，得靠 STORED 生成列抽出字段再建索引；直接写生成列名比写原始 JSON 表达式快，因为前者是覆盖索引 |
| 高级 | [分区表：适用场景与注意事项](advanced/06-partitioning/) | 条件包一层函数会让分区裁剪失效，跟索引失效是同一类坑；DROP PARTITION 删同量级数据比 DELETE 快一到两个数量级 |

新增案例时在这里加一行，同时更新对应级别目录下的 `README.md`。
