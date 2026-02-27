---
name: exe-dev-knowledge
description: >-
  This skill should be used when the user mentions "exe.dev", "exe dev",
  "exe VM", "exe.xyz", asks to "create a VM", "list my VMs", "share my
  server", "make port public", "set up custom domain", "configure DNS",
  "LLM gateway", "proxy port", "send email from VM", mentions Shelley
  agent, SSH proxy, or works with exe.dev infrastructure in any way.
  Provides comprehensive knowledge of the exe.dev platform, SSH CLI,
  HTTP proxy, sharing, custom domains, LLM gateway, email, and VM
  management.
---

# exe.dev Platform Knowledge

exe.dev is a subscription VM service. SSH **is** the CLI — there is no binary to install. All management commands run as `ssh exe.dev <command>`.

VMs are accessible at `<vmname>.exe.xyz` via SSH and HTTPS.

## Core Concepts

- VMs run on bare metal via Cloud Hypervisor with container images (default: `exeuntu`)
- VM creation takes ~2 seconds
- Persistent disks survive restarts
- VMs share CPU/RAM within subscription tier
- No dedicated public IP — exe.dev terminates TLS and proxies traffic

## SSH CLI Reference

All commands use the pattern `ssh exe.dev <command> [args]`. Append `--json` to `ls` and `new` for machine-readable output.

### VM Lifecycle

```
ssh exe.dev new                              # create VM (default image)
ssh exe.dev new --image=<image>              # create VM with custom image
ssh exe.dev ls                               # list VMs
ssh exe.dev ls --json                        # list VMs (JSON)
ssh exe.dev rm <vmname>                      # delete VM
ssh exe.dev restart <vmname>                 # restart VM
ssh exe.dev rename <old> <new>               # rename VM
ssh exe.dev cp <source> <dest>               # clone VM with disk
```

### Connecting to VMs

```
ssh <vmname>.exe.xyz                         # SSH into VM
scp <localfile> <vmname>.exe.xyz:            # copy file to VM
scp <vmname>.exe.xyz:<remote> <local>        # copy file from VM
```

### Other Commands

```
ssh exe.dev whoami                           # show account info
ssh exe.dev ssh-key                          # manage SSH keys
ssh exe.dev shelley install <vmname>         # upgrade Shelley agent
ssh exe.dev browser <vmname>                 # open VM in browser
ssh exe.dev help                             # show help
ssh exe.dev doc                              # show docs
```

## HTTP Proxy

Every VM gets `https://<vmname>.exe.xyz/` with automatic TLS.

- Default port: auto-detected from Dockerfile EXPOSE (prefers 80, falls back to smallest port >= 1024)
- Change target port: `ssh exe.dev share port <vmname> <port>`
- Ports 3000-9999 forwarded transparently at `https://<vmname>.exe.xyz:<port>/`
- Only the primary port can be made public; alternate ports require VM access

### Proxy Headers

Proxied requests include:
- `X-Forwarded-Proto`, `X-Forwarded-Host`, `X-Forwarded-For` (standard)
- `X-ExeDev-UserID` — stable unique user ID (authenticated requests only)
- `X-ExeDev-Email` — user email (authenticated requests only)

### Auth URLs

- Login: `https://<vmname>.exe.xyz/__exe.dev/login?redirect={path}`
- Logout: `POST https://<vmname>.exe.xyz/__exe.dev/logout`

## Sharing & Access Control

Default: private (login required). Manage with `ssh exe.dev share` subcommands:

```
ssh exe.dev share set-public <vmname>        # anyone can access
ssh exe.dev share set-private <vmname>       # require login (default)
ssh exe.dev share add <vmname> <email>       # invite by email
ssh exe.dev share add-link <vmname>          # generate share link
ssh exe.dev share remove-link <vmname>       # revoke share link
ssh exe.dev share remove <vmname> <email>    # revoke user access
ssh exe.dev share port <vmname> <port>       # change proxy port
```

## Custom Domains

Subdomains: CNAME `app.example.com` → `vmname.exe.xyz`

Apex domains: ALIAS `example.com` → `exe.xyz` + CNAME `www.example.com` → `vmname.exe.xyz`

TLS certificates provisioned automatically.

## LLM Gateway

Built-in proxy to LLM providers at `http://169.254.169.254/gateway/llm/<provider>`. No API keys required. Included token allocation with subscription.

Providers: `anthropic`, `openai`, `fireworks`

Example (Anthropic):
```bash
curl -s http://169.254.169.254/gateway/llm/anthropic/v1/messages \
  -H "content-type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-sonnet-4-5-20250929","max_tokens":256,"messages":[{"role":"user","content":"Hello!"}]}'
```

## Email

### Receiving

Enable: `ssh exe.dev share receive-email <vmname> on`
Disable: `ssh exe.dev share receive-email <vmname> off`

Mail delivers to `~/Maildir/new/` in Maildir format. Use the `Delivered-To:` header (not `To:` or `CC:`) for the recipient address. Max 1MB per message, no spam filtering. Auto-disables if 1,000+ unprocessed files accumulate.

### Sending

Send to your registered email via the internal gateway:

```bash
curl -X POST http://169.254.169.254/gateway/email/send \
  -H "Content-Type: application/json" \
  -d '{"to": "you@example.com", "subject": "...", "body": "..."}'
```

All three fields (`to`, `subject`, `body`) are required. `to` must match your registered email. Returns `{"success": true}` or `{"error": "message"}`.

## Shelley

Web-based coding agent included on default exeuntu VMs. Accepts natural language tasks — installs software, builds sites, browses the web. Runs on port 9999, accessible at `https://<vmname>.shelley.exe.xyz/`. Uses the LLM Gateway by default (no API key needed), but supports custom credentials.

Customize behavior with guidance files (checked in priority order):
- `~/.config/shelley/AGENTS.md` — personal config
- `AGENTS.md`, `CLAUDE.md`, or `DEAR_LLM.md` — project-level, in git root or working directory

Upgrade to latest: `ssh exe.dev shelley install <vmname>` (VMs ship the version from creation time).

## SSH Configuration

Host key fingerprint: `SHA256:JJOP/lwiBGOMilfONPWZCXUrfK154cnJFXcqlsi6lPo`

Recommended `~/.ssh/config`:
```
Host exe.dev *.exe.xyz
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519
```

## Cross-VM Networking

VMs are isolated from each other, even within one account. Use Tailscale, SSH forwarding, or the HTTP proxy for inter-VM communication.

## Docker

Fully supported on exeuntu images. `docker run --rm alpine:latest echo hello` works out of the box.

## GitHub on VMs

Use HTTPS URLs (not SSH) with fine-grained personal access tokens:
```bash
gh auth login --with-token < token
gh auth setup-git
git clone https://github.com/USER/REPO
```
