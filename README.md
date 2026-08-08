# mysql-lab

Local MySQL environment for learning and testing (currently focused on deadlocks).

## MySQL instance

- Type: portable (noinstall ZIP) MySQL 8.4.11 Community Server, not a Windows service
- Location: `C:\Users\DecVens\Desktop\programs\mysql-8.4.11-winx64`
- Host: `127.0.0.1`, Port: `3306`
- User: `root`, Password: (empty)

Start / stop:

```bash
./start.sh
./stop.sh
```

Connect with the client:

```bash
"C:/Users/DecVens/Desktop/programs/mysql-8.4.11-winx64/bin/mysql.exe" -h 127.0.0.1 -P 3306 -u root
```

## Deadlock demo

`sql/setup.sql` creates a `deadlock_lab` database with an `accounts` table (Alice, Bob).

To reproduce a classic deadlock, open two separate `mysql` client sessions:

1. In session A, run the first `UPDATE` from `sql/session_a.sql` (locks row id=1).
2. In session B, run all of `sql/session_b.sql` (locks row id=2, then blocks trying to lock row id=1).
3. Back in session A, run the second `UPDATE` (tries to lock row id=2) — MySQL's deadlock detector kills one transaction with error 1213 `Deadlock found when trying to get lock; try restarting transaction`.

Inspect the deadlock details afterward:

```sql
SHOW ENGINE INNODB STATUS\G
```

(look at the "LATEST DETECTED DEADLOCK" section)
