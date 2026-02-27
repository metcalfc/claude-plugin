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
```

**Inside Claude Code (slash commands):**

```
/plugin marketplace add metcalfc/claude-plugin
/plugin install gh-recipes
/plugin install chad-tools
/plugin install exe-dev
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

**[exe.dev](https://exe.dev) VM management via SSH CLI.**

| Command | What it does |
|---------|-------------|
| `/exe-ls` | List VMs with status |
| `/exe-new` | Create a new VM |
| `/exe-share` | Share a VM |
| `/exe-dev:status` | Quick health check of all VMs |
| `/exe-dev:add` | Request a new feature |
| `/exe-dev:issue` | Report a bug (gathers context, sanitizes, you review before filing) |
| `/exe-dev:help` | Plugin help |

---

## Contributing

Every plugin has `/help`, `/add`, and `/issue` commands. Request a feature or report a bug right from Claude Code — context is gathered automatically, sensitive data is scrubbed, duplicate issues are checked, and you review before anything gets filed.

```
/gh-recipes:add Add support for managing GitHub Projects V2 via GraphQL
/chad-tools:add Add a skill for managing git stashes
/exe-dev:add Add support for VM snapshots
```

Or open an issue directly at [github.com/metcalfc/claude-plugin/issues](https://github.com/metcalfc/claude-plugin/issues).
