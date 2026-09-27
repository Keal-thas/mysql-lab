#!/usr/bin/env bash
# Fire a big write burst at the master, then poll the replica's
# Seconds_Behind_Source every couple seconds until it catches back up to 0.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

echo "[1/2] creating a 2,000,000-row table on the master in one burst..."
./client.sh -e "
DROP DATABASE IF EXISTS repl_lag_lab;
CREATE DATABASE repl_lag_lab;
USE repl_lag_lab;
CREATE TABLE t (id INT PRIMARY KEY AUTO_INCREMENT, payload VARCHAR(200) NOT NULL);
CREATE TABLE seed_nums (n INT PRIMARY KEY);
SET SESSION cte_max_recursion_depth = 2000;
INSERT INTO seed_nums WITH RECURSIVE seq AS (SELECT 0 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 1999) SELECT n FROM seq;
INSERT INTO t (payload) SELECT REPEAT('x', 200) FROM seed_nums a JOIN seed_nums b ON b.n < 1000;
DROP TABLE seed_nums;
"

echo "[2/2] polling the replica's lag every 2s until it's caught up..."
for i in $(seq 1 15); do
    sleep 2
    LAG=$(docker compose exec -T mysql-replica mysql -uroot -proot -e \
        "SHOW REPLICA STATUS\G" 2>/dev/null | grep "Seconds_Behind_Source" | awk '{print $2}' || true)
    echo "    t+${i}x2s: Seconds_Behind_Source=${LAG:-?}"
    if [ "$LAG" = "0" ]; then
        echo "    caught up."
        break
    fi
done

echo
echo "=== row counts (should match once lag hits 0) ==="
echo -n "master:  "; ./client.sh -N -e "SELECT COUNT(*) FROM repl_lag_lab.t;"
echo -n "replica: "; docker compose exec -T mysql-replica mysql -uroot -proot -N -e "SELECT COUNT(*) FROM repl_lag_lab.t;" 2>/dev/null
