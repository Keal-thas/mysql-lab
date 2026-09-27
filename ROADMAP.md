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
15. `advanced/02` Online DDL：ALGORITHM 和 LOCK
16. `advanced/03` COUNT(*) 优化
17. `advanced/04` SHOW PROCESSLIST / Performance Schema 排查连接问题
18. `advanced/05` JSON 类型的索引方式（生成列 + 索引）
19. `advanced/06` 分区表：适用场景与注意事项

## 下一批值得补的案例（按优先级）

### 中优先级

- **binlog 格式与用途**：STATEMENT / ROW / MIXED 的区别，配合 `mysqlbinlog` 做
  一次最小可复现的 point-in-time 恢复。**卡住了**：`mysql-lab` 用的 MySQL 8.4
  官方镜像里没带 `mysqlbinlog` 这个客户端（`docker exec mysql-lab which
  mysqlbinlog` 找不到），host 机器上也没装，没法写出真的跑得通的复现步骤。
  想继续做的话，得先给 `docker-compose.yml` 加一个带完整客户端工具的镜像/
  sidecar，这是个基础设施改动，先搁置。

### 低优先级 / 视兴趣再做

- 主从复制延迟的最小可复现 demo。**需要基础设施改动**：得往
  `docker-compose.yml` 里加一个从库容器（配置 `server-id`、
  `CHANGE REPLICATION SOURCE TO`），比单纯写文档/demo 的改动范围大，先搁置，
  等用户明确要做的时候再动 compose 配置。

## 新增一个案例的步骤

1. 在对应难度目录下新建编号子目录（`beginner/06-xxx`、`intermediate/05-xxx` ...）。
2. 写 `README.md`，至少包含"你会学到什么 / 原理 / 复现 / 结论"四段（可按需增减，
   参考已有 demo 的写法）。
3. 写配套的 `.sql` 文件，能直接用 `../../client.sh < xxx.sql` 跑通。
4. 在该难度目录的 `README.md` 表格里加一行。
5. 在根目录 [`PITFALLS.md`](PITFALLS.md) 里加一行一句话简述。
6. 如果这份路线图里列了这个案例，把它从待办列表挪掉。
