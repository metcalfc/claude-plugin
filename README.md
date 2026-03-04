# Claude Code Plugins

A collection of plugins for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that teach Claude things it doesn't know out of the box — idiomatic shell scripting, GitHub API patterns, full fzf syntax, multi-agent code review, and more.

**The problem:** Claude Code is good at general programming but has blind spots. It writes `bash` when you're in `zsh`. It uses bare `| fzf` without previews. It doesn't know `gh milestone list` isn't a real command. These plugins fix that by giving Claude domain-specific knowledge that activates automatically when relevant.

**How plugins work:** Skills auto-activate based on context (mention a VM and exe-dev kicks in, write a zsh script and zsh-craft takes over). Commands are explicit (`/review`, `/exe-ls`). You install what you need — they're independent.

## Install

Add the marketplace, then install what you want:

```bash
# From the terminal
claude plugin marketplace add metcalfc/claude-plugin
claude plugin install chad-tools
claude plugin install gh-recipes
claude plugin install fzf-power
claude plugin install zsh-craft
claude plugin install exe-dev
claude plugin install claude-code-setup
```

```
# Inside Claude Code
/plugin marketplace add metcalfc/claude-plugin
/plugin install chad-tools
```

---

## chad-tools

**Multi-agent code review and dev workflow automation.**

The headline feature is `/review` — a single command that auto-detects what you've changed (unstaged, staged, last commit), selects the right review agents, runs them in parallel, and either posts a GitHub review (if a PR exists) or reports findings in your terminal. It also reviews PRs by number (`/review #123`).

Five specialized agents, each focused on a different aspect of code quality:

| Agent | Focus | Activates when |
|-------|-------|----------------|
| **code-reviewer** | Security, correctness, architecture, style | Always |
| **silent-failure-hunter** | Swallowed errors, lost context, misleading fallbacks | Error handling in diff |
| **pr-test-analyzer** | Test correctness, coverage gaps, flaky patterns | Test files in diff |
| **comment-analyzer** | Doc accuracy, stale comments, misleading docs | Comments/docstrings in diff |
| **type-design-analyzer** | Type design, breaking changes, leaky abstractions | Type definitions in diff |

Agent selection uses comprehensive trigger patterns across Go, Rust, JS/TS, Python, Ruby, Bash/Zsh, and more. Findings below 80% confidence are filtered. Duplicates are deduplicated. Every comment posted matters.

### Commands

| Command | What it does |
|---------|-------------|
| `/chad-tools:review` | Multi-agent code review — auto-detects scope, posts to PR if one exists |
| `/chad-tools:pick-next` | Prioritize open issues and launch worktrees |
| `/chad-tools:audit-plugins` | Run a review/test cycle across all plugins |

### Skills (auto-activate)

| Skill | What it does |
|-------|-------------|
| **resume-branch** | Check rebase status, PR state, orient to where you left off |
| **gen-script** | Generate standalone bash/python/JS scripts |
| **crystallize** | Turn a repeated pattern into a new Claude Code skill |
| **protect-branch** | Add branch protection hooks to a repo |
| **resolve-reviews** | Reply to PR review comments and resolve conversations |

---

## gh-recipes

**Recipes for `gh` CLI operations that don't have built-in subcommands.**

Ever tried `gh milestone list` and got "unknown command"? This plugin teaches Claude how to use `gh api` for the operations GitHub CLI doesn't cover natively. It auto-activates when Claude hits an unknown `gh` subcommand or when you ask about GitHub operations that need the API directly. Includes a **PostToolUse hook** that detects `gh` errors and nudges toward the right recipe.

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
- `/gh-recipes:add` — Request a new recipe
- `/gh-recipes:issue` — Report a bug
- `/gh-recipes:help` — Plugin help

---

## fzf-power

**Teaches Claude to use fzf's full capabilities instead of bare `| fzf`.**

Without this plugin, Claude writes `something | fzf` and calls it a day. With it, every fzf invocation gets preview windows, keybindings, headers, proper formatting, and theming. Auto-activates whenever Claude writes an interactive script.

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
- `/fzf-power:add` — Request a new recipe or pattern
- `/fzf-power:issue` — Report a bug
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

- `/zsh-craft:add` — Request a new zsh pattern or recipe
- `/zsh-craft:issue` — Report a bug
- `/zsh-craft:help` — Plugin help

---

## exe-dev

**Teaches Claude the [exe.dev](https://exe.dev) platform — instant Linux VMs managed entirely over SSH.**

Without this plugin, Claude doesn't know that `ssh exe.dev new` creates a VM, that `scp` targets `<vm>.exe.xyz` (not `exe.dev`), or that every VM gets automatic HTTPS. With it, Claude understands the full platform and can work with your VMs autonomously. Auto-activates when you mention exe.dev, VMs, or anything `*.exe.xyz`.

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

- `/exe-ls` — List VMs with status
- `/exe-new` — Create a new VM
- `/exe-share` — Share a VM
- `/exe-dev:status` — Quick health check of all VMs
- `/exe-dev:add` — Request a new feature
- `/exe-dev:issue` — Report a bug
- `/exe-dev:help` — Plugin help

---

## claude-code-setup

**Teaches Claude the correct `claude` CLI commands and plugin management lifecycle.**

Without this plugin, Claude says `claude plugins` (wrong — it's singular), uses `github:owner/repo` syntax (wrong — just `owner/repo`), tries to run interactive CLI commands inside a session (fails — no TTY), and doesn't bump plugin versions (users get stale cache). This plugin fixes all of that with a knowledge skill and a PreToolUse hook that catches mistakes before execution.

### What it covers

| Area | What Claude learns |
|------|-------------------|
| **CLI syntax** | Correct subcommands (`plugin` not `plugins`), correct flags, correct argument formats |
| **TTY awareness** | Which commands need a terminal, which work headless, when to suggest `/plugin` instead |
| **Marketplace ops** | `owner/repo` format (no `github:` prefix), `--sparse` for monorepos, `--scope` options |
| **Version bumping** | Must bump in both `plugin.json` and marketplace registry, or users get stale cache |
| **Automation recs** | Codebase analysis for hooks, skills, MCP servers, subagents, and plugins |

### Hook

**PreToolUse on Bash** — catches common mistakes before they execute:
- `claude plugins` → `claude plugin` (singular)
- `marketplace add github:owner/repo` → `marketplace add owner/repo`
- Interactive commands that need a TTY
- Deprecated `--mcp-debug` flag

### Commands

- `/claude-code-setup:add` — Request a new feature
- `/claude-code-setup:issue` — Report a bug
- `/claude-code-setup:help` — Plugin help

---

## Contributing

Every plugin has `/help`, `/add`, and `/issue` commands. Request a feature or report a bug right from Claude Code — context is gathered automatically, sensitive data is scrubbed, duplicate issues are checked, and you review before anything gets filed.

```
/gh-recipes:add Add support for managing GitHub Projects V2 via GraphQL
/chad-tools:add Add a skill for managing git stashes
/exe-dev:add Add support for VM snapshots
/fzf-power:add Add a recipe for browsing AWS S3 buckets
/zsh-craft:add Add coverage for zsh/curses TUI patterns
/claude-code-setup:add Add coverage for claude mcp server management patterns
```

Or open an issue directly at [github.com/metcalfc/claude-plugin/issues](https://github.com/metcalfc/claude-plugin/issues).
