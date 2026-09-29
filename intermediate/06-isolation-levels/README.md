# 隔离级别对比：脏读 / 幻读

## 你会学到什么

SQL 标准定义了四种隔离级别，用来在"事务间互相隔离的程度"和"并发性能"之间做
取舍。这个 demo 用两组对照实验，实测两种反直觉的现象在不同隔离级别下是否出现：
**脏读**（读到别的事务还没提交的数据）和**幻读**（同一个事务里两次范围查询，
结果集多了几行）。可重复读本身已经在 [`05-mvcc-read-view`](../05-mvcc-read-view/)
demo 里演示过了，这里不重复。

## 原理

- **脏读（Dirty Read）**：只有 `READ UNCOMMITTED` 会出现。这个级别下读操作完全
  不看 Read View，直接读当前最新版本，哪怕这个版本来自一个还没提交、甚至最终会
  回滚的事务。生产环境基本不会用这个级别。
- **幻读（Phantom Read）**：标准定义是"同一事务内两次范围查询，第二次多出了别的
  事务新插入并提交的行"。
  - `READ COMMITTED` 下每条 `SELECT` 都重新生成 Read View（见
    [`05-mvcc-read-view`](../05-mvcc-read-view/) 的原理部分），所以必然会看到
    幻读。
  - `REPEATABLE READ` 下，**普通的快照读**（不带 `FOR UPDATE`）复用同一个 Read
    View，所以同一事务内看不到新插入的行——这是 InnoDB 对标准 RR 级别的增强，
    比 SQL 标准要求的更强。但这只对快照读成立：如果改成 `SELECT ... FOR
    UPDATE`（当前读），InnoDB 靠 next-key lock 把插入范围也锁住，直接阻止别的
    事务插入（见 [`03-gap-lock`](../03-gap-lock/) demo），这是另一种防幻读手段，
    不是"消失的幻读"而是"幻读被提前挡住了"。

## 复现

准备数据：

```bash
../../client.sh < setup.sql
```

### 脏读

打开两个会话：

```bash
../../client.sh -D iso_lab   # session A
../../client.sh -D iso_lab   # session B
```

1. **session A** 执行 `session_a_dirty_ru.sql`（`READ UNCOMMITTED`）到第一条
   `SELECT` 为止，看到 `100.00`。
2. **session B** 执行 `session_b_dirty.sql` 的前两条语句（`UPDATE`，先别
   `ROLLBACK`）。
3. 回 **session A**，执行第二条 `SELECT`——看到 `999.00`，脏读命中：B 还没提交
   的修改被 A 看见了。
4. 回 **session B**，执行 `ROLLBACK`。
5. 回 **session A**，执行第三条 `SELECT`——变回 `100.00`：刚才读到的 `999.00`
   从来没真正存在过。

重置数据（`../../client.sh < setup.sql`），换成 `session_a_dirty_rc.sql`
（`READ COMMITTED`）重复同样步骤：这次 A 的第二条 `SELECT` 始终是 `100.00`，
B 未提交的修改看不见。

### 幻读

重置数据，打开两个会话，跑 `session_a_phantom_rc.sql`（`READ COMMITTED`）+
`session_b_phantom.sql`：A 事务内两次 `COUNT(*)` 从 `3` 变成 `4`，幻读发生。

再重置数据，换成 `session_a_phantom_rr.sql`（`REPEATABLE READ`，默认级别）+
`session_b_phantom.sql`：A 事务内两次 `COUNT(*)` 都是 `3`，直到 `COMMIT` 后
开一个新事务才看到 `4`——没有幻读。

## 结论

- `READ UNCOMMITTED` 几乎没有生产场景会用，唯一的"好处"是不用维护 Read View、
  性能最高，代价是脏读——读到根本不存在的数据。
- MySQL 默认的 `REPEATABLE READ` 对幻读的防护比 SQL 标准要求的更强：普通查询
  靠 MVCC 快照就避免了幻读，不需要像 `SELECT ... FOR UPDATE` 那样靠锁。这也是
  很多人以为"MySQL 的 RR 不会有幻读"的来源——严格说只对快照读成立。
- 选隔离级别本质是在"一致性保证"和"并发能力/加锁范围"之间取舍：级别越低，
  可能看到的异常越多，但锁的范围越小、并发越好。
