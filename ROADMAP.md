# 路线图

这个仓库的原则是"每个主题都要有能跑起来的 demo"，不是背知识点清单。这份文档只做
两件事：列出**已经有 demo 的案例**该按什么顺序学，以及**值得补的下一批案例**，方便按
优先级挑选下一个要写的 demo。想看已完成案例的一句话简述，去 [`PITFALLS.md`](PITFALLS.md)。

## 已有 demo：建议学习顺序

1. `beginner/01` ORDER BY 平局顺序
2. `beginner/02` EXPLAIN 怎么读
3. `beginner/04` 联合索引最左前缀原则
4. `beginner/03` 隐式类型转换让索引失效
5. `beginner/06` 覆盖索引 / index-only scan
6. `beginner/05` 大 OFFSET 分页越翻越慢
7. `intermediate/01` 死锁
8. `intermediate/02` 死锁发生后怎么排查
9. `intermediate/03` 间隙锁导致意外阻塞
10. `intermediate/04` 忘了提交的事务堵住一整张表
11. `intermediate/05` MVCC / Read View
12. `intermediate/06` 隔离级别对比：脏读 / 幻读
13. `intermediate/07` Next-Key Lock 范围判断
14. `advanced/01` 慢查询定位与调优思路

## 下一批值得补的案例（按优先级）

### 高优先级

- **Online DDL 的 ALGORITHM/LOCK**：`ALTER TABLE` 在大表上加字段/加索引时，
  INSTANT/INPLACE/COPY 对读写的影响。适合放 `advanced/`。

### 中优先级

- **慢查询之外：`COUNT(*)` 优化**：为什么 `COUNT(*)` 在大表上慢，近似值/维护计数
  表两种思路。
- **binlog 格式与用途**：STATEMENT / ROW / MIXED 的区别，配合 `mysqlbinlog` 做
  一次最小可复现的 point-in-time 恢复。
- **`SHOW PROCESSLIST` / Performance Schema 排查连接问题**："Too many
  connections"、长时间未提交的连接怎么定位。

### 低优先级 / 视兴趣再做

- JSON 类型的索引方式（生成列 + 索引）
- 分区表的适用场景与注意事项
- 主从复制延迟的最小可复现 demo

## 新增一个案例的步骤

1. 在对应难度目录下新建编号子目录（`beginner/06-xxx`、`intermediate/05-xxx` ...）。
2. 写 `README.md`，至少包含"你会学到什么 / 原理 / 复现 / 结论"四段（可按需增减，
   参考已有 demo 的写法）。
3. 写配套的 `.sql` 文件，能直接用 `../../client.sh < xxx.sql` 跑通。
4. 在该难度目录的 `README.md` 表格里加一行。
5. 在根目录 [`PITFALLS.md`](PITFALLS.md) 里加一行一句话简述。
6. 如果这份路线图里列了这个案例，把它从待办列表挪掉。
