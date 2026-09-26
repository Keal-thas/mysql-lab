# EXPLAIN 怎么读（执行计划基础）

## 你会学到什么

`EXPLAIN` 告诉你 MySQL **打算**怎么执行一条查询：走不走索引、扫多少行、要不要
额外排序。看不懂 `EXPLAIN` 就没法判断一条慢查询到底慢在哪。这个 demo 过一遍最
常用的几列，以及 `EXPLAIN` 和 `EXPLAIN ANALYZE` 的区别。

## 原理 / 关键列

- **type**：这条查询访问表的方式，从好到差大致是
  `system/const > eq_ref > ref > range > index > ALL`。
  - `ALL` = 全表扫描
  - `index` = 扫的是整个索引（比全表扫描省 I/O，但还是要扫全部条目）
  - `ref` = 用索引做等值查找，命中一部分行
- **key**：实际用的索引；`possible_keys` 只是"理论上能用"的索引，不代表真的用了。
- **rows**：优化器**估算**要扫描的行数（不是返回的行数），配合 `filtered`
  （估算过滤后剩多少比例）判断这条查询的开销数量级。
- **Extra**：常见几个值
  - `Using index`：覆盖索引，不用回表查聚簇索引
  - `Using where`：存储引擎返回的行还要在 server 层再过滤一次
  - `Using filesort`：需要额外排序（不是走索引直接有序）
  - `Using temporary`：需要建临时表（常见于 `GROUP BY`/`DISTINCT`）
- **`EXPLAIN` 是估算，`EXPLAIN ANALYZE` 是真的跑一遍**：`EXPLAIN` 给的
  `rows`/`cost` 是优化器根据统计信息猜的，可能和实际情况差很远（数据分布倾斜、
  统计信息过期都会导致估算不准）；`EXPLAIN ANALYZE`（MySQL 8.0.18+）会真正执行
  查询，给出每一步的 `actual time` 和 `rows`，是排查"为什么这条查询这么慢"时更
  可信的依据。

## 复现

```bash
../../client.sh < demo.sql
```

在 5 万行的表上，`customer_id = 10`（有索引）大约扫几十行，`status = 'paid'`
（无索引）会扫全部 5 万行——`EXPLAIN` 里 `rows` 列的数量级差异，就是两者性能差异
的直接体现，`EXPLAIN ANALYZE` 的 `actual time` 会进一步验证这一点。

## 相关

后面几个 demo 都会大量用到 `EXPLAIN`/`EXPLAIN ANALYZE`：
[隐式类型转换](../03-implicit-type-conversion/)、
[最左前缀原则](../04-index-leftmost-prefix/)、
[慢查询定位与调优](../../advanced/01-slow-query-tuning/)。
