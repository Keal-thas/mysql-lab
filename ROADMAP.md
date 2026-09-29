# 路线图

这个仓库的原则是"每个主题都要有能跑起来的 demo"，不是背知识点清单。这份文档只做
两件事：列出**已经有 demo 的案例**该按什么顺序学，以及**值得补的下一批案例**，方便按
优先级挑选下一个要写的 demo。想看已完成案例的一句话简述，去 [`PITFALLS.md`](PITFALLS.md)。

## 已有 demo：建议学习顺序

1. `beginner/01` ORDER BY 平局顺序
2. `beginner/02` EXPLAIN 怎么读
3. `beginner/04` 联合索引最左前缀原则
4. `beginner/03` 隐式类型转换让索引失效
5. `beginner/07` 长数字/长字符串"看起来不一样、比出来却一样"
6. `beginner/06` 覆盖索引 / index-only scan
7. `beginner/05` 大 OFFSET 分页越翻越慢
8. `intermediate/01` 死锁
9. `intermediate/02` 死锁发生后怎么排查
10. `intermediate/03` 间隙锁导致意外阻塞
11. `intermediate/04` 忘了提交的事务堵住一整张表
12. `intermediate/05` MVCC / Read View
13. `intermediate/06` 隔离级别对比：脏读 / 幻读
14. `intermediate/07` Next-Key Lock 范围判断
15. `advanced/01` 慢查询定位与调优思路
16. `advanced/02` Online DDL：ALGORITHM 和 LOCK
17. `advanced/03` COUNT(*) 优化
18. `advanced/04` SHOW PROCESSLIST / Performance Schema 排查连接问题
19. `advanced/05` JSON 类型的索引方式（生成列 + 索引）
20. `advanced/06` 分区表：适用场景与注意事项
21. `advanced/07` binlog 格式与用途：point-in-time 恢复
22. `advanced/08` 主从复制延迟的最小可复现 demo

## 下一批值得补的案例

目前列表是空的——想到新坑再往这儿加。上一批的 binlog/复制延迟两个案例原本
因为环境限制（见下面"这两个案例怎么做出来的"）卡住过，后来直接动了
`docker-compose.yml`（加了 `tools/mysqlbinlog/` 镜像和 `mysql-replica` 服务）
才解决，都已经在 [`advanced/07-binlog-recovery`](advanced/07-binlog-recovery/)
和 [`advanced/08-replication-lag`](advanced/08-replication-lag/) 里做完了。

### 这两个案例怎么做出来的（备查）

- **`mysqlbinlog`**：`mysql-lab` 用的官方 `mysql:8.4` 镜像在 arm64（Apple
  Silicon）上是 Oracle Linux 的 `server-minimal` 包，不带这个工具；查证过
  MySQL 官方 yum/apt 仓库都没发布 arm64 版的客户端工具包，`mysqlbinlog`
  只存在于 amd64 构建里，还是打包在"服务器"包（`mysql-community-server-core`）
  里而不是客户端包。解法是 `tools/mysqlbinlog/Dockerfile`：一个强制
  `--platform=linux/amd64` 的 Debian 镜像，靠 Docker Desktop 的 x86 模拟器跑，
  在 `docker-compose.yml` 里用 `profiles: ["tools"]` 隔离，不占默认资源。
- **从库**：`docker-compose.yml` 加了 `mysql-replica` 服务，同样用
  `profiles: ["replica"]` 隔离。**踩过的坑**：造这个 demo 时手滑跑了一次裸的
  `docker compose down`，以为 `--profile replica` 会限定只删从库，结果把
  整个项目（包括主库 `mysql`）都停掉重建了——`down` 不认 `--profile`/服务名
  这种缩小范围的参数，会把项目里所有服务都算进去。数据本身没丢（卷没删），
  但这是个值得记住的教训：删单个服务用 `docker compose rm -sf <service>`，
  永远别在这个项目目录下跑不带参数的 `docker compose down`。

## 新增一个案例的步骤

1. 在对应难度目录下新建编号子目录（`beginner/06-xxx`、`intermediate/05-xxx` ...）。
2. 写 `README.md`，至少包含"你会学到什么 / 原理 / 复现 / 结论"四段（可按需增减，
   参考已有 demo 的写法）。
3. 写配套的 `.sql` 文件，能直接用 `../../client.sh < xxx.sql` 跑通。
4. 在该难度目录的 `README.md` 表格里加一行。
5. 在根目录 [`PITFALLS.md`](PITFALLS.md) 里加一行一句话简述。
6. 如果这份路线图里列了这个案例，把它从待办列表挪掉。
