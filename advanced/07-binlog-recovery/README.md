# binlog 格式与用途：point-in-time 恢复

## 你会学到什么

"跑了一条没带 `WHERE` 的 `DELETE`，数据全没了"是每个人迟早会遇到的事故。这个
demo 走一遍完整的恢复流程：定期备份 + binlog，能把数据库精确恢复到"事故发生
前一刻"，而不只是恢复到"最近一次备份"那个更早的时间点。

## 环境准备：这个 demo 需要单独的 mysqlbinlog 工具镜像

`mysql-lab` 主服务用的官方 `mysql:8.4` 镜像，在 Apple Silicon（arm64）上是基于
Oracle Linux 的 `server-minimal` 包，**不带 `mysqlbinlog` 这个命令行工具**——
查证过 MySQL 官方的 yum/apt 仓库，arm64 架构下也都没有发布任何客户端工具包，
`mysqlbinlog` 只存在于 amd64 构建里（而且是打包在"服务器"包
`mysql-community-server-core` 里，不是"客户端"包，直觉上容易找错地方）。

所以仓库里加了一个专门的 `tools/mysqlbinlog/` 镜像，强制用
`--platform=linux/amd64` 跑（细节和踩坑过程见该 Dockerfile 里的注释），靠
Docker Desktop 自带的 x86 模拟器执行。这个服务在 `docker-compose.yml` 里用
`profiles: ["tools"]` 隔离，不会随 `docker compose up -d` 自动启动，只在需要时
按需跑一次：

```bash
docker compose run --rm binlog-tools mysqlbinlog ...
```

## 原理

- MySQL 的 binlog 有三种格式（`binlog_format`）：
  - `STATEMENT`：记录原始 SQL 语句本身。日志小，但 `NOW()`、`RAND()` 这类
    非确定性函数在主备之间可能算出不同结果，有数据不一致的风险。
  - `ROW`（本仓库 `mysql` 服务的默认值）：记录每一行实际变化前后的值，不管
    SQL 长什么样，结果都是确定的，代价是日志体积通常比 `STATEMENT` 大。
  - `MIXED`：默认按语句记录，遇到不安全的语句自动切成按行记录，两头兼顾。
- 恢复到任意时间点的核心思路：**全量备份 + 备份之后的 binlog** 组合起来，
  相当于"备份那一刻的完整状态" + "之后发生的每一个变更"，只要精确知道事故
  语句在 binlog 里的位置，就能只重放"备份之后、事故之前"这一段，把事故语句
  本身排除在外。
- `mysqlbinlog --start-position=X --stop-position=Y` 就是干这件事的工具：
  从 binlog 文件里截取 `[X, Y)` 这个位置区间，解码成可以直接喂给 `mysql`
  客户端重放的 SQL/BINLOG 语句。

## 复现

准备数据：

```bash
../../client.sh < setup.sql
```

一键跑完整个"备份 → 好的修改 → 事故 → 恢复"流程：

```bash
./recover.sh
```

脚本依次做这几件事（每一步都会打印在做什么）：

1. 用 `FLUSH TABLES WITH READ LOCK` 拿到一个一致性快照点，记下这一刻的
   binlog 文件名和位置，再用 `mysqldump` 做全量备份，之后立刻 `UNLOCK
   TABLES`。
2. 备份之后，插入一行新数据、改一行余额——这些是我们**想保留**的修改，
   记下这批修改结束时的 binlog 位置。
3. 模拟事故：跑一条没有 `WHERE` 的 `DELETE`，表清空。
4. 恢复：先把备份整个倒回去（这一步本身会丢掉步骤 2 那些"好的修改"，因为
   备份是在它们之前拍的）。
5. 用 `mysqlbinlog --start-position=<备份时的位置> --stop-position=<好修改
   结束时的位置>` 精确截取 binlog 里"备份之后、事故之前"这一段，重放到
   数据库——事故那条 `DELETE` 落在截取区间之外，不会被重放。

最终状态：`accounts` 表里 Alice 是 1100.00（备份时 1000 + 事后的 +100）、
Bob 是 500.00（没变过）、Carol 存在（备份之后新插入的）——跟事故发生前一刻
一模一样，`DELETE` 造成的丢失被完全绕开。

## 结论

- 只有"全量备份"是不够的：备份粒度决定了你能恢复到的**最粗**时间点，中间这
  段时间的修改全部丢失；只有配合 binlog 才能恢复到任意精确的时间点。
- 定位"事故发生前一刻"的 binlog 位置是这套流程里最关键、也最容易出错的一步：
  生产上通常靠 `mysqlbinlog` 先把可疑时间段的 binlog 解码成文本（配合
  `--base64-output=DECODE-ROWS -v` 能看到 `ROW` 格式下每一行具体改了什么），
  肉眼或者脚本找到事故语句那一行对应的位置，掐在它之前。
- 这套恢复方式跟"从库"是两回事：从库是持续应用 binlog、保持一个热备份，
  这里演示的是"事后从一份静态备份 + 一段 binlog 重建出某个时间点的状态"，
  两者可以结合使用，但解决的是不同的问题。
