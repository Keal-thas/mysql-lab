#!/usr/bin/env bash
# Stop the container and wipe all data for a clean slate.
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose down -v
