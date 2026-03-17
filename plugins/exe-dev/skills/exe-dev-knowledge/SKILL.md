---
name: exe-dev-knowledge
context: fork
description: >-
  This skill should be used when the user mentions "exe.dev", "exe dev",
  "exe VM", "exe.xyz", or any VM lifecycle operation: "create a VM",
  "delete a VM", "destroy a VM", "stop a VM", "start a VM", "restart a VM",
  "resize a VM", "list my VMs", "list VMs", "list machines", "spin up",
  "tear down", "provision". Also triggers on natural synonyms: "my server",
  "my machine", "remote machine", "dev environment", "cloud VM",
  "virtual machine", "remote dev box", "dev box". Also triggers on
  sharing and networking: "share my server", "make port public",
  "set up custom domain", "configure DNS", "LLM gateway", "proxy port",
  "send email from VM". Also triggers on SSH-related phrases:
  "SSH into my", "SSH proxy", "SSH to my VM", "ssh exe", "connect to my VM",
  "remote into". Also triggers on API and tokens: "exe.dev API",
  "exe0 token", "exe1 token", "API token", "programmatic access".
  Also triggers on templates: "idea template", "exe.new", "VM template".
  Also triggers on IDE integration: "vscode exe", "code server".
  Also triggers when the user mentions Shelley agent or
  works with exe.dev infrastructure in any way. Provides comprehensive
  knowledge of the exe.dev platform, SSH CLI, HTTPS API, HTTP proxy,
  sharing, custom domains, LLM gateway, email, templates, and VM management.
---

# exe.dev Platform Knowledge

exe.dev is a subscription VM service. SSH **is** the CLI — there is no binary to install. VMs get persistent disks, instant HTTPS, and built-in auth. Also has an HTTPS API for programmatic access.

## Documentation

Upstream docs for the latest information:

- Docs index: https://exe.dev/docs.md
- All docs in one page: https://exe.dev/docs/all.md

Detailed reference files in `references/`:
- `api-tokens.md` — HTTPS API endpoint, exe0/exe1 token generation, VM-scoped tokens
- `shelley-details.md` — Full Shelley capabilities, BYOK, subagents, skills, browser profiling
- `idea-templates.md` — Template gallery, available templates, custom images

The reference below covers the full platform. If something seems outdated, fetch the upstream docs.

## Core Concepts

- VMs run on bare metal via Cloud Hypervisor with container images (default: `exeuntu`)
- **Default user is `exedev`** (not root) — home directory is `/home/exedev/`
- Always use `~` or `$HOME` in paths, never hardcode `/root/` or `/home/exedev/`
- VM creation takes ~2 seconds
- Persistent disks survive restarts
- VMs share CPU/RAM within subscription tier
- No dedicated public IP — exe.dev terminates TLS and proxies traffic

## Two SSH Destinations

This is the most important concept. There are two distinct SSH targets:

1. **`ssh exe.dev <command>`** — the **lobby**. A management interface for VM lifecycle, sharing, and configuration. Does not support scp, sftp, or arbitrary shell commands.
2. **`ssh <vmname>.exe.xyz`** — a **direct VM connection**. Full SSH: shell, scp, sftp, port forwarding, everything.

Never mix these up. `scp` and `sftp` only work against `<vmname>.exe.xyz`, not `exe.dev`.

## SSH CLI Reference (Lobby)

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
ssh exe.dev cp <source> <dest>               # clone VM (copy-on-write, near-instant)
ssh exe.dev tag <vmname> <tag>               # tag a VM
```

### Other Lobby Commands

```
ssh exe.dev whoami                           # show account info
ssh exe.dev ssh-key                          # manage SSH keys (add/list)
ssh exe.dev shelley install <vmname>         # upgrade Shelley agent
ssh exe.dev browser <vmname>                 # open VM in browser
ssh exe.dev help                             # show help
ssh exe.dev doc                              # show docs
```

## Connecting to VMs (Direct)

Target `<vmname>.exe.xyz` for shell access and file transfer. You connect as the `exedev` user (home: `/home/exedev/`).

```
ssh <vmname>.exe.xyz                         # SSH into VM (as exedev)
scp <localfile> <vmname>.exe.xyz:~/          # copy file to VM home
scp <vmname>.exe.xyz:~/file <local>          # copy file from VM
```

## Non-Interactive & Agent Environments

Coding agents and sandboxed environments hit common SSH pitfalls:

- **Hung connections**: Non-interactive SSH blocks on host key prompts with no visible output. Use `-o StrictHostKeyChecking=accept-new` on first connection to a new VM.
- **scp/sftp failures**: Ensure you target `<vmname>.exe.xyz`, not `exe.dev`. The lobby does not support file transfer.
- **SSH config**: Both destinations must be configured to use the right key (see SSH Configuration below).
- **JSON output**: Use `--json` with `ls` and `new` for machine-parseable output instead of scraping text.

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
ssh exe.dev share show <vmname>              # view current sharing status
ssh exe.dev share port <vmname> <port>       # change proxy port
```

## Custom Domains

Subdomains: CNAME `app.example.com` → `vmname.exe.xyz`

Apex domains: ALIAS `example.com` → `exe.xyz` + CNAME `www.example.com` → `vmname.exe.xyz`

TLS certificates provisioned automatically.

## LLM Gateway

Built-in proxy to LLM providers at `http://169.254.169.254/gateway/llm/<provider>`. No API keys required. Subscription includes monthly token allocation; additional tokens available as pay-as-you-go credits.

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

Web-based, multi-modal coding agent on all default exeuntu VMs. Open source (github.com/boldsoftware/shelley). Runs on port 9999 at `https://<vmname>.shelley.exe.xyz/`.

Key capabilities: natural language task execution, browser tool with profiling, subagents with context continuation, skills system, conversation distillation (LLM-powered context optimization), diff viewer, HTML iframe output (Vega-Lite, etc.), shell commands in chat (`!bash`, `!git show HEAD`), multi-language support, self-upgrade from UI, BYOK (Anthropic, OpenAI, Gemini, z.ai) or LLM Gateway by default.

Guidance files (priority order): `~/.config/shelley/AGENTS.md` → `AGENTS.md` → `CLAUDE.md` → `DEAR_LLM.md`

Upgrade: `ssh exe.dev shelley install <vmname>` or from Shelley's UI.

See `references/shelley-details.md` for full feature documentation.

## HTTPS API

Programmatic VM management via `POST https://exe.dev/exec` with bearer token auth. The `args` array mirrors the SSH CLI:

```bash
curl -X POST https://exe.dev/exec \
  -H "Authorization: Bearer exe0...." \
  -H "Content-Type: application/json" \
  -d '{"args": ["ls", "--json"]}'
```

Tokens (exe0 format) are generated locally by signing permissions JSON with your SSH key — no web UI needed. Supports expiration, command restrictions, and custom context. VM-scoped tokens work with Bearer and Basic auth (git-compatible).

See `references/api-tokens.md` for token generation, permissions, and VM-scoped tokens.

## Idea Templates

Pre-configured VM templates at `exe.dev/idea` (also `exe.new/<template>`). Templates include a container image and a Shelley prompt that auto-configures the app with auth.

Available: Gitea, VS Code, Ghost, Minecraft, Grafana, Outline, OpenClaw, Marimo, and more. Check `exe.dev/idea` for the current list.

See `references/idea-templates.md` for details.

## VSCode Integration

Connect VS Code directly to a VM:
```
vscode://vscode-remote/ssh-remote+<vmname>.exe.xyz/home/exedev
```

Also available from the exe.dev dashboard.

## Tab Completion

VM name tab completion available for zsh, bash, and fish. Check upstream docs for setup instructions.

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
