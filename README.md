# certgun

Cloudflare Origin Certificate automation for Coolify servers.

certgun handles the full lifecycle of Cloudflare Origin CA certificates: generating keys, issuing certificates, deploying them over SSH, configuring Traefik, and managing DNS records. It is designed for self-hosted Coolify setups where you want proper SSL termination with Cloudflare's Full (Strict) mode.

## Install

### Linux / macOS

```sh
curl -fsSL https://raw.githubusercontent.com/takielias/certgun/main/install.sh | sh
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/takielias/certgun/main/install.ps1 | iex
```

### Manual download

Grab the archive for your platform from the [releases](https://github.com/takielias/certgun/releases) page, extract it, and move the binary to a directory in your PATH.

| Platform | Architecture | Archive |
|----------|-------------|---------|
| Linux | amd64 | `certgun-0.1.0-linux-amd64.tar.gz` |
| Linux | arm64 | `certgun-0.1.0-linux-arm64.tar.gz` |
| macOS | amd64 | `certgun-0.1.0-darwin-amd64.tar.gz` |
| macOS | arm64 | `certgun-0.1.0-darwin-arm64.tar.gz` |
| Windows | amd64 | `certgun-0.1.0-windows-amd64.tar.gz` |
| Windows | arm64 | `certgun-0.1.0-windows-arm64.tar.gz` |

## Quick start

1. Run the interactive setup to configure your Cloudflare API token, SSH credentials, and server details:

   ```sh
   certgun init
   ```

2. Issue and deploy a certificate for your domain:

   ```sh
   certgun setup
   ```

3. List active certificates:

   ```sh
   certgun list
   ```

4. Remove a certificate and clean up:

   ```sh
   certgun remove
   ```

## What it does

- Issues Cloudflare Origin CA certificates (valid for up to 15 years)
- Deploys the certificate and private key to your server over SSH
- Configures Traefik with the appropriate TLS entrypoints and certificate resolvers
- Creates or updates Cloudflare DNS records pointing to your server
- Sets the domain's SSL/TLS mode to Full (Strict) in Cloudflare

## Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/takielias/certgun/main/uninstall.sh | sh
```

## License

MIT
