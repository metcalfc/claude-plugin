---
name: claude-cli-knowledge
description: >-
  This skill should be used when Claude is about to run a `claude` CLI command,
  suggests the user run a `claude` CLI command, mentions "claude plugin",
  "claude plugins", "claude mcp", "claude auth", "claude install",
  "plugin marketplace", "marketplace add", installs or manages plugins,
  or discusses plugin versioning. Also triggers when the user says
  "install a plugin", "add a marketplace", "update a plugin", "bump version",
  "plugin version", "plugin cache", "setup-token", "headless auth",
  "CLAUDE_CODE_OAUTH_TOKEN", "authenticate headless", "CI authentication",
  "long-lived token", or when generating or suggesting any `claude` CLI command.
---

# Claude CLI Knowledge

Correct reference for the `claude` command-line interface. Use this knowledge whenever generating, suggesting, or running `claude` CLI commands.

## Critical Rule: TTY Requirement

**The `claude` CLI requires an interactive terminal (TTY).** Claude Code sessions do NOT have a TTY. This means:

- **NEVER run `claude` CLI commands via Bash tool** — they will fail or hang
- **NEVER suggest the user "run this in Claude"** when showing a `claude` CLI command
- **Instead, tell the user to run CLI commands in a separate terminal**

The one exception: `claude -p` (print mode) works without a TTY because it's non-interactive.

### What to Use Inside a Session

Inside a Claude Code session, use the `/plugin` slash command instead of `claude plugin`:

| CLI Command (external terminal) | Session Equivalent |
|---------------------------------|--------------------|
| `claude plugin install <name>` | `/plugin install <name>` |
| `claude plugin list` | `/plugin list` |
| `claude plugin update <name>` | `/plugin update <name>` |
| `claude plugin enable <name>` | `/plugin enable <name>` |
| `claude plugin disable <name>` | `/plugin disable <name>` |
| `claude plugin uninstall <name>` | `/plugin uninstall <name>` |
| `claude plugin marketplace add <source>` | `/plugin marketplace add <source>` |
| `claude plugin marketplace list` | `/plugin marketplace list` |
| `claude plugin marketplace remove <name>` | `/plugin marketplace remove <name>` |
| `claude plugin marketplace update [name]` | `/plugin marketplace update [name]` |

When the user needs to manage plugins from within a session, **always suggest the `/plugin` slash command** rather than a `claude plugin` CLI command.

## Correct CLI Syntax

### Top-Level Commands

```
claude [options] [prompt]           # Start session or run with -p for non-interactive
claude agents [options]             # List configured agents
claude auth                         # Manage authentication
claude doctor                       # Health check for auto-updater
claude install [target]             # Install native build (stable, latest, or version)
claude mcp                          # Configure and manage MCP servers
claude plugin                       # Manage plugins (NOT "plugins" — singular!)
claude setup-token                  # Set up long-lived auth token
claude update                       # Check for and install updates
```

### Common Mistakes

| Wrong | Correct | Why |
|-------|---------|-----|
| `claude plugins` | `claude plugin` | Subcommand is singular |
| `claude plugin add` | `claude plugin install` | Subcommand is `install` not `add` |
| `claude plugin marketplace add github:owner/repo` | `claude plugin marketplace add owner/repo` | No `github:` prefix — just `owner/repo` |
| `claude plugin marketplace add https://github.com/owner/repo` | `claude plugin marketplace add owner/repo` | Use short form, not full URL |
| `claude plugins list` | `claude plugin list` | Singular `plugin` |
| `claude --mcp-debug` | `claude --debug` | `--mcp-debug` is deprecated |

### Plugin Management — `claude plugin`

```
claude plugin install <name>[@marketplace]   # Install from marketplace
claude plugin uninstall <name>               # Remove installed plugin
claude plugin update <name>                  # Update to latest version
claude plugin list [--all] [--json]          # List installed plugins
claude plugin enable <name>                  # Enable a disabled plugin
claude plugin disable <name>                 # Disable without removing
claude plugin validate <path>                # Validate plugin manifest
```

### Marketplace Management — `claude plugin marketplace`

```
claude plugin marketplace add <source>       # Add marketplace (owner/repo format)
claude plugin marketplace list [--json]      # List configured marketplaces
claude plugin marketplace remove <name>      # Remove a marketplace
claude plugin marketplace update [name]      # Update marketplace(s)
```

**The `<source>` argument for `marketplace add`:**
- Use `owner/repo` format (e.g., `metcalfc/claude-plugin`)
- Do NOT use `github:owner/repo` — there is no `github:` prefix
- Do NOT use full URLs — just the short `owner/repo` form
- Use `--scope` to control where it's declared: `user` (default), `project`, or `local`
- Use `--sparse` for monorepos: `--sparse .claude-plugin plugins`

### MCP Management — `claude mcp`

```
claude mcp add <name> [args...]              # Add an MCP server
claude mcp remove <name>                     # Remove an MCP server
claude mcp list                              # List configured MCP servers
```

### Key Flags

| Flag | Purpose | Notes |
|------|---------|-------|
| `-p, --print` | Non-interactive output | Works without TTY, good for scripts/CI |
| `-c, --continue` | Resume last conversation | |
| `-r, --resume [id]` | Resume by session ID | |
| `--model <model>` | Set model (sonnet, opus, haiku) | |
| `-d, --debug [filter]` | Debug mode | Filter: `"api,hooks"`, `"!1p,!file"` |
| `--plugin-dir <path>` | Load plugin from directory | For local testing |
| `--permission-mode <mode>` | Set permissions | acceptEdits, default, plan, etc. |
| `--allowedTools <tools>` | Whitelist tools | Space/comma-separated |
| `--output-format <fmt>` | Output format (with -p) | text, json, stream-json |
| `-w, --worktree [name]` | Create git worktree session | |

## Version Bumping — Critical for Plugin Development

**Every commit that changes a plugin MUST bump its version** in both `plugins/<name>/.claude-plugin/plugin.json` and the marketplace registry file. If the version is not bumped, the plugin manager serves the cached old version and users never receive the update.

After `plugin update`, restart Claude Code — plugins load at session start, not dynamically.

See [references/plugin-lifecycle.md](references/plugin-lifecycle.md) for semver rules, the full cache flow, and validation commands.

## Authentication — `claude setup-token` and Headless Auth

`claude setup-token` generates a **1-year OAuth token** for headless/automated environments. This is the answer when users need Claude Code on remote servers, Docker containers, CI/CD pipelines, or anywhere without a browser.

**Requires:** Claude Pro or Max subscription.

### Setup Flow

1. **On a machine with a browser:** run `claude setup-token`
2. Browser opens for OAuth — authenticate normally
3. Token is displayed once: `sk-ant-oat01-xxxxx...xxxxx`
4. **Store it securely** (password manager, CI secrets, etc.)

### Using the Token

Set the `CLAUDE_CODE_OAUTH_TOKEN` environment variable:

```bash
export CLAUDE_CODE_OAUTH_TOKEN="sk-ant-oat01-your-token-here"
```

Claude Code automatically uses this token instead of interactive browser auth. No `/login` needed.

### Common Use Cases

| Scenario | How |
|----------|-----|
| **Remote SSH server** | Add `export CLAUDE_CODE_OAUTH_TOKEN=...` to `~/.bashrc` (mode 0600) |
| **Docker container** | Pass as env var: `docker run -e CLAUDE_CODE_OAUTH_TOKEN=... image` |
| **GitHub Actions** | Store as repository secret, reference in workflow |
| **CI/CD pipelines** | Store in your CI's secrets manager |
| **Cloud IDEs** | Set in workspace environment variables |

### Important Rules

- **Never set both** `CLAUDE_CODE_OAUTH_TOKEN` and `ANTHROPIC_API_KEY` simultaneously — causes auth conflicts
- `CLAUDE_CODE_OAUTH_TOKEN` takes precedence over credentials in `~/.claude/.credentials.json`
- Token expires after 1 year — regenerate with `claude setup-token` before expiration
- `claude setup-token` itself needs a TTY (browser) — run it locally, use the token remotely
- For API key auth (Console users), use `ANTHROPIC_API_KEY` instead

### Alternative: API Key Auth

For Console/API users (not Pro/Max subscribers):

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
claude -p "your prompt here"
```

This works for `claude -p` (print mode) in CI pipelines. For interactive sessions, use `CLAUDE_CODE_OAUTH_TOKEN`.

See [references/cli-commands.md](references/cli-commands.md) for all authentication-related flags and environment variables.

## Local Plugin Testing

Test a plugin without installing it:

```bash
# In an external terminal (needs TTY):
claude --plugin-dir /path/to/plugin-name

# Or for the /plugin slash command approach inside a session,
# the plugin must be installed first
```

For debug output including hook execution:

```bash
claude --debug                    # to stdout
claude --debug-file /tmp/debug.log  # capture to file for async review
```

## Reference Files

- [references/cli-commands.md](references/cli-commands.md) — Complete CLI command reference with all flags
- [references/plugin-lifecycle.md](references/plugin-lifecycle.md) — Plugin install, update, cache, and versioning lifecycle
