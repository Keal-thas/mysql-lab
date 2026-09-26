# 联合索引最左前缀原则

## 你会学到什么

给 `(customer_id, status)` 建了联合索引，`WHERE customer_id = ...` 能用上，
`WHERE customer_id = ... AND status = ...` 也能用上，但**单独**
`WHERE status = ...` 完全用不上这个索引——哪怕 `status` 明明就在索引里。这是
"为什么我明明建了索引，EXPLAIN 还是全表扫描"最常见的原因之一。

## 原理

联合索引在物理上是按列的顺序组织的：先按 `customer_id` 排序，`customer_id`
相同的行再按 `status` 排序。这决定了它只能支持"从最左边的列开始、连续使用"的
查询条件：

- 只给 `customer_id`：在索引里能直接二分定位到一段连续区间 —— 可以用。
- 给 `customer_id` + `status`：定位到的区间比只给 `customer_id` 更小 —— 可以用，
  而且更精确。
- 只给 `status`，跳过 `customer_id`：不同 `customer_id` 下的 `status` 值在索引
  里根本不相邻（想象成先按姓氏排序、姓氏相同再按名字排序的电话簿，你没法直接
  凭"名字"去二分查找）—— 用不上，只能全表扫描。

这就是"最左前缀原则"：联合索引 `(a, b, c)` 能加速的查询条件组合是
`a`、`a+b`、`a+b+c`，唯独不包括跳过 `a` 之后的任何组合。

## 复现

```bash
../../client.sh < demo.sql
```

看 `EXPLAIN` 里的 `key` 和 `key_len`：

- 只用 `customer_id`：`key=idx_customer_status`，`key_len=4`（只匹配了第一列）
- `customer_id` + `status`：`key=idx_customer_status`，`key_len=46`（两列都匹配上了）
- 只用 `status`：`key=NULL`，`type=ALL`，全表扫描 5 万行

## 结论 / 怎么写才对

设计联合索引时，把**最常用来做等值查询、区分度高**的列放在最前面；如果一个查询
条件经常"单独"出现却排在联合索引的非最左位置，那它需要一个自己的索引，或者把
联合索引的列顺序调整一下——不存在"一个索引优化所有查询顺序"这种事。
