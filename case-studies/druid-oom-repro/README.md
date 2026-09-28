# Druid 1.1.14 + Spring Boot 1.5.9 + Tomcat 8.5.x：数据库不可用时 getConnection 挂死复现

目标：复现 "DB OOM / 数据库不可达时，业务线程 `getConnection()` 卡住不动，最后表现为超时" 这一生产现象，
并在**不改任何配置（用官方默认值）**的前提下，搞清楚：

1. `getConnection()` 挂起时到底在等什么、等多久、有没有重试
2. Tomcat/HTTP 那一侧有没有执行超时、连接数上限是多少

## 环境

- Spring Boot **1.5.9.RELEASE**（内嵌 Tomcat **8.5.23**）
- Druid **1.1.14**
- mysql-connector-java **5.1.44**（Spring Boot 1.5.9 parent BOM 锁定的版本）
- 后端 DB：复用 `mysql-lab` 的 MySQL 8.4 容器（`mysql-lab_default` 网络）
- `application.yml` 只给了 `url/username/password/driver-class-name`，**没有设置任何 druid.* 超时/重试参数**，也没有覆盖任何 `server.tomcat.*`，全部走默认值

工程目录：`case-studies/druid-oom-repro`（本仓库内的独立子项目，不影响 beginner/intermediate/advanced 里的教程内容）。

> 注：`druid.password: root` 只是本仓库 `docker-compose.yml` 里跑着玩的本地测试库密码，不对应任何真实/线上环境，
> 公开也没有风险——如果你是在自己环境复现，请换成自己的数据库口令。

本仓库验证了两种配置场景，`src/main/resources/application.yml` 里当前保留的是"场景二"：

- **场景一：`maxWait` 完全不配置（-1，默认值）**——见结论 1
- **场景二：显式 `druid.maxWait=60000`**——见结论 1.5，这是本仓库当前的配置，也是用户在生产上遇到的实际配置

## 复现方式（真实故障，不是我手工模拟的）

老驱动 mysql-connector-java 5.1.44 不认识 MySQL 8.x 默认的 `caching_sha2_password` 认证插件，
每次建立物理连接都会失败：

```
java.sql.SQLException: Unable to load authentication plugin 'caching_sha2_password'.
    at com.mysql.jdbc.MysqlIO.proceedHandshakeWithPluggableAuthentication(MysqlIO.java:1746)
    ...
    at com.alibaba.druid.pool.DruidDataSource$CreateConnectionThread.run(DruidDataSource.java:2570)
```

这恰好就是生产上 "DB 端出问题（这里是认证握手失败，OOM 场景是 TCP 层无响应/建连失败）导致物理连接建不起来"
的一个天然、可稳定复现的等价场景 —— **对连接池来说，"建连失败" 和 "建连挂住不返回" 触发的是同一套重试/等待逻辑**，
区别只在于失败得快还是慢。所以这个环境非常适合验证默认的等待/重试语义。

## 结论 1：`getConnection()` 默认配置下会不会超时？—— 不会，默认是"无限等"

请求 `/query`（内部执行 `dataSource.getConnection()`）后线程栈：

```
"http-nio-8080-exec-2" ... WAITING (parking)
    at sun.misc.Unsafe.park(Native Method)
    - parking to wait for <0x00000000c393f300> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
    at java.util.concurrent.locks.LockSupport.park(LockSupport.java:175)
    at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:2039)
    at com.alibaba.druid.pool.DruidDataSource.takeLast(DruidDataSource.java:2002)
    at com.alibaba.druid.pool.DruidDataSource.getConnectionInternal(DruidDataSource.java:1539)
    at com.alibaba.druid.pool.DruidDataSource.getConnectionDirect(DruidDataSource.java:1326)
    at com.alibaba.druid.pool.DruidDataSource.getConnection(DruidDataSource.java:1306)
    at com.repro.druidoom.DbController.query(DbController.java:24)
```

`await()` 是**不带超时参数的**版本，也就是说这个线程会一直 park 下去，直到有连接归还或被打断，**不会自己醒来抛异常**。
挂了 20+ 分钟（本次实测），线程状态纹丝不动。

访问 `/pool` 拿到的默认值印证了这一点：

```
maxActive=8, minIdle=0, initialSize=0, maxWait=-1, activeCount=0, poolingCount=0,
waitThreadCount=21, connectionErrorRetryAttempts=1, timeBetweenConnectErrorMillis=500, createErrorCount=212
```

### 原理（DruidDataSource / DruidAbstractDataSource 源码）

- `maxWait` 默认值是 **`-1`**（`DruidAbstractDataSource.DEFAULT_MAX_WAIT = -1`）。
- 在 `getConnectionInternal()` 里，只有 `maxWait > 0` 时才会走 `notEmpty.awaitNanos(estimate)` 这种带超时的等待，
  超时后抛 `GetConnectionTimeoutException`（形如 `wait millis 5000, active 8, maxActive 8`）。
- 当 `maxWait <= 0`（默认就是这种情况）时，走的是 `empty.await()`（`DruidDataSource.java:2002` 附近的 `takeLast()`），
  **没有超时参数，永久等待**，除非：
  - 有连接被归还 / 新建成功，`notEmpty.signal()` 唤醒它；或
  - 线程被 `interrupt()`；或
  - 调用方自己在业务代码里包了 `Future.get(timeout)` / 线程池自带的超时熔断。
- 所以你线上遇到的 "getConnection 超时" 有两种可能，必须先分清楚是哪一种：
  1. **确实配置过 `druid.maxWait`**（比如 spring-boot-starter-druid、或者运维模板里默认给了 60000ms），到点抛
     `GetConnectionTimeoutException`；
  2. **就是默认 -1，压根没有 druid 层面超时**，你看到的"超时"其实是上游/网关/HTTP 客户端自己的读超时把连接掐断了
     （比如 Nginx `proxy_read_timeout`、RPC 客户端超时、前端 axios timeout），Tomcat worker 线程在服务端仍然是**卡死状态**，
     并不会因为客户端断开而释放 —— 见下面"结论 3"的线程泄漏现象。

### 重试逻辑

物理连接创建失败时（`DruidAbstractDataSource.createPhysicalConnection`），Druid 在
`DruidDataSource$CreateConnectionThread`（独立的后台线程，不是业务线程本身）里做的事：

- 每次失败会自增 `createErrorCount`（本次实测 4 秒内飙到 212，说明重试非常频繁）
- 失败后按 `timeBetweenConnectErrorMillis`（默认 **500ms**）等待后重试
- `connectionErrorRetryAttempts` 默认 **1**：超过该次数且 `breakAfterAcquireFailure`（默认 **false**）为 false 时，
  不会放弃，会继续按上面的间隔无限重试下去
- 业务线程（`http-nio-8080-exec-*`）自己并不参与重试探测，它只是在 `empty.await()` 上等 `CreateConnectionThread`
  什么时候建连成功后 `signal` 它

一句话总结：**默认配置下，Druid 会以 500ms 间隔无限次重试建连，业务线程无限等待，没有任何超时兜底。**

## 结论 1.5：配置了 `maxWait=60000` 之后，实测是多久？—— 约 120 秒，是配置值的 2 倍

把 `application.yml` 改成显式 `druid.maxWait=60000`（其余不变，仍然连着同一个认证握手失败的 DB）重跑：

```
ERROR after 120073ms: com.alibaba.druid.pool.GetConnectionTimeoutException: wait millis 60000, active 0, maxActive 8, creating 0, createErrorCount 238
ERROR after 120015ms: com.alibaba.druid.pool.GetConnectionTimeoutException: wait millis 60001, active 0, maxActive 8, creating 0, createErrorCount 555
```

两次独立测试都是 ~120s，不是偶发抖动。异常信息里的 `wait millis 60000/60001` 是 Druid **自己记录的最后一段等待耗时**（`pollLast`
那一次 `awaitNanos` 的时长），不是整个 `getConnection()` 调用的总耗时——从 `DbController` 里我们自己计时的结果看，
调用方实际感知到的耗时是它的 2 倍。

栈顶确认了这一次是走的**有超时的路径**（区别于结论1里 `maxWait=-1` 时的 `takeLast`）：

```
"http-nio-8080-exec-1" ... TIMED_WAITING (parking)
    at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:2078)
    at com.alibaba.druid.pool.DruidDataSource.pollLast(DruidDataSource.java:2049)
    at com.alibaba.druid.pool.DruidDataSource.getConnectionInternal(DruidDataSource.java:1537)
```

**原因**：`getConnectionInternal()` 在真正进入 `pollLast(maxWait)` 之前，`DruidAbstractDataSource` 会先做一次
**同步的 `createDirectly` 首次建连尝试**（第一次拿连接、池子还是空的时候会走这条路）。这次同步尝试本身也会按
`connectionErrorRetryAttempts`/`timeBetweenConnectErrorMillis` 重试并阻塞，而它的阻塞时长**不计入** `maxWait` 的配额；
真正基于 `maxWait` 的限时等待（`pollLast`）是在这次同步尝试彻底失败之后才开始计时的。两段时间叠加，
就出现了"配置 60s，实际等了 120s"的现象。

**这对生产的意义非常直接**：如果你的 SLA/超时链路是按 `druid.maxWait` 的配置值去反推的（比如网关超时设了比
`maxWait` 稍大一点，指望 Druid 先超时、由它来"兜底"），这个假设在 Druid 1.1.14 上是不成立的——实际等待时间
可能是配置值的 2 倍，你的网关/RPC 客户端会先于 Druid 超时熔断，导致 "客户端已经报错" 但服务端线程还在按
Druid 自己的时间表继续等，进一步加重结论3里说的线程泄漏问题。

## 结论 2：默认参数一览（Druid 1.1.14）

| 参数 | 默认值 | 含义 |
|---|---|---|
| `initialSize` | 0 | 启动不预建连接 |
| `maxActive` | 8 | 最大连接数很小，生产环境常见的坑 |
| `minIdle` | 0 | 不保留空闲连接 |
| `maxWait` | **-1**（无限等待） | 拿不到连接就一直等，不抛超时异常 |
| `connectionErrorRetryAttempts` | 1 | 建连失败重试门槛 |
| `timeBetweenConnectErrorMillis` | 500ms | 重试间隔 |
| `breakAfterAcquireFailure` | false | 失败后不放弃，继续无限重试 |
| `testOnBorrow` | false | 默认不校验，但本例是建连阶段失败，不受此影响 |
| `removeAbandoned` | false | 默认不会强制收回泄漏连接 |

## 结论 3：HTTP / Tomcat 那一侧怎么样？

同时发 20 个并发请求（DB 仍然故障）：

```
000 time=4.001420
000 time=4.001595
... (20 行全部 000，说明连接被 TCP 接受了，只是客户端自己 --max-time 4 超时断开，不是服务端拒绝)
```

客户端全部主动放弃后再查 `/pool`：

```
waitThreadCount=21
```

以及容器内线程数：

```
/proc/1/task 下有 54 个线程（启动时基线约 30 出头）
```

说明：**客户端断开连接，完全不会打断服务端正在 `getConnection()` 里 park 着的 Tomcat 工作线程**——
这些线程会一直占着，直到 DB 恢复或进程重启。这是比 "单次请求超时" 更危险的次生问题：**线程泄漏**。

### 默认值（不是查文档，是从跑起来的 Connector 对象里读出来的实际值）

加了一个 `TomcatConnectorLogger`，在内嵌 Tomcat 启动后直接读 `AbstractHttp11Protocol` 的字段打印出来，
启动日志里能看到：

```
### TOMCAT CONNECTOR DEFAULTS ### maxThreads=200, minSpareThreads=10, acceptCount=100, connectionTimeout=60000, maxConnections=10000
```

也就是说 Spring Boot 1.5.9 内嵌的 Tomcat 8.5.23，在完全不配置 `server.tomcat.*` 的情况下：

- `maxThreads`：**200**（最大工作线程数，也就是最多能有 200 个请求同时被业务代码处理）
- `acceptCount`：**100**（这只是内核 `listen()` backlog 大小，管的是"握手完成到 Tomcat 调用 `accept()`"这一瞬间的缓冲，不是线程排队队列——见下面"机制验证"里纠正过的结论）
- `minSpareThreads`：10
- `connectionTimeout`：**60000ms**（60s）—— 这个超时管的是"连接建立后、读到完整请求头/请求体的时间"，**不是**请求处理（Servlet 执行）的超时
- `maxConnections`：**10000**——这是 NIO Poller 能同时"握着"的 socket 数上限（远大于 maxThreads），意味着 Tomcat 可以接受远多于 200 个连接，但同一时刻只有 200 个能真正被派发到工作线程去跑业务代码，其余的连接是建立了但排着队、没人处理
- Tomcat（乃至整个 Servlet 容器规范）**默认没有"处理超时"这个概念**：一旦请求进了某个 worker 线程，
  这个线程可以永远执行下去，容器不会主动打断它。

### 机制验证：worker 线程数是不是真的被卡死在 maxThreads

200 个线程量级不方便在本地一次性打满做实验，所以用环境变量把
`SERVER_TOMCAT_MAX_THREADS=4`、`SERVER_TOMCAT_ACCEPT_COUNT=2`（机制等价，只是数字调小方便复现）跑了一遍：
启动日志确认生效（`maxThreads=4, acceptCount=2`），然后同时发 10 个会挂住的 `/query` 请求（`maxWait` 临时调到
10 分钟避免测试过程中自己超时跑完），3 秒后抓线程栈：

```
"http-nio-8080-exec-4" ... waiting on condition
"http-nio-8080-exec-3" ... waiting on condition
"http-nio-8080-exec-2" ... waiting on condition
"http-nio-8080-exec-1" ... waiting on condition
```

**只有 4 个 `http-nio-8080-exec-*` 线程存在**，跟配置的 `maxThreads=4` 精确对应，即使同时来了 10 个请求，
容器也不会为超出 `maxThreads` 的请求额外开线程——多出来的 6 个请求全部还在排队，一个都没有被真正执行。
这就是"默认 200 个线程一旦被 DB 故障全部占满，第 201 个请求开始就再也没有线程处理"的直接证据。

最初以为"超过 `maxThreads+acceptCount`（本例是 4+2=6）就会被拒绝/RST"，加测之后发现这个理解是错的，
下面是纠正后的结论。

### 排队等线程的连接，会不会占用文件描述符（fd）？—— 会，而且比想象中撑得住更多

同样 `maxThreads=4, acceptCount=2` 的配置下，这次直接发 **15 个**（远超"4+2=6"的假想上限）会挂住的请求，
对比发请求前后容器的 fd 数：

```
baseline fd count: 28
15 个并发请求 3 秒后: 43        # 整整多了 15 个，一个都没被拒绝
```

`ls -la /proc/1/fd` 能看到新增的都是 `socket:[...]`，说明这 15 个连接全部被 Tomcat 的 Acceptor 线程
`accept()` 了，每个都拿到了一个真实的 fd；而线程栈里 `http-nio-8080-exec-*` 依然只有 4 个——**连接被接受
和请求被执行是两件事，前者由 `maxConnections` 控制，后者才由 `maxThreads` 控制**。

这就纠正了前面"超过 acceptCount 就会拒绝"的说法。真实的分层是：

| 层级 | 谁控制 | 默认值 | 占不占 fd |
|---|---|---|---|
| 内核 SYN 队列（三次握手还没走完） | OS `listen()` backlog，即 Tomcat 的 `acceptCount` | 100 | 不占（内核态，还没 `accept()`） |
| 已 `accept()`、在 Poller 里排队等 worker 线程 | `maxConnections` | **10000** | **占**（一个 socket fd） |
| 真正在跑业务代码 | `maxThreads` | 200 | 占（还额外占一份线程栈内存） |

`acceptCount` 只是"握手完成到 Tomcat 应用层调用 `accept()`"这极短暂过程的内核缓冲区，Tomcat 的 Acceptor
是独立于 `maxThreads` 的一个线程，会一直 `accept()` 到 `maxConnections`（默认 **10000**）才停。也就是说
**线上 DB 故障时，真正会把新连接直接拒掉的边界是 `maxConnections=10000`，不是 `maxThreads+acceptCount`**——
在到 10000 之前，新连接都能连上、都会占一个 fd，只是分不到线程干活，纯排队挂着。这也是本来想验证
"超过 acceptCount 就会 connection refused" 却怎么都验证不出来的真正原因，不是本机 Docker 网络的锅。

### 附带发现：不碰数据库的接口也会被一起拖死

线程被打满期间，顺手测了一下完全不碰 `getConnection()` 的 `/pool` 接口：

```
curl --max-time 2 http://localhost:18080/pool   # 直接拿不到任何响应
```

因为 `/pool` 一样要占用一个 Tomcat 工作线程，而 4 个线程全被卡在 `/query` 的 `getConnection()` 里出不来，
`/pool` 只能在队列里排着。**"全站假死"不是夸张的比喻**：同一个 Tomcat 线程池一旦被某个依赖坏掉的接口占满，
这个进程里所有 HTTP 接口都会被拖死，跟接口本身碰不碰那个坏掉的 DB 完全无关。

### 所以级联失败的路径是这样的

```
DB 故障
  → 每次 getConnection() 都在 500ms 重试的背景下无限等待（默认 maxWait=-1）
  → 每个落到这个接口上的 HTTP 请求都会占用一个 Tomcat worker 线程且永不释放
  → 请求持续进来，200 个 maxThreads 很快用完，新连接照样能连上（占一个 fd），只是分不到线程干活，纯排队
  → 不碰这个坏 DB 的其它接口，因为抢不到工作线程，也会被一起拖死（"全站假死"）
  → 排队的连接数一路涨到 maxConnections=10000 之后，新连接才会被直接拒绝/RST
```

这也是为什么生产上一次"DB OOM 秒级抖动"经常被放大成"整个 Java 服务不可用几分钟甚至更久"——
罪魁祸首往往不是 DB 故障本身的时长，而是 **Druid 默认无限等待 + Tomcat 线程不会被打断** 这两个默认值叠加的结果。

## 怎么验证你线上到底是哪种情况

1. 线上报警时抓一次 `jstack`（或 `kill -3` 打到 GC 日志/stdout），搜 `takeLast` 还是 `awaitNanos`：
   - 停在 `takeLast` → `maxWait` 就是 -1（或未配置），无限等待
   - 停在 `awaitNanos` 或者日志里直接有 `GetConnectionTimeoutException: wait millis xxx` → 说明配置过 `maxWait`，是它生效超时了
2. 看 Druid 监控（`druid-stat` / Spring Boot Actuator 里的 DruidDataSource MBean，或者本仓库 `/pool` 这种简易端点）里的
   `waitThreadCount` 和 `createErrorCount` 是否在故障期间持续升高 —— 升高就说明确实是"物理连接建不起来 + 无限重试"这条路径
3. 查当时的 Tomcat 线程数 / `netstat` 连接数是否顶到 `maxThreads`/`acceptCount`，判断是否已经发生了线程泄漏式的级联

## 本仓库如何复现

```bash
cd case-studies/druid-oom-repro
# 1. 编译（本机没装 Maven，用容器编译）
docker run --rm -v "$PWD":/app -v maven-repo-cache:/root/.m2 -w /app \
  maven:3-eclipse-temurin-8 mvn -q -DskipTests package

# 2. 跑起来，接到 mysql-lab 的网络上（老驱动天然认证不了 MySQL 8.4，直接复现"建连失败+无限重试"）
docker run -d --name druid-oom-app --network mysql-lab_default -p 18080:8080 \
  -v "$PWD/target/app.jar":/app.jar eclipse-temurin:8-jre java -jar /app.jar

# 3. 观察
curl http://localhost:18080/pool     # 看默认参数 + 实时等待/重试计数
curl http://localhost:18080/query    # 这个会一直挂住，Ctrl+C 只会中断客户端，服务端线程不会释放

# 4. 抓线程栈证据
docker exec druid-oom-app kill -3 1
docker logs druid-oom-app | grep -A 20 'http-nio-8080-exec'

# 5.（可选）验证 Tomcat worker 线程数确实被硬性封顶在 max-threads，
#    用环境变量把默认的 200/100 缩小成 4/2，方便在本地几秒内打满：
docker rm -f druid-oom-app
docker run -d --name druid-oom-app --network mysql-lab_default -p 18080:8080 \
  -e SERVER_TOMCAT_MAX_THREADS=4 -e SERVER_TOMCAT_ACCEPT_COUNT=2 \
  -e SERVER_TOMCAT_MIN_SPARE_THREADS=1 -e DRUID_MAXWAIT=600000 \
  -v "$PWD/target/app.jar":/app.jar eclipse-temurin:8-jre java -jar /app.jar
for i in $(seq 1 10); do curl -s -o /dev/null http://localhost:18080/query & done
sleep 3
docker exec druid-oom-app kill -3 1
docker logs druid-oom-app | grep -c 'http-nio-8080-exec.*"'   # 应该恒等于 max-threads 的值，不会更多
```

清理：`docker rm -f druid-oom-app`（不影响 `mysql-lab` 本身任何容器，全程只读访问了它的网络）。
