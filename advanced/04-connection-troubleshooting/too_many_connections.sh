#!/usr/bin/env bash
# Simulate "Too many connections" (error 1040): lower max_connections to a
# tiny number, open several connections at once, and watch some of them get
# rejected. Restores max_connections to its original value on exit.
set -e
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

ORIGINAL=$(./client.sh -N -e "SELECT @@GLOBAL.max_connections;")
trap './client.sh -e "SET GLOBAL max_connections = '"$ORIGINAL"';" >/dev/null' EXIT

echo "[too_many_connections] original max_connections=$ORIGINAL, lowering to 3"
./client.sh -e "SET GLOBAL max_connections = 3;"

echo "[too_many_connections] opening 5 connections at once (each holds SLEEP(3))..."
for i in 1 2 3 4 5; do
    ./client.sh -e "SELECT SLEEP(3), CONNECTION_ID() AS conn_$i;" &
done
wait

echo "[too_many_connections] done -- some of the 5 above should show"
echo "'ERROR 1040 (HY000): Too many connections', the rest succeeded."
echo "root got in more often than max_connections=3 alone suggests: SUPER"
echo "accounts (root here) get an extra reserved connection on top of the"
echo "limit (see the CONNECTION_ADMIN/SUPER privilege docs), so a non-SUPER"
echo "application user would hit the wall one connection earlier."
