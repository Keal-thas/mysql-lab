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

## 怎么用这个仓库

- [完整 README](README.md)
- 各难度目录：[beginner](beginner/README.md) ·
  [intermediate](intermediate/README.md) · [advanced](advanced/README.md)
