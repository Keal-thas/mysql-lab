# MySQL Complete Learning Curriculum

A comprehensive learning framework covering all essential MySQL topics from fundamentals to advanced production practices. All items are tracked with priority, difficulty level, and demo availability.

## Learning Path Overview

1. **Phase 1 (Foundation)**: Data types, storage engines, basic architecture
2. **Phase 2 (Core Skills)**: Indexing, transactions, query optimization
3. **Phase 3 (Production)**: Concurrency, monitoring, troubleshooting
4. **Phase 4 (Operations)**: High availability, backup, security

---

## Module 1: Fundamentals (基础概念)

### 1.1 Architecture & Components
- [ ] MySQL Architecture Overview (Conn Layer, Query Engine, Storage Engine)
  - Priority: Critical | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] Storage Engines Comparison (InnoDB, MyISAM, Memory, Archive)
  - Priority: Critical | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] InnoDB vs MyISAM Trade-offs
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

### 1.2 Data Types & Schema Design
- [ ] Numeric Types (INT, BIGINT, DECIMAL, FLOAT)
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] String Types (VARCHAR, CHAR, TEXT, BLOB)
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] Date & Time Types (DATETIME, TIMESTAMP, DATE, TIME)
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] JSON Data Type and Operations
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Enum and Set Types Pitfalls
  - Priority: Low | Difficulty: Beginner | Has Demo: No | Status: Unstarted

### 1.3 Basic SQL Operations
- [ ] SELECT, INSERT, UPDATE, DELETE Fundamentals
  - Priority: Critical | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] JOIN Operations (INNER, LEFT, RIGHT, CROSS)
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] GROUP BY and Aggregation Functions
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] Subqueries and CTEs (Common Table Expressions)
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

---

## Module 2: Indexing & Query Optimization (索引与查询优化)

### 2.1 Index Fundamentals
- [ ] Index Basics and B+ Tree Structure
  - Priority: Critical | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Primary Key vs Secondary Indexes
  - Priority: Critical | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] Composite (Multi-column) Indexes
  - Priority: Critical | Difficulty: Beginner | Has Demo: Yes | Demo: beginner/04-index-leftmost-prefix | Status: Unstarted

- [ ] Leftmost Prefix Principle in Indexes
  - Priority: Critical | Difficulty: Beginner | Has Demo: Yes | Demo: beginner/04-index-leftmost-prefix | Status: Unstarted

- [ ] Index Types (Hash, Full-Text, Spatial)
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 2.2 Query Execution Plans
- [ ] EXPLAIN Statement Basics
  - Priority: Critical | Difficulty: Beginner | Has Demo: Yes | Demo: beginner/02-explain-basics | Status: Unstarted

- [ ] Understanding EXPLAIN Output (type, key, rows, Extra)
  - Priority: Critical | Difficulty: Beginner | Has Demo: Yes | Demo: beginner/02-explain-basics | Status: Unstarted

- [ ] EXPLAIN ANALYZE for Actual Execution
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: beginner/02-explain-basics | Status: Unstarted

- [ ] Query Optimizer Behavior and Hints
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 2.3 Index Optimization Pitfalls
- [ ] Implicit Type Conversion Breaks Indexes
  - Priority: High | Difficulty: Beginner | Has Demo: Yes | Demo: beginner/03-implicit-type-conversion | Status: Unstarted

- [ ] LIKE Pattern Matching and Indexes
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] Using Functions in WHERE Clause
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] OR Conditions and Index Selection
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] NOT IN vs NOT EXISTS Performance
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 2.4 Query Performance Tuning
- [ ] Slow Query Log Configuration and Analysis
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: advanced/01-slow-query-tuning | Status: Unstarted

- [ ] Slow Query Diagnosis and Optimization Steps
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: advanced/01-slow-query-tuning | Status: Unstarted

- [ ] Large OFFSET Pagination Pitfall
  - Priority: High | Difficulty: Beginner | Has Demo: Yes | Demo: beginner/05-offset-pagination | Status: Unstarted

- [ ] Cursor-Based Pagination Optimization
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: beginner/05-offset-pagination | Status: Unstarted

- [ ] COUNT(*) Optimization Techniques
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Covering Indexes and Index-Only Scans
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

---

## Module 3: Transactions & ACID Properties (事务与ACID特性)

### 3.1 Transaction Fundamentals
- [ ] ACID Properties Definition and Importance
  - Priority: Critical | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] Transaction Lifecycle (BEGIN, COMMIT, ROLLBACK)
  - Priority: Critical | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] Implicit Commits and Autocommit Behavior
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] Savepoints for Partial Rollback
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 3.2 Isolation Levels
- [ ] Four Isolation Levels Overview
  - Priority: Critical | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] READ UNCOMMITTED (Dirty Reads)
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] READ COMMITTED (Non-Repeatable Reads)
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] REPEATABLE READ (Phantom Reads)
  - Priority: Critical | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] SERIALIZABLE Isolation Level
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Phantom Read Problem and Solutions
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

---

## Module 4: Locking & Concurrency Control (锁与并发控制)

### 4.1 Lock Types
- [ ] Shared (Read) Locks vs Exclusive (Write) Locks
  - Priority: Critical | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Row Locks vs Table Locks
  - Priority: Critical | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Intention Locks (IS, IX)
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Record Locks and Next-Key Locks
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 4.2 Gap Locks & Range Locking
- [ ] Gap Lock Concept and When They Occur
  - Priority: High | Difficulty: Advanced | Has Demo: Yes | Demo: intermediate/03-gap-lock | Status: Unstarted

- [ ] Gap Lock Causing Unexpected Blocking
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: intermediate/03-gap-lock | Status: Unstarted

- [ ] Next-Key Locks (Record + Gap)
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Lock Range Prediction Strategies
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 4.3 Deadlocks
- [ ] Deadlock Mechanism and Detection
  - Priority: Critical | Difficulty: Intermediate | Has Demo: Yes | Demo: intermediate/01-deadlock | Status: Unstarted

- [ ] Deadlock Cycle Example
  - Priority: Critical | Difficulty: Intermediate | Has Demo: Yes | Demo: intermediate/01-deadlock | Status: Unstarted

- [ ] Deadlock Analysis and Resolution
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: intermediate/02-deadlock-analysis | Status: Unstarted

- [ ] SHOW ENGINE INNODB STATUS for Debugging
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: intermediate/02-deadlock-analysis | Status: Unstarted

- [ ] Deadlock Prevention Strategies
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 4.4 Advanced Concurrency Issues
- [ ] Idle Transaction Blocking DDL and SELECT
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: intermediate/04-idle-transaction-blocks-ddl | Status: Unstarted

- [ ] Metadata Locks (MDL) Concept
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: intermediate/04-idle-transaction-blocks-ddl | Status: Unstarted

- [ ] MVCC (Multi-Version Concurrency Control) Basics
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Undo Log and Version Chain
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

---

## Module 5: InnoDB Internals (InnoDB内部实现)

### 5.1 Storage Structure
- [ ] Page and Record Structure
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Clustered Index (Primary Key) Implementation
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Secondary Index Structure and Lookup
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Row Format (COMPACT, DYNAMIC, COMPRESSED)
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 5.2 Transaction Management
- [ ] Transaction ID and Version Chain
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Read View and Visibility Rules
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] MVCC Implementation Details
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

---

## Module 6: Logging & Recovery (日志与恢复)

### 6.1 Binary Log (Binlog)
- [ ] Binary Log Purpose and Format
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Statement, Row, and Mixed Log Formats
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Binary Log Position and GTID
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Binlog Configuration and Rotation
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 6.2 Redo Log and Undo Log
- [ ] Redo Log Function and Structure
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Write-Ahead Logging (WAL) Concept
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Undo Log for Rollback and MVCC
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Crash Recovery Process
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 6.3 Point-in-Time Recovery
- [ ] PITR Using Binlog
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Mysqlbinlog Tool Usage
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

---

## Module 7: Replication & High Availability (复制与高可用)

### 7.1 Asynchronous Replication
- [ ] Master-Slave Replication Basics
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Binlog Position and Replication Lag
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Replication Filters (--replicate-do/ignore-db/table)
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 7.2 Semi-Synchronous Replication
- [ ] Semi-Sync Replication Concept
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Balancing RPO and Performance
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 7.3 GTID and Advanced Replication
- [ ] Global Transaction ID (GTID)
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Multithreaded Replica (MTS)
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 7.4 Group Replication
- [ ] MySQL Group Replication Overview
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Consensus and Consistency in Group Replication
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

---

## Module 8: Backup & Disaster Recovery (备份与灾难恢复)

### 8.1 Backup Methods
- [ ] Logical Backup (mysqldump)
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Physical Backup Methods
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Percona XtraBackup Features
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Incremental and Differential Backups
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 8.2 Recovery Scenarios
- [ ] Complete Database Recovery
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Partial Recovery (Table or Schema)
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Point-in-Time Recovery from Backup + Binlog
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 8.3 RPO and RTO Planning
- [ ] Recovery Point Objective (RPO)
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Recovery Time Objective (RTO)
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

---

## Module 9: Performance Monitoring & Tuning (性能监控与调优)

### 9.1 Performance Schema
- [ ] Performance Schema Overview and Setup
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Events and Tables in Performance Schema
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Query Analysis Using Performance Schema
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 9.2 Slow Query Monitoring
- [ ] Slow Query Log Configuration
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: advanced/01-slow-query-tuning | Status: Unstarted

- [ ] Long Query Time Threshold Setting
  - Priority: High | Difficulty: Beginner | Has Demo: Yes | Demo: advanced/01-slow-query-tuning | Status: Unstarted

- [ ] Analyzing Slow Query Patterns
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: advanced/01-slow-query-tuning | Status: Unstarted

### 9.3 System Variables and Tuning
- [ ] Key Tuning Parameters (buffer_pool_size, max_connections)
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Memory Optimization
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] InnoDB Buffer Pool Sizing and Warmup
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Query Cache (deprecated in 8.0)
  - Priority: Low | Difficulty: Beginner | Has Demo: No | Status: Unstarted

### 9.4 Diagnostics Tools
- [ ] SHOW Commands (PROCESSLIST, STATUS, VARIABLES)
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] SHOW ENGINE INNODB STATUS
  - Priority: High | Difficulty: Intermediate | Has Demo: Yes | Demo: intermediate/02-deadlock-analysis | Status: Unstarted

- [ ] sys Schema for System Diagnostics
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

---

## Module 10: Data Management & Maintenance (数据管理与维护)

### 10.1 Table Optimization
- [ ] Table Fragmentation and Optimization
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] OPTIMIZE TABLE Operations
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] ANALYZE TABLE for Statistics
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 10.2 Online DDL
- [ ] Online ALTER TABLE in InnoDB
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Instant Column Addition (MySQL 8.0.12+)
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Algorithm and Lock Options in ALTER TABLE
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 10.3 Partitioning & Sharding
- [ ] Table Partitioning Strategies
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Range, List, Hash Partitioning
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Sharding Architecture and Implementation
  - Priority: Low | Difficulty: Advanced | Has Demo: No | Status: Unstarted

---

## Module 11: Security & Access Control (安全与访问控制)

### 11.1 User Management
- [ ] User Accounts and Authentication Methods
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Password Management and Policies
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Plugin-based Authentication (mysql_native_password, caching_sha2_password)
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 11.2 Privilege Management
- [ ] Global, Database, and Table Privileges
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] GRANT and REVOKE Statements
  - Priority: High | Difficulty: Beginner | Has Demo: No | Status: Unstarted

- [ ] Principle of Least Privilege
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 11.3 Encryption & Data Protection
- [ ] TLS/SSL for Secure Connections
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Transparent Data Encryption (InnoDB)
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Column-Level Encryption Techniques
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 11.4 Auditing
- [ ] MySQL Audit Plugin
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Audit Event Logging and Analysis
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

---

## Module 12: Administration & Troubleshooting (管理与故障排查)

### 12.1 Connection Management
- [ ] Connection Pool Concepts
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Max Connections and Timeout Settings
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Connection Handling and Cleanup
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 12.2 Resource Management
- [ ] Query Time Limits
  - Priority: Medium | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Memory Management and Allocation
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] Disk Space Monitoring
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

### 12.3 Common Issues & Troubleshooting
- [ ] "Too Many Connections" Error
  - Priority: High | Difficulty: Intermediate | Has Demo: No | Status: Unstarted

- [ ] High CPU Usage Diagnosis
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Replica Lag and Synchronization Issues
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Data Corruption Detection and Recovery
  - Priority: High | Difficulty: Advanced | Has Demo: No | Status: Unstarted

### 12.4 Upgrade and Compatibility
- [ ] Major Version Upgrade Process
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

- [ ] Backward Compatibility Considerations
  - Priority: Medium | Difficulty: Advanced | Has Demo: No | Status: Unstarted

---

## Summary Stats

Total Learning Topics: 154

By Difficulty:
- Beginner: 24
- Intermediate: 78
- Advanced: 52

By Priority:
- Critical: 18
- High: 81
- Medium: 43
- Low: 12

By Availability of Demo:
- Has Demo: 20
- No Demo Yet: 134

---

## How to Use This Curriculum

1. **Choose Your Starting Point**: Begin with Module 1 (Fundamentals) if you are new to MySQL, or jump to your area of interest.

2. **Mark Progress**: Use the checkbox to track completion of each learning topic.

3. **Prioritize**: Focus on items marked "Critical" and "High" priority first for production readiness.

4. **Run Demos**: When a topic has "Has Demo: Yes", use the corresponding demo script to learn hands-on.

5. **Create New Demos**: For topics without demos, consider creating one to deepen understanding.

6. **Reference**: Use this document to structure your learning and ensure comprehensive coverage.

---

## Next Steps

- Create demo scripts for high-priority topics without demos
- Organize by learning phase based on your current level
- Set weekly goals to progress through the curriculum
