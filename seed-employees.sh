#!/usr/bin/env bash
# Load the official MySQL "employees" sample database into the lab container.
# Source: https://github.com/datacharmer/test_db (widely used MySQL sample
# dataset: ~300k employees, ~2.8M salary rows — enough scale to make
# EXPLAIN/index/pagination demos meaningful against real data).
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[seed-employees] cloning datacharmer/test_db..."
git clone --depth 1 https://github.com/datacharmer/test_db.git "$TMP_DIR/test_db"

echo "[seed-employees] copying into container and loading..."
docker compose cp "$TMP_DIR/test_db" mysql:/tmp/test_db
docker compose exec -T mysql sh -c "cd /tmp/test_db && mysql -uroot -proot < employees.sql"
docker compose exec -T mysql rm -rf /tmp/test_db

echo "[seed-employees] done. Try: ./client.sh -D employees -e 'SHOW TABLES;'"
