# Idea Templates

exe.dev provides a gallery of pre-configured VM templates for common use cases.

## Access

- **Gallery**: https://exe.dev/idea
- **Direct launch**: `exe.new/<template-name>` (e.g., `exe.new/gitea`)

## How Templates Work

Each template includes:
1. A container image (or the default exeuntu)
2. A tailored Shelley prompt that sets up the app automatically
3. Pre-configured auth and networking

When you launch a template, Shelley runs the setup prompt to install and configure the application, including wiring up exe.dev's built-in authentication.

## Available Templates (as of March 2026)

| Template | Description |
|----------|-------------|
| Gitea | Self-hosted Git service |
| VS Code | Code Server (VS Code in browser) |
| Ghost | Publishing platform |
| Minecraft | Minecraft server |
| Grafana | Monitoring dashboards |
| Outline | Team wiki/knowledge base |
| OpenClaw | AI agent framework |
| Marimo | Python notebook (`--image=ghcr.io/marimo-team/marimo:latest-sql`) |

Template availability changes — check `exe.dev/idea` for the current list.

## Custom Images

Beyond templates, create VMs from any container image:

```bash
ssh exe.dev new --image=ghcr.io/marimo-team/marimo:latest-sql
ssh exe.dev new --image=ubuntu:24.04
```

The image must be publicly accessible or from a registry you've authenticated with.

## Use Cases

- **Quick demos**: Spin up a pre-configured app in seconds for a demo or evaluation
- **Self-hosted tools**: Run Gitea, Outline, or Ghost as your own instance with built-in auth
- **Game servers**: Minecraft and other game servers with instant HTTPS and sharing
- **Development environments**: VS Code Server for browser-based development from any device
