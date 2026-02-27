---
name: help
description: Show gh-recipes plugin help
allowed-tools: []
---

Display the following help text to the user:

```
gh-recipes — Recipes for gh CLI operations without built-in subcommands

RECIPES (auto-activates when you hit a missing gh subcommand):
  milestones          Create, list, update, close, delete; assign to issues
  collaborators       Add/remove, permissions, invitations, team access
  traffic             Views, clones, referrers, popular paths
  notifications       List, mark read, subscribe/unsubscribe, watch repos
  pages               Enable/disable, source config, custom domains
  actions-permissions Enable/disable Actions, allowed actions, token scope
  commit-statuses     Create/read legacy commit statuses
  interaction-limits  Lock down repo interactions (spam control)
  repository-dispatch Trigger custom events for cross-repo automation
  dependabot          List, dismiss, reopen vulnerability alerts
  review-threads      Resolve/unresolve PR review conversations
  repo-settings       Topics, autolinks, deploy keys, protection, webhooks

COMMANDS:
  /gh-recipes:list    Show all available recipes
  /gh-recipes:add     Request a new recipe (files an issue)
  /gh-recipes:issue   Report a bug (gathers context, you review before filing)
  /gh-recipes:help    This help text

USAGE:
  Just ask about any GitHub operation — the plugin activates automatically.
  Examples: "list milestones", "add a collaborator", "check repo traffic"
```
