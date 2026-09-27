# `SHOW PROCESSLIST` / Performance Schema 排查连接问题

## 你会学到什么

两个连接类问题的实测复现：一是"哪个连接空闲着还占了一个事务不提交"（这是
[`intermediate/04-idle-transaction-blocks-ddl`](../../intermediate/04-idle-transaction-blocks-ddl/)
背后那种连接的排查手段），二是"Too many connections"到底是什么、为什么 root
有时候还能连进去。

## 原理

- `SHOW PROCESSLIST`（或 `information_schema.processlist`）的 `Command =
  Sleep` 只说明这个连接现在没在跑语句，**不能区分**它是一个干干净净空闲的
  连接池连接，还是一个开了事务、正躺在那儿没提交的定时炸弹——这两种在
  `PROCESSLIST` 里长得一模一样。
- 要分辨出"空闲 + 有未提交事务"，得联查 Performance Schema：
  `performance_schema.threads` 把 `PROCESSLIST_ID` 和内部的 `THREAD_ID` 对上，
  再查 `performance_schema.events_transactions_current`，`STATE = 'ACTIVE'`
  就是这个线程当前有一个还没结束的事务。把这两张表和
  `information_schema.processlist` 的 `time`（空闲了多少秒）联起来，就能精确
  定位"空闲超过 N 秒、还有未提交事务"的连接，这正是会一路卡住 DDL、卡住
  purge 的那种。
- `max_connections` 是全局连接数上限，超过时新连接直接报 `1040 (HY000): Too
  many connections`。但具备 `CONNECTION_ADMIN`（或老版本的 `SUPER`）权限的账号
  （比如 `root`）在这个上限之上还有一个**预留连接**，专门留给管理员在连接数
  打满时也能连进去踢掉别的连接——这也是为什么用 root 压测这个上限时，会发现
  实际能连进去的连接数比 `max_connections` 设的值多一个。

## 复现

### 空闲事务排查

打开两个会话：

```bash
../../client.sh   # session A
../../client.sh   # session B
```

1. **session A** 执行 `session_a_idle_txn.sql`（开一个事务，只跑一条 `SELECT`，
   先别提交）。
2. **session B** 执行 `check_idle_txn.sql`：先看 `SHOW PROCESSLIST`，一堆
   `Sleep` 状态的连接分不出谁有问题；再跑下面那条联查 Performance Schema 的
   语句，只有 session A 这一条会出现在结果里，`trx_state = ACTIVE`。
3. 回 **session A** 执行 `COMMIT`。

### Too many connections

```bash
./too_many_connections.sh
```

脚本把 `max_connections` 临时调到 3，同时开 5 个连接，实测会看到 5 个里有 1 个
报 `ERROR 1040`，其余 4 个成功——比 `max_connections=3` 字面上多了 1 个，就是
root 的管理员预留连接生效了。脚本退出前会自动把 `max_connections` 改回原值。

## 结论

- 监控/告警不要只看"有多少个 Sleep 状态的连接"，这个数字在正常连接池下本来
  就很大，没有信息量；真正该告警的是"空闲超过阈值 **且** 有未提交事务"的连接数，
  这才是会拖累别的查询/DDL 的那一批。
- `max_connections` 打满导致业务连不上时，root 通常还能连进去做诊断
  （`SHOW PROCESSLIST`、`KILL` 掉占用连接最多的来源），前提是没把这个预留
  连接也耗尽——生产上要警惕"用同一个账号既跑业务又留作应急"这种设计。
