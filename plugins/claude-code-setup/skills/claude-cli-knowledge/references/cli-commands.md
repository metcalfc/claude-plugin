# Claude CLI Complete Reference

**TTY Warning:** Most `claude` commands need an interactive terminal. Only `claude -p` (print mode) and non-interactive subcommands (`plugin`, `mcp`, `--version`, `doctor`, `install`, `update`) work without a TTY. Do not run interactive commands from inside a Claude Code session.

## Session Options

| Flag | Description |
|------|-------------|
| `--add-dir <dirs>` | Additional directories to allow tool access |
| `--agent <agent>` | Agent for the session |
| `--agents <json>` | JSON object defining custom agents |
| `--allowedTools <tools>` | Comma/space-separated tool whitelist |
| `--append-system-prompt <prompt>` | Append to default system prompt |
| `--betas <betas>` | Beta headers for API requests |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `-c, --continue` | Continue most recent conversation |
| `--dangerously-skip-permissions` | Bypass all permission checks (sandbox only) |
| `-d, --debug [filter]` | Debug mode with optional category filter |
| `--debug-file <path>` | Write debug logs to file |
| `--disable-slash-commands` | Disable all skills |
| `--disallowedTools <tools>` | Tool denylist |
| `--effort <level>` | Effort level: low, medium, high |
| `--fallback-model <model>` | Fallback model when default is overloaded (with -p) |
| `--file <specs>` | File resources: `file_id:relative_path` |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr [value]` | Resume session linked to a PR |
| `--ide` | Auto-connect to IDE |
| `--include-partial-messages` | Stream partial messages (with -p and stream-json) |
| `--input-format <fmt>` | Input format: text (default), stream-json |
| `--json-schema <schema>` | JSON Schema for structured output |
| `--max-budget-usd <amount>` | Max API spend (with -p) |
| `--mcp-config <configs>` | Load MCP servers from files/strings |
| `--model <model>` | Model: sonnet, opus, haiku, or full name |
| `--no-session-persistence` | Don't save sessions to disk (with -p) |
| `--output-format <fmt>` | Output: text (default), json, stream-json |
| `--permission-mode <mode>` | acceptEdits, bypassPermissions, default, dontAsk, plan |
| `--plugin-dir <paths>` | Load plugins from directories (repeatable) |
| `-p, --print` | Non-interactive: print response and exit |
| `--replay-user-messages` | Re-emit user messages on stdout |
| `-r, --resume [id]` | Resume by session ID or interactive picker |
| `--session-id <uuid>` | Use specific session ID |
| `--setting-sources <sources>` | Comma-separated: user, project, local |
| `--settings <file-or-json>` | Additional settings file or JSON |
| `--strict-mcp-config` | Only use MCP from --mcp-config |
| `--system-prompt <prompt>` | System prompt for session |
| `--tmux` | Create tmux session (with --worktree) |
| `--tools <tools>` | Specify available tools: "", "default", or tool names |
| `--verbose` | Override verbose mode |
| `-v, --version` | Show version |
| `-w, --worktree [name]` | Create git worktree for session |

## Subcommands

### `claude agents [options]`

List configured agents.

### `claude auth`

Manage authentication (interactive — needs TTY).

### `claude doctor`

Health check for auto-updater.

### `claude install [target]`

Install native build. Target: `stable`, `latest`, or specific version.

### `claude mcp`

```
claude mcp add <name> [args]     # Add MCP server
claude mcp remove <name>         # Remove MCP server
claude mcp list                  # List MCP servers
```

### `claude plugin`

```
claude plugin install <name>[@marketplace]    # Install plugin
claude plugin uninstall <name>                # Remove plugin
claude plugin update <name>                   # Update plugin
claude plugin list [--all] [--json]           # List plugins
claude plugin enable <name>                   # Enable plugin
claude plugin disable <name>                  # Disable plugin
claude plugin validate <path>                 # Validate manifest
```

### `claude plugin marketplace`

```
claude plugin marketplace add <source>        # Add marketplace
  --scope <scope>                             # user (default), project, local
  --sparse <paths>                            # Sparse checkout for monorepos
claude plugin marketplace list [--json]       # List marketplaces
claude plugin marketplace remove <name>       # Remove marketplace
claude plugin marketplace update [name]       # Update marketplace(s)
```

**Source format for `marketplace add`:** Just `owner/repo` — no `github:` prefix, no full URL.

### `claude setup-token`

Set up long-lived auth token (needs TTY).

### `claude update`

Check for and install updates (alias: `claude upgrade`).

## Non-Interactive / CI Usage

```bash
# Simple prompt, text output
claude -p "explain this function" < file.py

# Structured JSON output
claude -p "list all TODO items" --output-format json

# Streaming JSON
claude -p "refactor this" --output-format stream-json

# Budget-limited
claude -p "fix all lint errors" --max-budget-usd 0.50

# Specific tools only
claude -p "fix formatting" --allowedTools Edit,Write

# With specific model
claude -p "review this PR" --model opus

# Fallback model for overloaded primary
claude -p "quick fix" --fallback-model haiku
```
