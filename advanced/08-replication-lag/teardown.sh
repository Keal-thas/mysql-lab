#!/usr/bin/env bash
# Stop and remove ONLY the replica container -- scoped to this one service
# so it never touches the main mysql/adminer/dozzle/docs stack.
#
# IMPORTANT: plain `docker compose down` tears down the WHOLE project
# (found out the hard way while building this demo -- it stopped the main
# `mysql` container too, even with --profile set). `down` doesn't take a
# service argument to scope itself, so this uses `rm -sf` on just the one
# service instead. Its data volume (mysql-lab-replica-data) is left in
# place -- remove it yourself with `docker volume ls` + `docker volume rm`
# if you want to reclaim the space; it'll just be reused next time
# otherwise.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

docker compose rm -sf mysql-replica
echo "done -- mysql-replica removed, main stack untouched."
