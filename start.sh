#!/usr/bin/env bash
# Start the lab's MySQL 8.4 container and wait until it accepts connections.
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

docker compose up -d
echo "[start] waiting for mysql to be ready..."
until docker compose exec -T mysql mysqladmin ping -h 127.0.0.1 --silent 2>/dev/null; do
    sleep 1
done
echo "[start] ready: 127.0.0.1:3306, user root, no password"
