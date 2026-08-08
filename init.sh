#!/usr/bin/env bash
# Idempotent setup: initialize data dir if needed, start mysqld if not running,
# and make sure the deadlock_lab demo database exists.
set -e

MYSQL_HOME="C:/Users/DecVens/Desktop/programs/mysql-8.4.11-winx64"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYSQLD="$MYSQL_HOME/bin/mysqld.exe"
MYSQL="$MYSQL_HOME/bin/mysql.exe -h 127.0.0.1 -P 3306 -u root"

# 1. Initialize the data directory if it doesn't exist yet.
if [ ! -d "$MYSQL_HOME/data" ]; then
    echo "[init] no data dir found, initializing..."
    (cd "$MYSQL_HOME" && ./bin/mysqld.exe --defaults-file=./my.ini --initialize-insecure --console)
fi

# 2. Start the server if it's not already listening on 3306.
if ! netstat -ano | grep -q "127.0.0.1:3306.*LISTENING"; then
    echo "[init] starting mysqld..."
    (cd "$MYSQL_HOME" && ./bin/mysqld.exe --defaults-file=./my.ini --console > mysqld.log 2>&1 &)
    for i in $(seq 1 20); do
        sleep 1
        if netstat -ano | grep -q "127.0.0.1:3306.*LISTENING"; then
            break
        fi
    done
else
    echo "[init] mysqld already running on 3306"
fi

# 3. Make sure the demo database/table exist.
$MYSQL -e "CREATE DATABASE IF NOT EXISTS deadlock_lab;" >/dev/null
if ! $MYSQL -D deadlock_lab -e "SELECT 1 FROM accounts LIMIT 1;" >/dev/null 2>&1; then
    echo "[init] creating deadlock_lab demo data..."
    $MYSQL < "$PROJECT_DIR/sql/setup.sql"
fi

echo "[init] ready: 127.0.0.1:3306, user root, no password"
