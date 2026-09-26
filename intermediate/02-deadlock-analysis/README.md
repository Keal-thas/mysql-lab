# 死锁发生后怎么排查

## 你会学到什么

看到 `1213 Deadlock found` 报错之后，怎么找出当时到底是谁和谁在抢什么锁。这里
复用 [01-deadlock](../01-deadlock/) 的转账场景，在死锁真正触发之前插入一个诊断
会话，分别演示"锁等待还没解开时怎么看"和"死锁已经发生怎么看"两种手段。

## 前置条件

先完成 [01-deadlock](../01-deadlock/) 的 `setup.sql`。

## 复现

除了 session A、session B（直接用 01-deadlock 的 `session_a.sql` /
`session_b.sql`），这次多开一个 session D 用来诊断：

```bash
../../client.sh -D deadlock_lab   # session A
../../client.sh -D deadlock_lab   # session B
../../client.sh -D deadlock_lab   # session D，诊断用
```

时间线：

1. **session A**：执行 `../01-deadlock/session_a.sql` 的第一条 `UPDATE`（锁住 id=1）。
2. **session B**：执行 `../01-deadlock/session_b.sql` 全部内容（锁住 id=2，然后
   卡在等 id=1 的锁）。
3. **session D**：执行 `diagnose.sql` 的第一段（`sys.innodb_lock_waits`）。此时
   死锁还没发生，只是 B 在正常等锁，你能看到 B 在等谁、等的锁被谁占着：

   ```
   waiting_pid  waiting_query                                  blocking_pid  blocking_query
   B 的线程id    UPDATE accounts SET balance=balance+50 ...     A 的线程id    NULL（A 当前空闲, 等着你敲下一条)
   ```

4. **session A**：执行第二条 `UPDATE`（尝试锁 id=2）——这一步会让等待环闭合，
   InnoDB 检测到死锁，A 报错 1213 并回滚，B 的 `UPDATE` 随即成功返回。
5. **session D**：执行 `diagnose.sql` 的第二段（`SHOW ENGINE INNODB STATUS`），
   在 `LATEST DETECTED DEADLOCK` 里能看到两个事务分别持有/等待的具体锁，以及
   `WE ROLL BACK TRANSACTION (2)` 这样的结论——即最后是哪个事务被牺牲掉了。

## 关键点

- **`sys.innodb_lock_waits`**：看**正在进行中**的锁等待，比直接读
  `SHOW ENGINE INNODB STATUS` 的大段文本好读得多，生产上怀疑某个查询被卡住时
  第一时间应该查这个（底层是 `performance_schema.data_lock_waits` 关联出来的）。
- **`SHOW ENGINE INNODB STATUS` 里的 `LATEST DETECTED DEADLOCK`**：看**已经发生
  过**的死锁详情，但只保留最近一次——如果短时间内连续发生多起死锁，前面的会被
  覆盖看不到。
- 生产环境建议打开 `innodb_print_all_deadlocks = ON`（可以直接
  `SET GLOBAL innodb_print_all_deadlocks = ON;` 动态生效），这样每一次死锁都会
  完整记录到错误日志里，不会被后面的死锁覆盖。

## 结论

死锁本身 InnoDB 会自动兜底（回滚一方），应用层只要对 1213 错误做好重试；真正
需要人工介入的是**频繁**死锁——这时候上面两个工具能告诉你具体是哪些 SQL、按什么
顺序访问了哪些行，从而判断是不是能通过调整访问顺序、缩小事务范围、加合适的索引
来减少锁冲突。
