# 间隙锁（Gap Lock）导致意外阻塞

## 你会学到什么

`SELECT ... FOR UPDATE` 用了一个范围条件时，InnoDB 默认隔离级别
（`REPEATABLE READ`）不只锁住"已经存在的行"，还会锁住这个范围内的**间隙**。结果
是：另一个事务往这个范围里插入一行全新的、跟你没有任何交集的数据，也会被卡住。
很多人第一次遇到这种"明明没改同一行，为什么会被锁"的阻塞，都是间隙锁在起作用。

## 原理

- `REPEATABLE READ` 隔离级别下，为了防止幻读（同一个事务里两次执行同一个范围
  查询，第二次多出了别的事务新插入的行），InnoDB 用 **next-key lock**（记录锁 +
  间隙锁）锁住扫描到的范围，包括范围两端之间"还不存在数据"的间隙。
- `points` 表里 `val` 是 10、20、30。`SELECT ... WHERE val BETWEEN 10 AND 20
  FOR UPDATE` 会锁住 (10, 20) 这个区间，包括中间那个空隙。任何尝试往这个空隙里
  插入新行（比如 `val=15`）的事务，都要等这把锁释放。
- 换成 `READ COMMITTED` 隔离级别，InnoDB 对普通的锁定读只加记录锁、不加间隙锁
  （幻读问题交给应用自己容忍或用其他手段处理），同样的插入不会被阻塞。

## 复现

```bash
../../client.sh < setup.sql
../../client.sh -D gap_lock_lab   # session A
../../client.sh -D gap_lock_lab   # session B
```

1. **session A**：执行 `session_a.sql`（锁住 `val` 在 10~20 之间的行和间隙，先
   不要 `ROLLBACK`）。
2. **session B**：执行 `session_b.sql`，尝试插入 `(4, 15)`——会一直卡住，直到
   `innodb_lock_wait_timeout` 超时报错 `1205 Lock wait timeout exceeded`。
3. 回到 **session A**，执行 `ROLLBACK;` 把锁放掉。

对比一下隔离级别的影响：把 session A 第一行换成

```sql
SET SESSION transaction_isolation = 'READ-COMMITTED';
```

再重复一遍上面的步骤，这次 session B 的 `INSERT` 会立刻成功，不会被阻塞。

## 结论 / 怎么写才对

- 默认的 `REPEATABLE READ` + 范围条件的锁定读（`FOR UPDATE`/`FOR SHARE`/范围
  `UPDATE`/`DELETE`），会比你直觉上以为的锁住更多东西——尤其是"这个区间还没有
  数据"的部分。
- 高并发写入、经常在某个区间"insert 新数据"的场景（比如按时间递增写入、按某个
  分组 key 批量插入），如果同时有事务在对这个区间做范围锁定读，很容易出现看起来
  无关的插入互相卡住，甚至升级成死锁。
- 排查这类"莫名其妙的阻塞"，思路和 [死锁分析](../02-deadlock-analysis/) 一样：
  查 `sys.innodb_lock_waits`，看等的锁具体是 gap 锁还是 record 锁
  （`SHOW ENGINE INNODB STATUS` 的锁信息里会写 `locks gap before rec` 之类的
  说明）。
