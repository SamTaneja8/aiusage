#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT}/.env"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  set -a && source "${ENV_FILE}" && set +a
fi

NETWORK_NAME="${SHARED_EDGE_NETWORK:-shared_edge}"

if docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1; then
  echo "Docker network ${NETWORK_NAME} already exists."
  exit 0
fi

docker network create "${NETWORK_NAME}" >/dev/null
echo "Created Docker network ${NETWORK_NAME}."

