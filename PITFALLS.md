# 坑列表

所有 demo 的一句话简述，方便扫一眼找相关的坑。想看原理和复现步骤，点进对应链接。

| 级别 | 坑 | 一句话简述 |
|------|----|-----------|
| 初级 | [ORDER BY 平局顺序](beginner/01-order-by-tie-order/) | 排序列有相同值时，谁先谁后不保证固定，靠索引/filesort 的实现细节决定 |
| 初级 | [EXPLAIN 怎么读](beginner/02-explain-basics/) | 执行计划的 type/key/rows/Extra 分别在说什么，EXPLAIN 只是估算、EXPLAIN ANALYZE 才是真跑一遍 |
| 初级 | [隐式类型转换让索引失效](beginner/03-implicit-type-conversion/) | 字符串列拿数字字面量比较，索引基本失效，实测慢了近 800 倍 |
| 初级 | [联合索引最左前缀原则](beginner/04-index-leftmost-prefix/) | 联合索引 (a,b) 只能加速 a、a+b，跳过 a 单独查 b 完全用不上 |
| 初级 | [大 OFFSET 分页越翻越慢](beginner/05-offset-pagination/) | OFFSET 越大，被扫描又丢弃的行越多；游标分页翻到哪页都一样快 |
| 中级 | [死锁](intermediate/01-deadlock/) | 两个事务交叉锁不同行，互相等待形成死锁环，InnoDB 自动回滚一方 |
| 中级 | [死锁发生后怎么排查](intermediate/02-deadlock-analysis/) | sys.innodb_lock_waits 看进行中的锁等待，SHOW ENGINE INNODB STATUS 看已发生的死锁详情 |
| 中级 | [间隙锁导致意外阻塞](intermediate/03-gap-lock/) | REPEATABLE READ 下范围锁定读连"还不存在的数据"的间隙也锁住，插入新行会被卡住 |
| 中级 | [忘了提交的事务堵住一整张表](intermediate/04-idle-transaction-blocks-ddl/) | 空闲事务占着元数据锁，别人一跑 DDL，连无关的 SELECT 都要排队 |
| 高级 | [慢查询定位与调优思路](advanced/01-slow-query-tuning/) | 慢查询日志 + EXPLAIN ANALYZE 定位问题；索引选择性差时优化器可能主动放弃索引 |

新增坑时在这里加一行，同时更新对应级别目录下的 `README.md`。
