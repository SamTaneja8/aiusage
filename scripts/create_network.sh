#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT}/.env"

read_env_value() {
  local key="$1"
  local env_file="$2"
  python3 - "$key" "$env_file" <<'PY'
import sys
from pathlib import Path

key = sys.argv[1]
env_file = Path(sys.argv[2])

if not env_file.exists():
    raise SystemExit(0)

for raw_line in env_file.read_text(encoding="utf-8").splitlines():
    line = raw_line.strip()
    if not line or line.startswith("#") or "=" not in line:
        continue
    current_key, value = line.split("=", 1)
    if current_key.strip() != key:
        continue
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        value = value[1:-1]
    print(value)
    break
PY
}

NETWORK_NAME="$(read_env_value "SHARED_EDGE_NETWORK" "${ENV_FILE}")"
NETWORK_NAME="${NETWORK_NAME:-shared_edge}"

if docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1; then
  echo "Docker network ${NETWORK_NAME} already exists."
  exit 0
fi

docker network create "${NETWORK_NAME}" >/dev/null
echo "Created Docker network ${NETWORK_NAME}."
