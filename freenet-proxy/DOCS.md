# Configuration Examples

## Cloudflare Access setup

User configures in configuration.yaml:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.33.0/24
```

In the freenet-proxy app options:

- `auth_mode: cloudflare_access`
- `cf_access_enabled: true`
- `cf_team_domain: your-domain.cloudflareteams.com`

Cloudflare Zero Trust dashboard:

1. Create an Access Policy for the tunnel
2. Set rules like "Email domain must be @yourcompany.com"
3. Set ingress rule: https://freenet.yourdomain.com → http://freenet-proxy:8443
4. Add service tokens if needed for API access

## Pangolin/Newt setup

User configures in configuration.yaml:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
```

In the freenet-proxy app options:

- `auth_mode: pangolin`
- `pangolin_enabled: true`
- `pangolin_verify: true`

Pangolin dashboard:

1. Create a Resource pointing to http://freenet-proxy:8443
2. Enable SSL (auto-generated cert)
3. Configure OIDC if desired (Pangolin supports Google, GitHub, etc.)
4. Set access rules per user/group
