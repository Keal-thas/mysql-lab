# MySQL Learning Progress Tracker

Your personal learning roadmap. Check off items as you complete them. Focus on Critical and High priority items first.

Last Updated: 2026-09-27

---

## Phase 1: Foundation (Must Know)

Essential concepts before diving into advanced topics. Target: 2-3 weeks.

### Critical Path (Start Here)
- [ ] MySQL Architecture Overview
- [ ] Storage Engine Basics (InnoDB vs MyISAM)
- [ ] ACID Properties Definition
- [ ] Basic SQL Operations (SELECT, INSERT, UPDATE, DELETE)
- [ ] JOIN Operations Fundamentals

### High Priority Foundation Topics
- [ ] Data Types (Numeric, String, Date/Time)
- [ ] Index Basics and B+ Tree Structure
- [ ] Primary Key vs Secondary Indexes
- [ ] Transaction Lifecycle (BEGIN, COMMIT, ROLLBACK)
- [ ] Autocommit Behavior

**Estimated Time**: 2-3 weeks
**Current Status**: Not Started

---

## Phase 2: Core Skills (Essential for Daily Work)

Skills you need to handle real queries and basic optimization. Target: 4-5 weeks.

### Indexing & Query Optimization (Critical)
- [ ] EXPLAIN Statement Basics *(Demo: beginner/02-explain-basics)*
- [ ] Understanding EXPLAIN Output (type, key, rows, Extra) *(Demo: beginner/02-explain-basics)*
- [ ] Composite Indexes and Leftmost Prefix Principle *(Demo: beginner/04-index-leftmost-prefix)*
- [ ] Implicit Type Conversion Breaks Indexes *(Demo: beginner/03-implicit-type-conversion)*
- [ ] Large OFFSET Pagination Pitfall *(Demo: beginner/05-offset-pagination)*
- [ ] Covering Indexes and Index-Only Scans

### Transaction Isolation Levels (Critical)
- [ ] Four Isolation Levels Overview
- [ ] READ COMMITTED and Non-Repeatable Reads
- [ ] REPEATABLE READ and Phantom Reads

### Locking Fundamentals (High)
- [ ] Shared (Read) Locks vs Exclusive (Write) Locks
- [ ] Row Locks vs Table Locks
- [ ] Record Locks and Next-Key Locks

### Slow Query Monitoring (High)
- [ ] Slow Query Log Configuration *(Demo: advanced/01-slow-query-tuning)*
- [ ] Analyzing Slow Query Patterns *(Demo: advanced/01-slow-query-tuning)*
- [ ] Basic Query Performance Tuning

**Estimated Time**: 4-5 weeks
**Current Status**: Not Started

---

## Phase 3: Production Readiness (Concurrency & Troubleshooting)

Handling production scenarios: deadlocks, locking issues, concurrent access. Target: 3-4 weeks.

### Deadlock Handling (Critical)
- [ ] Deadlock Mechanism and Detection *(Demo: intermediate/01-deadlock)*
- [ ] Deadlock Cycle Example *(Demo: intermediate/01-deadlock)*
- [ ] Deadlock Analysis and Resolution *(Demo: intermediate/02-deadlock-analysis)*
- [ ] SHOW ENGINE INNODB STATUS for Debugging *(Demo: intermediate/02-deadlock-analysis)*
- [ ] Deadlock Prevention Strategies

### Advanced Locking Issues (High)
- [ ] Gap Lock Concept *(Demo: intermediate/03-gap-lock)*
- [ ] Gap Lock Causing Unexpected Blocking *(Demo: intermediate/03-gap-lock)*
- [ ] Idle Transaction Blocking DDL *(Demo: intermediate/04-idle-transaction-blocks-ddl)*
- [ ] Metadata Locks (MDL) Concept *(Demo: intermediate/04-idle-transaction-blocks-ddl)*

### MVCC & Concurrency Control (High)
- [ ] MVCC (Multi-Version Concurrency Control) Basics
- [ ] Undo Log and Version Chain
- [ ] Read View and Visibility Rules

### Monitoring & Diagnostics (High)
- [ ] Performance Schema Overview
- [ ] SHOW Commands (PROCESSLIST, STATUS, VARIABLES)
- [ ] sys Schema for System Diagnostics

**Estimated Time**: 3-4 weeks
**Current Status**: Not Started
**Demos Completed**: 10/10 available

---

## Phase 4: Operations & Advanced Topics (High Availability, Maintenance)

Operations, backup, replication, and advanced tuning. Target: 6-8 weeks (ongoing).

### InnoDB Internals (Medium Priority)
- [ ] Clustered Index (Primary Key) Implementation
- [ ] Secondary Index Structure and Lookup
- [ ] Page and Record Structure
- [ ] Transaction ID and Version Chain

### Logging & Recovery (High)
- [ ] Binary Log (Binlog) Purpose and Format
- [ ] Statement, Row, and Mixed Log Formats
- [ ] Redo Log Function and Structure
- [ ] Crash Recovery Process
- [ ] Point-in-Time Recovery Using Binlog

### Replication & High Availability (High)
- [ ] Master-Slave Replication Basics
- [ ] Binlog Position and Replication Lag
- [ ] Semi-Synchronous Replication Concept
- [ ] Global Transaction ID (GTID)

### Backup & Disaster Recovery (High)
- [ ] Logical Backup (mysqldump)
- [ ] Physical Backup Methods
- [ ] Percona XtraBackup Features
- [ ] Complete Database Recovery
- [ ] Point-in-Time Recovery from Backup + Binlog

### Performance Tuning (High)
- [ ] Key Tuning Parameters (buffer_pool_size, max_connections)
- [ ] Memory Optimization
- [ ] InnoDB Buffer Pool Sizing and Warmup
- [ ] Query Optimization for Complex Queries
- [ ] COUNT(*) Optimization Techniques

### Security & Access Control (High)
- [ ] User Accounts and Authentication Methods
- [ ] Global, Database, and Table Privileges
- [ ] GRANT and REVOKE Statements
- [ ] TLS/SSL for Secure Connections
- [ ] Transparent Data Encryption (InnoDB)

### Administration & Troubleshooting (Medium)
- [ ] Online ALTER TABLE (Online DDL)
- [ ] Algorithm and Lock Options in ALTER TABLE
- [ ] Table Fragmentation and Optimization
- [ ] ANALYZE TABLE for Statistics
- [ ] Connection Pool Concepts
- [ ] Max Connections and Timeout Settings
- [ ] Common Issues (Too Many Connections, High CPU, etc.)

**Estimated Time**: 6-8 weeks (ongoing)
**Current Status**: Not Started

---

## Additional Topics (Nice to Have, Lower Priority)

Topics for deeper understanding and specialized scenarios.

- [ ] JSON Data Type and Operations
- [ ] Enum and Set Types Pitfalls
- [ ] Subqueries and CTEs (Common Table Expressions)
- [ ] Index Types (Hash, Full-Text, Spatial)
- [ ] Query Optimizer Behavior and Hints
- [ ] LIKE Pattern Matching and Indexes
- [ ] Using Functions in WHERE Clause
- [ ] OR Conditions and Index Selection
- [ ] NOT IN vs NOT EXISTS Performance
- [ ] Savepoints for Partial Rollback
- [ ] Intention Locks (IS, IX)
- [ ] Lock Range Prediction Strategies
- [ ] Replication Filters
- [ ] Multithreaded Replica (MTS)
- [ ] MySQL Group Replication
- [ ] Incremental and Differential Backups
- [ ] Table Partitioning Strategies
- [ ] Sharding Architecture and Implementation
- [ ] Plugin-based Authentication
- [ ] Column-Level Encryption
- [ ] MySQL Audit Plugin
- [ ] Major Version Upgrade Process

---

## Statistics

**Total Topics**: 154
**Critical Priority**: 18
**High Priority**: 81
**Medium Priority**: 43
**Low Priority**: 12

**Phase Breakdown**:
- Phase 1 (Foundation): 12 topics
- Phase 2 (Core Skills): 26 topics
- Phase 3 (Production): 22 topics
- Phase 4 (Operations): 42 topics
- Additional Topics: 52 topics

**Current Progress**:
- Completed: 0/154 (0%)
- In Progress: 0
- Not Started: 154

---

## Learning Tips

1. **Follow the Phases in Order**: Each phase builds on the previous one. Don't skip.

2. **Use Available Demos**: When a topic has a demo, run it hands-on. That's the fastest way to learn.

3. **Read CURRICULUM.md for Details**: Full topic descriptions and context are in CURRICULUM.md.

4. **Create New Demos**: For high-priority topics without demos, consider creating one to deepen your understanding.

5. **Weekly Check-in**: Update this file weekly. Track what you learned and what's next.

6. **Focus on Critical Items First**: You should know everything marked "Critical" before working in production.

7. **Balance Theory and Practice**: Don't just read; actually run queries and see behavior in action.

---

## Quick Reference: Where to Start Right Now

If you are brand new to MySQL:
1. Start with Phase 1 (Foundation) - at least the "Critical Path" section
2. Run the EXPLAIN basics demo (beginner/02-explain-basics)
3. Run the index leftmost prefix demo (beginner/04-index-leftmost-prefix)

If you already know basic MySQL:
1. Jump to Phase 2 (Core Skills)
2. Run all the demos in beginner/ and intermediate/ directories
3. Move to Phase 3 when you understand deadlocks and locking

If you are preparing for production deployment:
1. Complete Phase 1 + Phase 2 + Phase 3
2. Then focus on Phase 4, especially Logging, Backup, and Recovery topics

---

## How to Update This File

Each week, update the checkboxes:
- [x] = Completed and understood
- [~] = In progress, still learning
- [ ] = Not started yet

Add notes or insights below each phase as you learn:

```
### Notes

Phase 1 Completed on: [DATE]
- Key learnings: ...
- Areas needing review: ...

Phase 2 Progress: [DATE]
- Currently working on: ...
- Next: ...
```
