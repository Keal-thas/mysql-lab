# mysql-lab 仪表盘

## 面板入口

- [Adminer 网页 SQL 客户端](http://127.0.0.1:13380/?server=mysql&username=root)
  —— 密码 `root`
- [Dozzle 容器日志](http://127.0.0.1:13381)
- [ROADMAP：学习顺序 + 待补的案例](ROADMAP.md)
- [PITFALLS：案例索引](PITFALLS.md)
- [Starlight 版文档（对比用）](http://127.0.0.1:13383) —— 同一批 md，
  换一套渲染方案看效果，不是正式用的那个

## 当前 TODO

- [ ] 对比完 Starlight 和 MkDocs Material，定下用哪个之后，把没选中的那个从
      `docker-compose.yml` 里删掉（现在两个同时占着资源）

## 已完成

- [x] 端口统一挪到 `133xx` 段（mysql `13306`、adminer `13380`、
      dozzle `13381`、docs `13382`），避免跟别的项目冲突
- [x] root 账号改成有密码（`root`/`root`），解决 Adminer 拒绝空密码登录
- [x] 导入官方 `employees` 示例库（`./seed-employees.sh`），有真实体量数据
- [x] `CURRICULUM.md`/`PROGRESS.md` 合并成一份 `ROADMAP.md`
- [x] 文档面板从 docsify 换成 MkDocs Material（搜索、深浅色切换、
      Mermaid 官方支持，`mkdocs.yml` 里配置）
- [x] `mkdocs.yml` 的 `nav` 改成自动生成（只手动钉住首页），新增 demo 不用再
      改配置
- [x] 验证慢查询日志（`mysql.slow_log` 里能查到）和 binlog（`SHOW BINARY
      LOGS` 有文件）都确实生效
- [x] 新增 `intermediate/05-mvcc-read-view`：REPEATABLE READ vs READ
      COMMITTED 下 Read View 生成时机的对比 demo（ROADMAP 高优先级案例之一）
- [x] 新增 `intermediate/06-isolation-levels`：脏读（READ UNCOMMITTED）和
      幻读（READ COMMITTED vs REPEATABLE READ）的实测对比（ROADMAP 高优先级
      案例之一）
- [x] 新增 `intermediate/07-next-key-lock-ranges`：等值命中/未命中/开区间三种
      `WHERE` 条件各自锁住哪个间隙的实测对比（ROADMAP 高优先级案例之一）
- [x] 新增 `beginner/06-covering-index`：同一张表用四种 SELECT/WHERE 组合，
      对比 `Using index` 和 `Using index condition` 的区别（ROADMAP 高优先级
      案例之一）
- [x] 新增 `advanced/02-online-ddl`：200 万行表上实测 INSTANT/INPLACE/COPY
      三种 ALTER 算法的耗时和并发写入影响（ROADMAP 高优先级案例最后一项，
      至此高优先级 backlog 全部完成）
- [x] 新增 `advanced/03-count-star`：实测 COUNT(*) 在 InnoDB 上是真扫描，
      对比近似值（information_schema.tables）和触发器维护计数表两种方案
- [x] 新增 `advanced/04-connection-troubleshooting`：联查 Performance Schema
      找出"空闲且有未提交事务"的连接；脚本实测 Too many connections + root
      管理员预留连接
- [x] 新增 `advanced/05-json-generated-column-index`：JSON 字段用 STORED
      生成列 + 索引，实测无索引/表达式命中索引/生成列名命中覆盖索引三种耗时
- [x] 新增 `advanced/06-partitioning`：实测分区裁剪何时生效/失效，以及
      DROP PARTITION 比同量级 DELETE 快一到两个数量级
- [x] 新增 `advanced/07-binlog-recovery`：一键脚本演示"全量备份 + binlog
      精确恢复到事故发生前一刻"的完整流程。为此往 `docker-compose.yml`
      加了 `tools/mysqlbinlog/`（arm64 上官方镜像不带这个工具，见该目录
      Dockerfile 的注释）
- [x] 新增 `advanced/08-replication-lag`：从零搭从库，实测 200 万行写入
      造成的复制延迟和追平过程。往 `docker-compose.yml` 加了 `mysql-replica`
      服务（`profiles: ["replica"]`，不随默认 `up -d` 启动）
- [x] ROADMAP 里原本因环境限制卡住的两个案例（binlog/复制延迟）都做完了，
      待办列表清空
- [x] 新增 `beginner/07-numeric-precision-pitfalls`：长数字/长字符串"看起来
      不一样、比出来却一样"的四种原因（FLOAT/DOUBLE 精度丢失、INT/VARCHAR
      超范围截断、VARCHAR 不加引号查询触发隐式转换），来自和用户对话时的
      真实疑惑，逐一实测复现

## 怎么用这个仓库

- [完整 README](README.md)
- 各难度目录：[beginner](beginner/README.md) ·
  [intermediate](intermediate/README.md) · [advanced](advanced/README.md)
