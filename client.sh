#!/usr/bin/env bash
# Open a mysql client against the lab container.
# Usage: ./client.sh              (interactive shell)
#        ./client.sh < some.sql   (pipe in a script)
#        ./client.sh -D dbname
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

if [ -t 0 ]; then
    docker compose exec mysql mysql -uroot -proot "$@"
else
    docker compose exec -T mysql mysql -uroot -proot "$@"
fi
