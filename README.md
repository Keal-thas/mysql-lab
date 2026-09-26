# mysql-lab

从真实场景出发学 MySQL 的动手实验室：每个主题都是一个可以实际跑起来的 demo，
而不只是一段结论。按难度分为初级 / 中级 / 高级。

## 环境（Docker）

需要本机装好 Docker（含 Compose）。

```bash
./start.sh    # 启动 MySQL 8.4 容器，并等到它就绪
./client.sh   # 打开交互式 mysql 客户端（root，无密码）
./stop.sh     # 停止容器（保留数据）
./reset.sh    # 停止容器并清空数据，恢复到干净状态
```

连接信息：host `127.0.0.1`，port `3306`，user `root`，无密码。

## 怎么用这个仓库

每个 demo 都在自己的目录下，包含一个 `README.md`（讲清楚要学什么、怎么跑、为什么
会这样）和对应的 `.sql` 文件。跟着 README 用 client 跑：

```bash
./client.sh < beginner/01-order-by-tie-order/demo.sql
```

有些 demo（比如死锁、间隙锁）需要开两个甚至三个独立的 client 会话，对应 README
会写清楚。

想快速扫一眼有哪些坑、每个坑一句话是什么，看 [`PITFALLS.md`](PITFALLS.md)。

## 目录

- [`beginner/`](beginner/README.md) —— 基础概念里容易被忽略的坑
- [`intermediate/`](intermediate/README.md) —— 事务、锁、并发
- [`advanced/`](advanced/README.md) —— 生产向：调优、诊断

新增主题时，在对应难度目录下建一个编号子目录，放 `README.md` + `.sql`，再在该
目录的 `README.md` 表格和根目录的 [`PITFALLS.md`](PITFALLS.md) 里各加一行。
