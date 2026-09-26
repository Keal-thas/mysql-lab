# 死锁（Deadlock）

## 你会学到什么

两个事务各自持有对方需要的行锁，互相等待，谁也无法继续——这就是死锁。InnoDB 有
死锁检测器，会主动选一个事务回滚来打破僵局，而不是让两边一直卡住。这个 demo
用两个转账事务手工复现一次经典死锁，并教你怎么用 `SHOW ENGINE INNODB STATUS`
读出死锁发生时的详细信息。

## 原理

- `accounts` 表有两行：Alice（id=1）、Bob（id=2）。
- 事务 A 先锁住 id=1，再尝试锁 id=2；事务 B 先锁住 id=2，再尝试锁 id=1。
- 如果两个事务的第一条 `UPDATE` 都先执行完，此时 A 持有 id=1 的锁、等待 id=2，
  B 持有 id=2 的锁、等待 id=1——形成环形等待，InnoDB 的死锁检测器会发现这个环，
  选一个事务回滚，报错 `1213 Deadlock found when trying to get lock; try
  restarting transaction`，另一个事务得以继续。

## 复现

准备数据：

```bash
../../client.sh < setup.sql
```

打开两个独立的 client 会话：

```bash
../../client.sh -D deadlock_lab   # session A
../../client.sh -D deadlock_lab   # session B
```

1. 在 **session A** 里，执行 `session_a.sql` 的第一条 `UPDATE`（锁住 id=1）。
2. 在 **session B** 里，执行 `session_b.sql` 全部内容（锁住 id=2，然后尝试锁
   id=1 时会被阻塞）。
3. 回到 **session A**，执行第二条 `UPDATE`（尝试锁 id=2）——此时 MySQL 的死锁
   检测器会杀掉其中一个事务，报错 1213。

事后查看死锁详情：

```sql
SHOW ENGINE INNODB STATUS\G
```

看 `LATEST DETECTED DEADLOCK` 这一段，里面会列出两个事务分别持有/等待哪些锁。
