# Cloudflare Setup for `aiusage.webmanage.net`

This document covers the DNS and edge settings needed to expose `one-api` through:

- `https://aiusage.webmanage.net`

## DNS record

Add this record in the `webmanage.net` Cloudflare zone:

- `A` record
  - name: `aiusage`
  - value: `YOUR_VPS1_PUBLIC_IP`
  - proxy status: **Proxied**

This should resolve:

- `aiusage.webmanage.net`

## SSL/TLS mode

Use:

- **Full (strict)**

Reason:

- Caddy on VPS1 terminates TLS with a valid origin certificate
- Cloudflare should validate that origin certificate

## Why `aiusage.webmanage.net` should be proxied

Unlike `headscale.webmanage.net`, this hostname is normal HTTPS API traffic and is compatible with Cloudflare proxy mode.

Cloudflare proxying gives you:

- TLS edge termination
- origin IP shielding
- optional WAF / rate-limiting later

## Hosting-side upstream

In `~/hosting/.env`:

```env
AIUSAGE_UPSTREAM=http://aiusage-one-api:3000
```

And ensure the `hosting` repo includes:

- `aiusage.webmanage.net` as a proxy host

## Verification

After DNS is live and Caddy is recreated:

```bash
curl -I https://aiusage.webmanage.net
curl -k -I --resolve aiusage.webmanage.net:443:127.0.0.1 https://aiusage.webmanage.net
```

Expected:

- `200`
- or `302` depending on the upstream `one-api` route behavior

## Security note

This hostname is intentionally left suitable for API clients, so it should not be wrapped in whole-site Caddy basic auth.

For stronger admin-plane isolation later, prefer one of:

- separate `api-admin.webmanage.net` behind auth
- Cloudflare Access on admin paths
- Tailscale-only admin access
