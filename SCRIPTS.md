# Scripts

This document describes the helper scripts in `aiusage/scripts`.

## Network and stack lifecycle

### `scripts/create_network.sh`

Ensures the shared Docker network used by the `hosting` repo exists before the `one-api` container is started.

### `scripts/up.sh`

Creates the shared edge network if needed, then starts the `aiusage` Docker stack with `docker compose up -d`.

### `scripts/down.sh`

Stops the local Docker stack without removing persistent data.

## Channel bootstrap

### `scripts/add_local_channels.sh`

Adds or refreshes the three local Ollama-backed `one-api` channels directly in `aiusage_db`:

- `qwen2.5:3b`
- `phi4-mini:3.8b`
- `llama3.2:3b`

The script is idempotent for those three channel names. It deletes the existing matching channel rows and their `abilities`, then recreates them with the current `OLLAMA_BASE_URL` and `ONEAPI_CHANNEL_GROUP`.
