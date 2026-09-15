# Freenet

Runs a Freenet peer on your Home Assistant host, with a Caddy gateway in
front so you can reach River, Delta, Git and Mail from anywhere through a
Cloudflare Tunnel or a Pangolin/Newt connection.

## What this app does

Two processes run in one container, supervised by s6:

- **freenet-core**, the Freenet peer (using the official supervisor script)
- **Caddy**, the gateway

The node binds its API to all interfaces inside the container so that
Home Assistant can map the ports. Caddy proxies to `127.0.0.1:7509`, so the
node's API is never directly exposed to the internet.

## Access modes

Pick one in the app configuration.

### cloudflare_access (recommended)

Cloudflare Zero Trust authenticates at the edge. Caddy rejects requests
that carry no `Cf-Access-Jwt-Assertion` header.

### pangolin

Pangolin authenticates at its server before Newt forwards anything.
Caddy cannot verify a per-request token in this mode.

### oidc

Caddy validates tokens itself using the caddy-security plugin. Works with
any OIDC provider.

### none

No authentication at this layer. Only appropriate when the IP allowlist
is genuinely the only way to reach the port.

## Networking

The app uses **bridge mode** with port mapping, not `host_network`.
This is safer and allows you to map specific ports.

- **Host Port 8443** (TCP): Caddy gateway (Cloudflare/Pangolin target)
- **Host Port 31337** (UDP): Freenet P2P traffic

## ⚠️ Read before exposing your node

**Set an Access policy.** In `cloudflare_access` mode, Caddy checks that
the Access header is *present*. It does not validate its signature. That
means the Cloudflare Access policy is doing the real authentication, and
if you leave the public hostname without a policy, the node is exposed.

## Auto-update

The node updates itself automatically. This is **not optional**.
Freenet ships frequent releases, and nodes below the minimum compatible
version are refused by the network.

You can disable auto-update by setting `FREENET_DISABLE_AUTO_UPDATE=1` in
the environment, but **do not do this on the real network**.

