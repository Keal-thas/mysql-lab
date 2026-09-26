#!/usr/bin/env bash
# Stop the lab's MySQL container. Data is kept (see reset.sh to wipe it).
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose stop
