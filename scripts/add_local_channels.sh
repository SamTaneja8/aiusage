#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Copy .env.example to .env first." >&2
  exit 1
fi

read_env_value() {
  local key="$1"
  local env_file="$2"
  python3 - "$key" "$env_file" <<'PY'
import sys
from pathlib import Path

key = sys.argv[1]
env_file = Path(sys.argv[2])

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

MYSQL_CONTAINER="$(read_env_value "MYSQL_CONTAINER_NAME" "${ENV_FILE}")"
MYSQL_DATABASE="$(read_env_value "MYSQL_DATABASE" "${ENV_FILE}")"
MYSQL_ROOT_PASSWORD="$(read_env_value "MYSQL_ROOT_PASSWORD" "${ENV_FILE}")"
OLLAMA_BASE_URL="$(read_env_value "OLLAMA_BASE_URL" "${ENV_FILE}")"
ONEAPI_CHANNEL_GROUP="$(read_env_value "ONEAPI_CHANNEL_GROUP" "${ENV_FILE}")"

MYSQL_CONTAINER="${MYSQL_CONTAINER:-aiusage-mysql}"
MYSQL_DATABASE="${MYSQL_DATABASE:-aiusage_db}"
OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://10.20.0.2:11434}"
ONEAPI_CHANNEL_GROUP="${ONEAPI_CHANNEL_GROUP:-default}"

if [[ -z "${MYSQL_ROOT_PASSWORD}" ]]; then
  echo "MYSQL_ROOT_PASSWORD must be set in ${ENV_FILE}." >&2
  exit 1
fi

BASE_URL_TRIMMED="${OLLAMA_BASE_URL%/}"

docker exec -i "${MYSQL_CONTAINER}" mysql -uroot "-p${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" <<SQL
SET @channel_group = '${ONEAPI_CHANNEL_GROUP}';
SET @base_url = '${BASE_URL_TRIMMED}';
SET @created_time = UNIX_TIMESTAMP();

DELETE FROM abilities
WHERE channel_id IN (
  SELECT id
  FROM channels
  WHERE name IN (
    'Ollama Primary (qwen2.5:3b)',
    'Ollama Secondary (phi4-mini:3.8b)',
    'Ollama Fallback (llama3.2:3b)'
  )
);

DELETE FROM channels
WHERE name IN (
  'Ollama Primary (qwen2.5:3b)',
  'Ollama Secondary (phi4-mini:3.8b)',
  'Ollama Fallback (llama3.2:3b)'
);

INSERT INTO channels (
  type,
  \`key\`,
  status,
  name,
  weight,
  created_time,
  test_time,
  response_time,
  base_url,
  balance,
  balance_updated_time,
  models,
  \`group\`,
  used_quota,
  priority,
  config
) VALUES
  (30, 'local-ollama-primary', 1, 'Ollama Primary (qwen2.5:3b)', 0, @created_time, 0, 0, @base_url, 0, 0, 'qwen2.5:3b', @channel_group, 0, 0, ''),
  (30, 'local-ollama-secondary', 1, 'Ollama Secondary (phi4-mini:3.8b)', 0, @created_time, 0, 0, @base_url, 0, 0, 'phi4-mini:3.8b', @channel_group, 0, 0, ''),
  (30, 'local-ollama-fallback', 1, 'Ollama Fallback (llama3.2:3b)', 0, @created_time, 0, 0, @base_url, 0, 0, 'llama3.2:3b', @channel_group, 0, 0, '');

INSERT INTO abilities (\`group\`, model, channel_id, enabled, priority)
SELECT c.\`group\`, c.models, c.id, TRUE, c.priority
FROM channels c
WHERE c.name IN (
  'Ollama Primary (qwen2.5:3b)',
  'Ollama Secondary (phi4-mini:3.8b)',
  'Ollama Fallback (llama3.2:3b)'
);
SQL

echo "Seeded local Ollama channels into ${MYSQL_DATABASE} using base URL ${BASE_URL_TRIMMED}."
