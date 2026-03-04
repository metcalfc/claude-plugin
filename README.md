# Claude Code Plugins by Chad Metcalf

A collection of Claude Code plugins for everyday dev workflows. Install one, all, or pick and choose.

## Install

Add the marketplace and install the plugins you want. Works from the terminal or inside Claude Code:

**From the terminal:**

```bash
claude plugin marketplace add metcalfc/claude-plugin
claude plugin install gh-recipes
claude plugin install chad-tools
claude plugin install exe-dev
claude plugin install fzf-power
claude plugin install zsh-craft
```

**Inside Claude Code (slash commands):**

```
/plugin marketplace add metcalfc/claude-plugin
/plugin install gh-recipes
/plugin install chad-tools
/plugin install exe-dev
/plugin install fzf-power
/plugin install zsh-craft
```

Install one, all, or pick and choose — they're independent.

---

## gh-recipes

**Recipes for `gh` CLI operations that don't have built-in subcommands.**

Ever tried `gh milestone list` and got "unknown command"? This plugin teaches Claude how to use `gh api` for the operations GitHub CLI doesn't cover natively. It automatically activates when Claude hits an unknown `gh` subcommand or when you ask about GitHub operations that need the API directly.

### What's covered

| Recipe | What it does |
|--------|-------------|
| **Milestones** | Create, list, update, close, delete milestones; assign issues |
| **Collaborators** | Add/remove repo collaborators, permissions, team access, invitations |
| **Traffic** | Views, clones, referrers, popular paths (14-day retention — export or lose it) |
| **Notifications** | List, mark read, subscribe/unsubscribe, watch/unwatch repos |
| **GitHub Pages** | Enable/disable, set source branch, custom domains, build status |
| **Actions Permissions** | Enable/disable Actions, restrict allowed actions, GITHUB_TOKEN scope |
| **Commit Statuses** | Create/read legacy commit statuses for custom CI integrations |
| **Interaction Limits** | Temporarily lock down repo interactions (spam control) |
| **Repository Dispatch** | Trigger custom events for cross-repo automation |
| **Dependabot** | List, dismiss, reopen vulnerability alerts; enable/disable Dependabot |
| **Review Threads** | Resolve/unresolve PR review conversations, reply to threads |
| **Repo Settings** | Topics, autolinks, deploy keys, branch protection, rulesets, webhooks, environments |

### Commands

- `/gh-recipes:list` — Show all available recipes
- `/gh-recipes:add <description>` — Request a new recipe
- `/gh-recipes:issue <what went wrong>` — Report a bug (gathers context, sanitizes, you review before filing)
- `/gh-recipes:help` — Plugin help

Also includes a **PostToolUse hook** that automatically detects `gh` "unknown command" errors and nudges toward the right recipe.

---

## chad-tools

**Personal dev workflow skills.**

| Skill | What it does |
|-------|-------------|
| `/resume-branch` | Check rebase status, PR state, orient to where you left off |
| `/gen-script` | Generate standalone bash/python/JS scripts |
| `/crystallize` | Turn a repeated pattern into a new skill |
| `/protect-branch` | Add branch protection hooks to a repo |
| `/resolve-reviews` | Reply to PR review comments and resolve conversations |
| `/chad-tools:audit-plugins` | Run a review/test cycle on gh-recipes and exe-dev |
| `/chad-tools:add` | Request a new skill |
| `/chad-tools:issue` | Report a bug (gathers context, sanitizes, you review before filing) |
| `/chad-tools:help` | Plugin help |

---

## exe-dev

**Teaches Claude the [exe.dev](https://exe.dev) platform — instant Linux VMs managed entirely over SSH.**

Without this plugin, Claude doesn't know that `ssh exe.dev new` creates a VM, that `scp` targets `<vm>.exe.xyz` (not `exe.dev`), or that every VM gets automatic HTTPS. With it, Claude understands the full platform and can work with your VMs autonomously. The skill auto-activates when you mention exe.dev, VMs, or anything `*.exe.xyz`.

### Platform knowledge

| Area | What Claude knows |
|------|-------------------|
| **Two SSH destinations** | The lobby (`ssh exe.dev`) for management vs direct VM access (`ssh <vm>.exe.xyz`) — and when to use which |
| **VM lifecycle** | Create, list, restart, rename, clone, delete VMs |
| **File transfer** | `scp`/`sftp` to the right destination, not the lobby |
| **HTTP proxy & TLS** | Automatic HTTPS at `<vm>.exe.xyz`, port forwarding 3000-9999, proxy headers, auth URLs |
| **Sharing & access** | Public/private, email invites, share links, per-port control |
| **Custom domains** | CNAME/ALIAS setup with automatic TLS |
| **LLM gateway** | Built-in proxy to Anthropic, OpenAI, Fireworks — no API keys on VMs |
| **Email** | Send/receive via the internal gateway |
| **Shelley** | Web-based coding agent on every VM, guidance files, upgrades |
| **Agent-safe SSH** | Host key prompts, non-interactive pitfalls, `--json` output for machine parsing |

### Commands

Convenience shortcuts — the skill handles most things automatically, but these are handy for quick operations:

- `/exe-ls` — List VMs with status
- `/exe-new` — Create a new VM
- `/exe-share` — Share a VM
- `/exe-dev:status` — Quick health check of all VMs
- `/exe-dev:add` — Request a new feature
- `/exe-dev:issue` — Report a bug
- `/exe-dev:help` — Plugin help

---

## fzf-power

**Teaches Claude to use fzf's full capabilities instead of bare `| fzf`.**

Without this plugin, Claude writes `something | fzf` and calls it a day. With it, every fzf invocation gets preview windows, keybindings, headers, proper formatting, and theming. The skill auto-activates whenever Claude writes an interactive script.

### What it teaches

| Capability | What Claude learns |
|------------|-------------------|
| **Preview windows** | `--preview` with context-appropriate commands (bat for files, git show for commits, docker inspect for containers) |
| **Keybindings** | `--bind` actions: reload, become, execute, mode switching, preview cycling |
| **Theming** | `--color` with 8 built-in themes (Gruvbox, Catppuccin, Tokyo Night, Nord, Dracula, One Dark, Solarized, Rose Pine) |
| **Advanced patterns** | Ripgrep launcher, bidirectional mode toggle, state switching, live reload |
| **Real-world recipes** | Git branch picker, commit browser, docker management, k8s pod browser, process killer, file browser |

### Commands

- `/fzf-power:theme` — Browse and apply fzf color themes to your shell profile
- `/fzf-power:add <description>` — Request a new recipe or pattern
- `/fzf-power:issue <what went wrong>` — Report a bug
- `/fzf-power:help` — Plugin help

---

## zsh-craft

**Teaches Claude to write idiomatic zsh — not bash with a `#!/bin/zsh` shebang.**

Without this plugin, Claude writes bash-in-disguise: `echo | grep`, `getopts`, `cat file`, `stat -c`, `date +%s`, and arrays indexed from 0. With it, Claude reaches for parameter expansion flags, zparseopts, glob qualifiers, `print -P`, zsh modules, and all the features that make zsh a different language from bash.

### What it teaches

| Area | What Claude learns |
|------|-------------------|
| **Parameter expansion** | 40+ composable flags: `(f)` split, `(s:,:)` split on delim, `(U)` uppercase, `(u)` unique, `(o)` sort, `(P)` indirect, `(q)` quote |
| **zparseopts** | Native arg parsing with long options, boolean flags, required/optional args — no getopts/getopt/while-shift |
| **print builtin** | `-P` for prompt colors, `-f` for printf, `-l` per-line, `-C` columns, `-v` to variable — replaces echo and printf |
| **Glob qualifiers** | `(.)` files, `(/)` dirs, `(m-1)` modified today, `(Lm+10)` >10MB, `(om)` sort by mtime — replaces find entirely |
| **String ops** | Replace grep, sed, awk, cut, tr, wc with pure zsh parameter expansion |
| **Modules** | `zsh/datetime` (no date), `zsh/stat` (no stat), `zsh/mapfile` (no cat), `zsh/mathfunc` (no bc), `zsh/pcre` |

### Commands

- `/zsh-craft:add <description>` — Request a new zsh pattern or recipe
- `/zsh-craft:issue <what went wrong>` — Report a bug
- `/zsh-craft:help` — Plugin help

---

## Contributing

Every plugin has `/help`, `/add`, and `/issue` commands. Request a feature or report a bug right from Claude Code — context is gathered automatically, sensitive data is scrubbed, duplicate issues are checked, and you review before anything gets filed.

```
/gh-recipes:add Add support for managing GitHub Projects V2 via GraphQL
/chad-tools:add Add a skill for managing git stashes
/exe-dev:add Add support for VM snapshots
/fzf-power:add Add a recipe for browsing AWS S3 buckets
/zsh-craft:add Add coverage for zsh/curses TUI patterns
```

Or open an issue directly at [github.com/metcalfc/claude-plugin/issues](https://github.com/metcalfc/claude-plugin/issues).
