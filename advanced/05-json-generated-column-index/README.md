# JSON 类型的索引方式（生成列 + 索引）

## 你会学到什么

MySQL 不能直接在 `JSON` 类型的列上建普通索引（`JSON` 列没有固定长度、不能
直接比较大小），但业务里经常需要按 JSON 里的某个字段过滤。这个 demo 用
**生成列**（generated column）把 JSON 里的字段"抽出来"单独存一份、再给这个
生成列建索引，实测三种查询方式的性能差异。

## 原理

- `ALTER TABLE ... ADD COLUMN brand VARCHAR(50) GENERATED ALWAYS AS (attrs ->>
  '$.brand') STORED` 会新增一个从 `attrs` 这个 JSON 列算出来的列。`STORED`
  表示这个值会实际写盘（跟着原表一起存），而不是每次查询时现算的 `VIRTUAL`——
  想在这个列上建索引，必须是 `STORED`（`VIRTUAL` 生成列在部分场景也能建索引，
  但语义和存储代价不同，`STORED` 更直观）。
- `->>` 是 `JSON_UNQUOTE(JSON_EXTRACT(...))` 的简写，取出字段值并去掉 JSON
  字符串外层的引号，这样生成列才是一个普通的 `VARCHAR`，可以像任何其他列
  一样建 B+树索引。
- **表达式索引识别**（MySQL 8.0.13+）：只要 `WHERE` 条件里的表达式和某个生成
  列的定义完全一致（这里是 `attrs ->> '$.brand'`），优化器就能自动把这个表达式
  换算成对那个生成列的索引查找——不需要改查询语句去显式引用生成列名，这对不
  方便改 SQL 的场景（比如 ORM 生成的查询）很有用。
- 不过直接写生成列名（`WHERE brand = 'acme'`）和写原始表达式
  （`WHERE attrs ->> '$.brand' = 'acme'`）实测走的执行计划不完全一样：前者是
  `Covering index lookup`（索引本身就够用，不用回表），后者是普通的
  `Index lookup`（用上了索引缩小范围，但优化器认为还需要回表核对）——同一个
  索引，写法不同，优化器给出的执行计划保守程度不一样。

## 复现

```bash
../../client.sh < demo.sql
```

三条 `EXPLAIN ANALYZE` 在 200 万行、5 种 brand 取值（`acme` 占 40 万行）上的
实测耗时：

| # | 表 | WHERE 写法 | 执行计划 | 实测耗时 |
|---|----|-----------|---------|---------|
| 1 | 无索引 | `attrs ->> '$.brand' = 'acme'` | `Table scan` + `Filter` | ~440ms |
| 2 | 有生成列索引 | `attrs ->> '$.brand' = 'acme'`（原始表达式） | `Index lookup` | ~250ms |
| 3 | 有生成列索引 | `brand = 'acme'`（生成列名） | `Covering index lookup` | ~40ms |

## 结论

- 给 JSON 字段建索引的标准做法就是"生成列 + 索引"，不是什么特殊语法，
  该有的索引设计原则（选择性、覆盖索引）都适用。
- 能改查询语句的话，直接用生成列名（场景 3）比用原始 JSON 表达式（场景 2）
  更快——虽然两者都用上了索引，优化器对"直接是索引列"和"表达式匹配到索引"
  给出的执行计划不完全对等。
- 如果 JSON 里要按多个字段过滤，可以加多个生成列、建联合索引，用法和普通表的
  联合索引完全一样，参考
  [联合索引最左前缀原则](../../beginner/04-index-leftmost-prefix/)。
