# Claude Code Plugins by Chad Metcalf

A collection of Claude Code plugins for everyday dev workflows. Install one, all, or pick and choose.

## Install

```
/plugin marketplace add metcalfc/claude-plugin
```

Then install the plugins you want:

```
/plugin install chad-tools
/plugin install gh-recipes
/plugin install exe-dev
```

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

- `/gh-recipes:add <description>` — File an issue to request a new recipe

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
| `/chad-tools:add` | File an issue to request a new skill |

---

## exe-dev

**[exe.dev](https://exe.dev) VM management via SSH CLI.**

| Command | What it does |
|---------|-------------|
| `/exe-ls` | List VMs with status |
| `/exe-new` | Create a new VM |
| `/exe-share` | Share a VM |
| `/exe-dev:add` | File an issue to request a new feature |

---

## Contributing

Every plugin has an `/add` command that files an issue on this repo. If Claude can't do something you expected, just run it:

```
/gh-recipes:add Add support for managing GitHub Projects V2 via GraphQL
/chad-tools:add Add a skill for managing git stashes
/exe-dev:add Add support for VM snapshots
```

Or open an issue directly at [github.com/metcalfc/claude-plugin/issues](https://github.com/metcalfc/claude-plugin/issues).
