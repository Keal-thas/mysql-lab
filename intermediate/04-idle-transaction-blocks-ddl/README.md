# 忘了提交的事务，堵住一整张表

## 你会学到什么

一个连接开了事务、执行了一条 `SELECT`，然后就晾在那儿没提交也没回滚（本地开发
时很常见：断点调试卡住了、忘了点提交、连接池里一个连接没归还干净）。这个空闲事务
本身看起来人畜无害，但只要这时候有人对同一张表跑一次 `ALTER TABLE`，整张表的
**所有**查询都会被拖下水排队等待——包括跟这次改表毫无关系的普通 `SELECT`。

## 原理

- 任何访问表的语句（哪怕只是 `SELECT`）都要先拿到这张表的元数据锁（MDL，
  metadata lock）。普通读写拿的是共享 MDL，彼此不冲突；`ALTER TABLE` 这类 DDL
  需要拿排他 MDL，必须等所有共享 MDL 都释放。
- session A 的事务只要没提交/回滚，它在 `SELECT` 时拿到的共享 MDL 就一直不释放
  ——即使这条 `SELECT` 本身早就执行完了。
- session B 的 `ALTER TABLE` 因此卡住，排在 MDL 等待队列里。
- **关键点**：MDL 等待队列基本是先进先出的，为了防止后来的读请求"插队"饿死排在
  前面的 DDL，session B 排队之后，新来的普通 `SELECT`（session C）即使只申请共享
  MDL、跟 A、B 都没有数据冲突，也必须排在 B 后面一起等，而不是直接插队执行。
- 结果就是：一个人忘了提交事务 + 另一个人凑巧跑了次 DDL = 全表流量卡死，直到
  第一个事务被找到并结束。

## 复现

```bash
../../client.sh < setup.sql
../../client.sh -D mdl_lab   # session A
../../client.sh -D mdl_lab   # session B
../../client.sh -D mdl_lab   # session C
```

1. **session A**：执行 `session_a.sql`，故意不提交。
2. **session B**：执行 `session_b.sql`（`ALTER TABLE`）——卡住，等待 A 的 MDL 释放。
3. **session C**：紧接着执行 `session_c.sql`（普通 `SELECT`）——同样卡住，直到
   `lock_wait_timeout` 超时报错 `1205`，即使 A、B、C 三者在数据上毫无交集。
4. 回到 **session A**，执行 `COMMIT;`，会看到 B 和 C 几乎同时恢复。

## 怎么排查 / 怎么写才对

- 生产上如果一条简单 `SELECT` 突然大量超时，别只想着锁行、锁表，先查
  `SHOW PROCESSLIST`，找状态是 `Waiting for table metadata lock` 的连接——那是
  排在队列里等 DDL 的；再往前找那个占着 MDL 迟迟不提交的事务（更细粒度的信息可以
  开启 `performance_schema` 里的 `wait/lock/metadata/sql/mdl` instrument 后查
  `performance_schema.metadata_locks`）。
- 任何客户端库/连接池都要保证事务边界清晰：读完就提交（哪怕是只读事务），不要
  依赖"反正是只读、放着也没事"的直觉——它照样占着 MDL。
- 生产环境的 DDL（尤其是大表）尽量避开高峰期，并且提前确认没有长事务在跑，
  必要时用 `ALTER TABLE ... , ALGORITHM=INSTANT` 等在线 DDL 方式减少影响。
