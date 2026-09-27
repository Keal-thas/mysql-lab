#!/usr/bin/env bash
# Full point-in-time recovery walkthrough: backup -> good writes -> an "oops"
# DELETE -> restore the backup -> replay only the good writes from the
# binlog, using mysqlbinlog's --start-position/--stop-position to cut the
# DELETE out. Every step prints what it's doing and what to expect.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

BACKUP_FILE="$(mktemp -t pit_backup.XXXXXX.sql)"
trap 'rm -f "$BACKUP_FILE"' EXIT

echo "[1/6] resetting pit_lab..."
./client.sh < advanced/07-binlog-recovery/setup.sql

echo "[2/6] taking a consistent backup + noting the binlog position at backup time..."
docker compose exec -T mysql mysql -uroot -proot -e "FLUSH TABLES WITH READ LOCK;" &
LOCK_PID=$!
sleep 1
BACKUP_POS_LINE=$(docker compose exec -T mysql mysql -uroot -proot -N -e "SHOW BINARY LOG STATUS;" 2>/dev/null)
BACKUP_FILE_NAME=$(echo "$BACKUP_POS_LINE" | awk '{print $1}')
BACKUP_POS=$(echo "$BACKUP_POS_LINE" | awk '{print $2}')
docker compose exec -T mysql mysqldump -uroot -proot --databases pit_lab 2>/dev/null > "$BACKUP_FILE"
docker compose exec -T mysql mysql -uroot -proot -e "UNLOCK TABLES;"
wait "$LOCK_PID" 2>/dev/null || true
echo "    backup taken at $BACKUP_FILE_NAME:$BACKUP_POS"

echo "[3/6] making some GOOD changes after the backup..."
./client.sh -D pit_lab -e "
INSERT INTO accounts VALUES (3, 'Carol', 300.00);
UPDATE accounts SET balance = balance + 100 WHERE id = 1;
"
GOOD_POS=$(docker compose exec -T mysql mysql -uroot -proot -N -e "SHOW BINARY LOG STATUS;" 2>/dev/null | awk '{print $2}')
echo "    good writes end at position $GOOD_POS -- this is where we'll stop the replay"

echo "[4/6] simulating the disaster: someone runs DELETE FROM accounts with no WHERE..."
./client.sh -D pit_lab -e "DELETE FROM accounts;"
echo "    row count is now:"
./client.sh -D pit_lab -N -e "SELECT COUNT(*) FROM accounts;"

echo "[5/6] restoring the backup (this alone loses Carol and Alice's +100)..."
./client.sh -e "DROP DATABASE pit_lab;"
docker compose cp "$BACKUP_FILE" mysql:/tmp/pit_backup.sql
docker compose exec -T mysql sh -c "mysql -uroot -proot < /tmp/pit_backup.sql"

echo "[6/6] replaying only [$BACKUP_POS, $GOOD_POS) from $BACKUP_FILE_NAME -- the good writes, not the DELETE..."
docker compose run --rm binlog-tools bash -c "
mysqlbinlog --start-position=$BACKUP_POS --stop-position=$GOOD_POS /var/lib/mysql/$BACKUP_FILE_NAME | mysql -h mysql -uroot -proot
"

echo
echo "=== final state (expect Alice=1100.00, Bob=500.00, Carol=300.00, no DELETE) ==="
./client.sh -D pit_lab -e "SELECT * FROM accounts;"
