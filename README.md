# aiusage

`aiusage` runs [`one-api`](https://github.com/songquanpeng/one-api) behind Docker with a dedicated MySQL database named `aiusage_db`.

This repo is intended to give you:

- a central AI gateway / usage console
- one place to manage upstream API providers and local model relays
- a reverse-proxy target for `aiusage.webmanage.net`
- a clean separation from the existing `dealstage_db`

## What this stack includes

- `one-api` in Docker
- dedicated MySQL in Docker
- shared `shared_edge` network attachment so Caddy on VPS1 can reverse proxy it
- placeholder provider inventory for major US and Chinese model vendors plus current local/proxy infrastructure

## Quick start

```bash
cd /Users/samtaneja/Codex/aiusage
cp .env.example .env
./scripts/up.sh
```

Then open the local bind:

```bash
http://127.0.0.1:3015
```

Or after the edge route is enabled:

```bash
https://aiusage.webmanage.net
```

## Important first login note

The upstream `one-api` project defaults to:

- username: `root`
- password: `123456`

Change that immediately after first login.

## Key files

- stack config: [docker-compose.yml](/Users/samtaneja/Codex/aiusage/docker-compose.yml)
- env template: [.env.example](/Users/samtaneja/Codex/aiusage/.env.example)
- Cloudflare setup: [CLOUDFLARE.md](/Users/samtaneja/Codex/aiusage/CLOUDFLARE.md)
- provider inventory: [CHANNEL_PLACEHOLDERS.md](/Users/samtaneja/Codex/aiusage/CHANNEL_PLACEHOLDERS.md)
- scripts catalog: [SCRIPTS.md](/Users/samtaneja/Codex/aiusage/SCRIPTS.md)

## Expected reverse-proxy target

In the `hosting` repo, use:

```env
AIUSAGE_UPSTREAM=http://aiusage-one-api:3000
```

The container is attached to:

- `shared_edge` so Caddy can reach it
- `aiusage_internal` so MySQL stays private to this stack

## Provider placeholders

The `.env.example` file includes placeholders for:

- local / current stack:
  - Ollama on VPS2
  - Groq
  - Together AI
- major US / global:
  - OpenAI
  - Anthropic
  - Google Gemini
  - xAI
  - Mistral
  - Perplexity
  - OpenRouter
  - Azure OpenAI
- major Chinese / China-adjacent:
  - DeepSeek
  - Alibaba DashScope / Qwen
  - Zhipu
  - Moonshot / Kimi
  - MiniMax
  - Baidu Qianfan / ERNIE
  - Tencent Hunyuan
  - Volcengine Ark / Doubao
  - SiliconFlow
  - Stepfun
  - Yi

See [CHANNEL_PLACEHOLDERS.md](/Users/samtaneja/Codex/aiusage/CHANNEL_PLACEHOLDERS.md) for the recommended channel inventory and notes.

## Current architectural assessment

As an architecture choice, this setup is good if your goals are:

- centralizing API usage and spend visibility
- normalizing multiple upstreams behind one OpenAI-compatible layer
- testing local, US, and Chinese providers from one control plane

Why I like it:

- it gives you a dedicated billing / key management plane instead of scattering provider keys across apps
- it keeps usage analytics isolated from `dealstage_db`
- it fits your existing VPS1 + shared-edge reverse proxy model
- it lets `reviewgate`, `dealstage`, and future tools target one consistent gateway

Main risks and caveats:

- `one-api` serves both the admin UI and API traffic from the same app, so a single public hostname is operationally convenient but not ideal for management-plane isolation
- if you plan to expose `aiusage.webmanage.net` to external API clients, do not wrap the whole hostname in Caddy basic auth
- if this becomes production-critical, you should strongly consider:
  - a separate private admin route
  - Cloudflare Access / Tailscale / VPN for admin access
  - external database backups
  - a managed MySQL or a replicated database later if usage becomes important

My recommendation:

- use this repo now as the central gateway
- keep `aiusage.webmanage.net` public for API traffic
- treat admin access hardening as the next security step

## Deploy flow on VPS1

1. Copy `.env.example` to `.env`
2. Set strong MySQL passwords
3. Start the stack:

```bash
./scripts/up.sh
```

4. Log in and change the default `root` password
5. Seed the three current local Ollama channels:

```bash
./scripts/add_local_channels.sh
```

6. Add any additional upstream channels in the `one-api` UI using the placeholders from [CHANNEL_PLACEHOLDERS.md](/Users/samtaneja/Codex/aiusage/CHANNEL_PLACEHOLDERS.md)
7. Update `hosting/.env` with:

```env
AIUSAGE_UPSTREAM=http://aiusage-one-api:3000
```

8. Recreate Caddy in the `hosting` repo

## Validation

Local:

```bash
curl -I http://127.0.0.1:3015
docker logs aiusage-one-api --tail 100
docker logs aiusage-mysql --tail 100
```

Edge:

```bash
curl -I https://aiusage.webmanage.net
```

## Backup note

This stack stores:

- MySQL data in `./data/mysql`
- one-api local state in `./data/one-api`

For now, filesystem backup of `data/` is enough for lab use. For production usage accounting, add scheduled MySQL dumps.
