# mysql-lab

从真实场景出发学 MySQL 的动手实验室：每个主题都是一个可以实际跑起来的 demo，
而不只是一段结论。按难度分为初级 / 中级 / 高级。

## 环境（Docker）

需要本机装好 Docker（含 Compose）。

```bash
./start.sh    # 启动 MySQL 8.4 容器，并等到它就绪
./client.sh   # 打开交互式 mysql 客户端（root/root）
./stop.sh     # 停止容器（保留数据）
./reset.sh    # 停止容器并清空数据，恢复到干净状态
```

连接信息：host `127.0.0.1`，port `13306`，user `root`，password `root`。这个
项目的所有本机端口都用 `133xx` 段，避免跟你机器上其他项目/服务（比如常见的
`3306`）冲突。密码之所以不是空的，是因为 Adminer 6.x 默认拒绝空密码账号登录。

`start.sh` 同时会拉起两个只在本机可访问的辅助面板：

- **Adminer**（网页版 SQL 客户端）：http://127.0.0.1:13380 —— System 选
  MySQL，Server 填 `mysql`（compose 里的服务名，不是 `127.0.0.1`），用户名
  `root`，密码 `root`。可以直接在浏览器里跑任意 SQL、浏览表数据，不用开
  `client.sh`。
- **Dozzle**（网页看容器日志）：http://127.0.0.1:13381 —— 实时看 `mysql-lab`
  容器（以及本机其他容器）的日志，不用 `docker exec` 进容器或敲 `docker logs`。

## 怎么用这个仓库

每个 demo 都在自己的目录下，包含一个 `README.md`（讲清楚要学什么、怎么跑、为什么
会这样）和对应的 `.sql` 文件。跟着 README 用 client 跑：

```bash
./client.sh < beginner/01-order-by-tie-order/demo.sql
```

有些 demo（比如死锁、间隙锁）需要开两个甚至三个独立的 client 会话，对应 README
会写清楚。

想快速扫一眼有哪些坑、每个坑一句话是什么，看 [`PITFALLS.md`](PITFALLS.md)。
想知道学习顺序和接下来打算补哪些坑，看 [`ROADMAP.md`](ROADMAP.md)。

## 目录

- [`beginner/`](beginner/README.md) —— 基础概念里容易被忽略的坑
- [`intermediate/`](intermediate/README.md) —— 事务、锁、并发
- [`advanced/`](advanced/README.md) —— 生产向：调优、诊断

新增主题时，按 [`ROADMAP.md`](ROADMAP.md) 里"新增一个坑的步骤"来做：在对应难度
目录下建一个编号子目录，放 `README.md` + `.sql`，再在该目录的 `README.md` 表格、
根目录的 [`PITFALLS.md`](PITFALLS.md) 和 `ROADMAP.md` 里各加一行。
