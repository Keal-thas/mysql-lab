# 覆盖索引 / index-only scan

## 你会学到什么

`EXPLAIN` 的 `Extra` 列里，`Using index` 和 `Using index condition` 长得很
像，意思完全不同：前者是"这条查询靠索引就能拿到全部结果，不用回表"，后者是
"用索引先筛掉一批行，但最终还是要回表"。这个 demo 用同一张表、同一个索引，
调整 `SELECT` 的列和 `WHERE` 条件，让 `Extra` 在四种组合之间来回切换。

## 原理

- InnoDB 的二级索引（非主键索引）里，每条索引记录额外存了一份主键值。查询如果
  只需要索引列本身和主键，直接在二级索引上就能拿到全部数据，完全不用再跳到
  聚簇索引（主键索引，叶子节点存整行）去找——这叫**覆盖索引**（covering
  index），`Extra` 里会出现 `Using index`。
- 一旦 `SELECT` 的列里有任何一个不在索引里（比如本例的 `amount`），就必须顺着
  索引记录里存的主键值回聚簇索引再查一次整行——这叫**回表**。等值查询
  （`customer_id = 10`）已经精确定位到具体的行，不需要索引再帮忙过滤，所以
  `Extra` 里既没有 `Using index` 也没有 `Using index condition`。
- **索引条件下推**（Index Condition Pushdown，ICP）发生在：查询条件里有一部分
  能在索引内部判断（本例的 `status LIKE 'p%'`，属于联合索引的第二列，是一个
  范围条件），但查询还需要索引之外的列（比如 `SELECT *` 里的 `amount`）。
  MySQL 会先在索引里用 `status` 这个条件筛一遍，只对通过筛选的行才回表，减少
  不必要的回表次数——`Extra` 显示 `Using index condition`，说明"用了索引过滤，
  但还是要回表"。
- 如果这次 `SELECT` 的列本身就在索引里（不需要回表），同样的范围条件就不需要
  "下推"这个额外动作了——直接在索引内部完成过滤和取值，`Extra` 变成
  `Using where; Using index`：覆盖索引 + 范围过滤的组合，是四种情况里最快的。

## 复现

```bash
../../client.sh < demo.sql
```

四条 `EXPLAIN` 的 `Extra` 列依次是：

| # | SELECT 的列 | WHERE 条件 | Extra |
|---|-------------|-----------|-------|
| 1 | `customer_id, status`（都在索引里） | 等值 | `Using index` |
| 2 | `customer_id, status, amount`（amount 不在索引里） | 等值 | 无 |
| 3 | `*`（有列不在索引里） | 范围（`LIKE`） | `Using index condition` |
| 4 | `customer_id, status`（都在索引里） | 范围（`LIKE`） | `Using where; Using index` |

## 结论

- 想判断一条查询是不是覆盖索引，先看 `SELECT` 里用到的列（包括 `WHERE`/
  `ORDER BY` 隐含用到的）是不是都在某个索引里——**不是看有没有用上索引**，而是
  看用没用上"整个索引就够了"。
- `Using index condition` 不代表查询已经很快了，只代表"比不下推更快"——它依然
  要回表，只是回表次数变少了。真正想要极致性能、彻底避免回表，得把 `SELECT`
  需要的列也加进联合索引里（哪怕只是为了覆盖，这种做法有时被称为"宽索引"）。
- 联合索引设计时，常见套路是把等值查询的列放前面、范围查询的列放中间、
  查询里会用到的其他列放最后凑成覆盖索引——[联合索引最左前缀原则](../04-index-leftmost-prefix/)
  是这个套路成立的前提。
