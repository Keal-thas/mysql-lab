# MVCC / Read View

## 你会学到什么

同一个事务里，两次读同一行，为什么有时候看到的是同一个旧值（哪怕别的事务已经
改完并提交了），有时候又能立刻看到别人刚提交的新值。答案不是"锁"，是每个事务
读数据时用的 **Read View**（快照）什么时候生成——REPEATABLE READ 和 READ
COMMITTED 的区别就在这一点上。

## 原理

- InnoDB 的每一行都有隐藏的版本信息（事务 ID + 指向 undo log 的指针），
  一行数据的历史版本靠 undo log 链起来，这就是 MVCC（多版本并发控制）的基础。
- 一个事务执行 `SELECT` 时不是直接读最新数据，而是先生成（或复用）一个
  **Read View**：一份"哪些事务的修改对我可见"的快照，然后顺着 undo log 链
  找到符合这份快照规则的那个历史版本。
- 两种隔离级别的区别，就是 Read View 什么时候生成：
  - **REPEATABLE READ**（MySQL 默认）：事务内第一条 `SELECT` 时生成一次 Read
    View，之后整个事务复用同一份，所以事务中途读到的永远是"事务开始那一刻"
    的世界——这就是"可重复读"名字的来源，靠 MVCC 实现，不需要锁住整张表。
  - **READ COMMITTED**：每一条 `SELECT` 都重新生成一份 Read View，所以能看到
    别的事务在这期间刚提交的修改。
- 这解释了为什么 MVCC 读（普通 `SELECT`）不会被写操作阻塞，也不会阻塞写操作——
  读的是历史版本，不需要跟当前正在写的那个版本抢锁。

## 复现

准备数据：

```bash
../../client.sh < setup.sql
```

### REPEATABLE READ（默认隔离级别）

打开两个独立的 client 会话：

```bash
../../client.sh -D mvcc_lab   # session A
../../client.sh -D mvcc_lab   # session B
```

1. 在 **session A** 执行 `session_a_rr.sql` 到第一条 `SELECT` 为止，看到
   `1000.00`。
2. 切到 **session B**，执行 `session_b.sql` 全部内容（把 balance 改成 500 并
   提交）。
3. 回到 **session A**，执行第二条 `SELECT`——还是 `1000.00`，B 已经提交的修改
   在这个事务里看不见。
4. 执行 `COMMIT`，再执行第三条 `SELECT`——变成 `500.00`：新事务拿到了新的
   Read View。

### READ COMMITTED（对比）

重置数据（`../../client.sh < setup.sql`），再打开两个会话，这次跑
`session_a_rc.sql` 和 `session_b.sql`，重复同样的步骤：session A 的第二条
`SELECT` 会立刻看到 B 提交的新值，因为 READ COMMITTED 每条语句都重新生成
Read View。

## 结论

- `SELECT ... FROM ...`（不带 `FOR UPDATE`/`LOCK IN SHARE MODE`）是"快照读"，
  靠 MVCC 实现，不加锁；只有 `FOR UPDATE`、`UPDATE`、`DELETE` 这类才是"当前读"，
  会读最新版本并加锁。
- REPEATABLE READ 的"可重复读"保证来自事务级别只生成一次的 Read View，不是
  靠锁住整张表实现的，所以读操作几乎不影响并发写入。
- 隔离级别选择本质上是在"事务内看到的数据是否始终一致"和"能多快看到别人的
  提交"之间做取舍；MySQL 默认 REPEATABLE READ，Oracle/PostgreSQL 默认
  READ COMMITTED，两种都常见，选型时要清楚这个区别。
