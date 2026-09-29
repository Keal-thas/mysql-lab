# Online DDL：ALGORITHM 和 LOCK 对读写的影响

## 你会学到什么

`ALTER TABLE` 在大表上到底会不会锁表，答案取决于你在改什么、MySQL 选了哪种
`ALGORITHM`。这个 demo 在一张 200 万行的表上跑三种典型的 `ALTER`，实测
`INSTANT`/`INPLACE`/`COPY` 三种算法执行耗时的数量级差异，以及并发 `INSERT`
在每种算法下到底会不会被卡住。

## 原理

- **`ALGORITHM=INSTANT`**（MySQL 8.0.12+，仅支持部分操作，比如在表尾加一个
  可为空/有默认值的列）：不touch 任何已有行，只是在表的元数据里记一笔"这张表
  从现在起多一列"，读到旧行时用默认值补齐。耗时和表有多少行完全无关，
  哪怕是几亿行的表也是毫秒级。
- **`ALGORITHM=INPLACE`**（大多数加索引、部分加列/改列的场景）：会在存储引擎
  内部重建需要变动的结构（比如新建一棵 B+ 树索引），但不需要把整张表复制一份。
  配合 `LOCK=NONE`，重建期间的绝大部分时间里，并发的 `SELECT`/`INSERT`/
  `UPDATE`/`DELETE` 都不受影响——这是"online DDL"这个说法的由来。
- **`ALGORITHM=COPY`**（不支持 `INSTANT`/`INPLACE` 的操作会退化到这个，比如
  某些字符集转换；这里为了演示效果特意显式指定）：MySQL 在后台建一张新表、
  把数据整个拷贝过去，再原子地换名。配合 `LOCK=EXCLUSIVE`，整个拷贝期间对这张
  表的读写都会被 DDL 持有的排它元数据锁挡住，直到 `ALTER` 完成——表越大，
  锁的时间越长。

## 复现

准备数据（生成 200 万行，方便让 `COPY` 的耗时肉眼可见）：

```bash
../../client.sh < setup.sql
```

### `ALGORITHM=INSTANT`

```bash
../../client.sh < session_a_instant.sql
```

对比 `t0`/`t1` 两个时间戳——相差几毫秒，2,000,000 行的表加一列没有感觉。

### `ALGORITHM=INPLACE, LOCK=NONE`

打开两个会话：

```bash
../../client.sh < session_a_inplace.sql   # session A
../../client.sh < session_b_inplace.sql   # session B，在 A 跑的同时/紧接着执行
```

session A 的 `ALTER`（加二级索引）大概要跑几百毫秒到一秒；session B 的
`INSERT` 会立刻完成（毫秒级），`insert_start`/`insert_done` 的时间戳落在
session A 的 `t0`/`t1` 中间，说明并发写入完全没被这个 DDL 卡住。

### `ALGORITHM=COPY, LOCK=EXCLUSIVE`

```bash
../../client.sh < session_a_copy.sql   # session A
../../client.sh < session_b_copy.sql   # session B，在 A 跑的同时/紧接着执行
```

这次 session B 的 `insert_done` 会卡在 session A 的 `ALTER` 结束（`t1`）附近，
而不是紧跟着 `insert_start`——这条 `INSERT` 排在了 `ALTER` 持有的排它锁后面，
硬等了几秒。

## 结论

- 判断一个 `ALTER TABLE` 会不会锁表，先看 MySQL 官方文档里这个操作对应的
  `Algorithm`/`Concurrent DML` 支持情况（`ALTER TABLE` 章节有完整表格），
  而不是凭经验猜。可以显式加 `ALGORITHM=INPLACE, LOCK=NONE` 让 MySQL 校验：
  如果这个操作实际上做不到，会直接报错而不是默默退化成 `COPY`——生产上想要
  这个"保险丝"效果，显式指定比让 MySQL 自动选更安全。
- 大表上做"加字段/加索引"这类操作，优先确认是否落在 `INSTANT`/`INPLACE` 支持
  范围内；真的需要 `ALGORITHM=COPY`（比如改字符集）时，评估耗时（跟行数、
  行大小基本成正比）并在低峰期做，因为整个过程会挡住这张表的所有读写。
- 这个 demo 只测了 `INSERT`；`SELECT` 在 `LOCK=EXCLUSIVE` 下也会被挡住，只是
  `ALTER` 刚启动、还没真正拿到排它锁的一瞬间可能会侥幸插队成功——不要依赖这个
  时间窗口，生产上按"整个过程都会锁"来评估影响。
