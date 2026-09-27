# Advanced

| # | 主题 | 你会学到什么 |
|---|------|--------------|
| 01 | [慢查询定位与调优思路](01-slow-query-tuning/) | 慢查询日志 + EXPLAIN ANALYZE 的调优闭环，以及优化器为何会放弃一个能用的索引 |
| 02 | [Online DDL：ALGORITHM 和 LOCK](02-online-ddl/) | INSTANT/INPLACE/COPY 三种算法在 200 万行表上的耗时和并发写入影响实测对比 |
| 03 | [COUNT(*) 优化](03-count-star/) | InnoDB 没有现成的总行数，COUNT(*) 是扫描；近似值和维护计数表两种绕开全表扫描的思路 |
| 04 | [SHOW PROCESSLIST / Performance Schema 排查连接问题](04-connection-troubleshooting/) | 区分"空闲连接"和"空闲且有未提交事务的连接"；Too many connections 时 root 为什么还能连进去 |
| 05 | [JSON 类型的索引方式（生成列 + 索引）](05-json-generated-column-index/) | JSON 列不能直接建索引，靠生成列抽出字段再建索引；写法不同（表达式 vs 生成列名）执行计划也不同 |
