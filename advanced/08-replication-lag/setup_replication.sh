#!/usr/bin/env bash
# Start the replica container and point it at the master, from scratch.
# Uses classic file+position replication (this lab doesn't have GTID mode
# on), which is fine for a from-scratch demo replica with no prior data.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

echo "[1/4] starting mysql-replica (profile 'replica', not part of the default stack)..."
docker compose --profile replica up -d mysql-replica
echo "    waiting for it to accept connections..."
until docker compose exec -T mysql-replica mysqladmin ping -uroot -proot --silent 2>/dev/null; do
    sleep 1
done

echo "[2/4] creating a replication user on the master (idempotent)..."
./client.sh -e "
CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
"

echo "[3/4] reading the master's current binlog position..."
POS_LINE=$(docker compose exec -T mysql mysql -uroot -proot -N -e "SHOW BINARY LOG STATUS;" 2>/dev/null)
LOG_FILE=$(echo "$POS_LINE" | awk '{print $1}')
LOG_POS=$(echo "$POS_LINE" | awk '{print $2}')
echo "    $LOG_FILE:$LOG_POS"

echo "[4/4] pointing the replica at the master from that position and starting replication..."
docker compose exec -T mysql-replica mysql -uroot -proot -e "
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='mysql',
  SOURCE_USER='repl',
  SOURCE_PASSWORD='replpass',
  SOURCE_LOG_FILE='$LOG_FILE',
  SOURCE_LOG_POS=$LOG_POS,
  GET_SOURCE_PUBLIC_KEY=1;
START REPLICA;
"
sleep 2
echo
echo "=== replica status (expect Replica_IO_Running=Yes, Replica_SQL_Running=Yes) ==="
docker compose exec -T mysql-replica mysql -uroot -proot -e "SHOW REPLICA STATUS\G" 2>/dev/null \
  | grep -E "Replica_IO_Running|Replica_SQL_Running|Seconds_Behind_Source|Last_IO_Error|Last_SQL_Error"
