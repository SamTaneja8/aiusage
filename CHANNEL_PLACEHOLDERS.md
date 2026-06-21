# Channel Placeholders

This file lists the recommended initial provider/channel inventory for `one-api`.

These placeholders are grouped by:

- current stack integrations
- major US / global vendors
- major Chinese / China-adjacent vendors
- proxy / gateway inventory

## Important note

The current repo provides placeholder env values and operational inventory.

It does **not** automatically seed `one-api` channels into the database yet.

Use the `one-api` admin UI to create channels from this list after first login.

## Current stack channels

These three local Ollama channels are also seeded by:

```bash
./scripts/add_local_channels.sh
```

| Channel label | Provider family | Base URL / endpoint | Model placeholder(s) | Secret / credential placeholder | Notes |
| --- | --- | --- | --- | --- | --- |
| `Ollama Primary` | Local Ollama relay | `${OLLAMA_BASE_URL}` | `${OLLAMA_PRIMARY_MODEL}` | none | Current VPS2 local primary |
| `Ollama Secondary` | Local Ollama relay | `${OLLAMA_BASE_URL}` | `${OLLAMA_SECONDARY_MODEL}` | none | Current VPS2 local secondary |
| `Ollama Fallback` | Local Ollama relay | `${OLLAMA_BASE_URL}` | `${OLLAMA_FALLBACK_MODEL}` | none | Current VPS2 local fallback |
| `Groq Remote` | Groq | `${GROQ_BASE_URL}` | `${GROQ_MODEL}` | `${GROQ_API_KEY}` | Already used in `aistage` |
| `Together Remote` | Together AI | `${TOGETHERAI_BASE_URL}` | `${TOGETHERAI_MODEL}` | `${TOGETHERAI_API_KEY}` | Already used in `aistage` |

## Major US / global channel placeholders

| Channel label | Provider family | Base URL / endpoint | Model placeholder(s) | Secret placeholder |
| --- | --- | --- | --- | --- |
| `OpenAI GPT-5` | OpenAI | `${OPENAI_BASE_URL}` | `${OPENAI_MODEL}` | `${OPENAI_API_KEY}` |
| `Anthropic Claude` | Anthropic | `${ANTHROPIC_BASE_URL}` | `${ANTHROPIC_MODEL}` | `${ANTHROPIC_API_KEY}` |
| `Google Gemini` | Google | `${GOOGLE_BASE_URL}` | `${GOOGLE_MODEL}` | `${GOOGLE_API_KEY}` |
| `xAI Grok` | xAI | `${XAI_BASE_URL}` | `${XAI_MODEL}` | `${XAI_API_KEY}` |
| `Mistral Large` | Mistral | `${MISTRAL_BASE_URL}` | `${MISTRAL_MODEL}` | `${MISTRAL_API_KEY}` |
| `Perplexity Sonar` | Perplexity | `${PERPLEXITY_BASE_URL}` | `${PERPLEXITY_MODEL}` | `${PERPLEXITY_API_KEY}` |
| `OpenRouter` | OpenRouter | `${OPENROUTER_BASE_URL}` | `${OPENROUTER_MODEL}` | `${OPENROUTER_API_KEY}` |
| `Azure OpenAI` | Azure OpenAI | `${AZURE_OPENAI_BASE_URL}` | `${AZURE_OPENAI_DEPLOYMENT}` | `${AZURE_OPENAI_API_KEY}` |

## Major Chinese / China-adjacent channel placeholders

| Channel label | Provider family | Base URL / endpoint | Model placeholder(s) | Secret placeholder |
| --- | --- | --- | --- | --- |
| `DeepSeek` | DeepSeek | `${DEEPSEEK_BASE_URL}` | `${DEEPSEEK_MODEL}` | `${DEEPSEEK_API_KEY}` |
| `Qwen / DashScope` | Alibaba | `${ALIBABA_DASHSCOPE_BASE_URL}` | `${ALIBABA_DASHSCOPE_MODEL}` | `${ALIBABA_DASHSCOPE_API_KEY}` |
| `Zhipu GLM` | Zhipu | `${ZHIPU_BASE_URL}` | `${ZHIPU_MODEL}` | `${ZHIPU_API_KEY}` |
| `Moonshot Kimi` | Moonshot | `${MOONSHOT_BASE_URL}` | `${MOONSHOT_MODEL}` | `${MOONSHOT_API_KEY}` |
| `MiniMax` | MiniMax | `${MINIMAX_BASE_URL}` | `${MINIMAX_MODEL}` | `${MINIMAX_API_KEY}` |
| `Baidu Qianfan` | Baidu | `${BAIDU_QIANFAN_BASE_URL}` | `${BAIDU_QIANFAN_MODEL}` | `${BAIDU_QIANFAN_API_KEY}` |
| `Tencent Hunyuan` | Tencent | `${TENCENT_HUNYUAN_BASE_URL}` | `${TENCENT_HUNYUAN_MODEL}` | `${TENCENT_HUNYUAN_API_KEY}` |
| `Volcengine Ark / Doubao` | ByteDance / Volcengine | `${VOLCENGINE_ARK_BASE_URL}` | `${VOLCENGINE_ARK_MODEL}` | `${VOLCENGINE_ARK_API_KEY}` |
| `SiliconFlow` | SiliconFlow | `${SILICONFLOW_BASE_URL}` | `${SILICONFLOW_MODEL}` | `${SILICONFLOW_API_KEY}` |
| `Stepfun` | Stepfun | `${STEPFUN_BASE_URL}` | `${STEPFUN_MODEL}` | `${STEPFUN_API_KEY}` |
| `Yi / Lingyi Wanwu` | Yi | `${YI_BASE_URL}` | `${YI_MODEL}` | `${YI_API_KEY}` |

## Proxy and gateway inventory

These are not channels by themselves, but they matter operationally.

Important boundary:

- these proxy placeholders are inventory/reference only
- they should not be routed through `one-api`
- they should not be used as a central proxy layer for scraper traffic
- scraper repos should continue to talk to their stealth providers directly

| Inventory item | Placeholder | Recommended use |
| --- | --- | --- |
| process-wide relay proxy | `${RELAY_PROXY}` | Force all relay traffic through one outbound proxy |
| user-content request proxy | `${USER_CONTENT_REQUEST_PROXY}` | Proxy user-content fetches if needed |
| Cloudflare AI Gateway | `${CLOUDFLARE_AI_GATEWAY_BASE_URL}` | Optional API gateway layer |
| Evomi proxy inventory | `${EVOMI_PROXY_URL}` | Keep as inventory only unless intentionally reused |
| Bright Data proxy inventory | `${BRIGHTDATA_PROXY_URL}` | Keep as inventory only unless intentionally reused |
| Decodo proxy inventory | `${DECODO_PROXY_URL}` | Keep as inventory only unless intentionally reused |
| FloppyData proxy inventory | `${FLOPPYDATA_PROXY_URL}` | Keep as inventory only unless intentionally reused |

## Suggested first wave

If you want the cleanest first deployment, start with only:

1. `Ollama Primary`
2. `Ollama Secondary`
3. `Groq Remote`
4. `Together Remote`
5. `OpenAI GPT-5`
6. `DeepSeek`
7. `Google Gemini`

That gives you:

- local fallback
- one fast US remote provider
- one broad global proxy / model market
- one premium frontier provider
- one strong Chinese provider
- one Google-native path
