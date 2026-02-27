---
name: gh-api-recipes
description: This skill should be used when Claude attempts a gh CLI operation
  that fails because the subcommand doesn't exist, when Claude encounters
  "unknown command" errors from gh, or when the user asks about GitHub
  operations that require `gh api` directly. Common triggers include questions
  about "milestones", "branch protection", "repo topics", "autolinks",
  "deploy keys", "webhooks", "environments", "repository rulesets",
  "repository settings", "collaborators", "repo access", "traffic",
  "repo analytics", "notifications", "GitHub Pages", "actions permissions",
  "GITHUB_TOKEN permissions", "commit statuses", "interaction limits",
  "repository dispatch", "dependabot alerts", "resolve review threads",
  or "resolve conversations". Also applies when the user asks "how do I
  create a milestone with gh", "add a collaborator", "check repo traffic",
  "manage notifications", "set up GitHub Pages", "configure actions
  permissions", "restrict allowed actions", "post a commit status",
  "lock down repo interactions", "trigger a repository dispatch",
  "list dependabot alerts", "dismiss dependabot alert", or "resolve PR
  review conversations".
---

# gh API Recipes

Many GitHub operations don't have dedicated `gh` subcommands and require using `gh api` directly. This skill provides tested recipes for common operations.

## General Pattern

All recipes use `gh api` with REST endpoints. When run inside a git repo with a GitHub remote, `gh api` automatically resolves `:owner/:repo` placeholders:

```bash
# List resources
gh api repos/:owner/:repo/milestones --jq '.[] | [.number, .title, .state, .due_on] | @tsv'

# Create resources
gh api repos/:owner/:repo/milestones -f title="v1.0" -f state=open -f due_on="2026-03-01T00:00:00Z"

# Update resources
gh api -X PATCH repos/:owner/:repo/milestones/1 -f state=closed

# Delete resources
gh api -X DELETE repos/:owner/:repo/milestones/1
```

### Common --jq Patterns

Format output as tables:

```bash
# TSV for simple tables
--jq '.[] | [.field1, .field2] | @tsv'

# Custom formatting
--jq '.[] | "\(.number)\t\(.title)\t\(.state)"'

# Filter results
--jq '[.[] | select(.state == "open")]'

# Count results
--jq 'length'
```

### Pagination

For endpoints that return many results, use `--paginate`:

```bash
gh api repos/:owner/:repo/milestones --paginate --jq '.[] | .title'
```

## Available Recipes

Detailed recipes are in the `references/` directory. Consult these when the user needs help with a specific operation:

- **`references/milestones.md`** — Create, list, update, close, delete milestones; assign issues to milestones
- **`references/collaborators.md`** — Add/remove collaborators, permissions, invitations, team access
- **`references/traffic.md`** — Views, clones, referrers, popular paths (14-day retention)
- **`references/notifications.md`** — List, mark read, subscribe/unsubscribe, watch repos
- **`references/pages.md`** — Enable/disable Pages, source config, custom domains, build status
- **`references/actions-permissions.md`** — Actions enable/disable, allowed actions, GITHUB_TOKEN permissions, runners
- **`references/commit-statuses.md`** — Create/read legacy commit statuses for CI integrations
- **`references/interaction-limits.md`** — Temporarily restrict repo interactions (spam control)
- **`references/repository-dispatch.md`** — Trigger custom events for cross-repo automation
- **`references/dependabot.md`** — List, dismiss, reopen Dependabot vulnerability alerts
- **`references/review-threads.md`** — Resolve/unresolve PR review conversations, reply to threads (GraphQL)
- **`references/repo-settings.md`** — Topics, autolinks, deploy keys, branch protection, rulesets, webhooks, environments, repository visibility

When an operation isn't covered by an existing recipe, construct the `gh api` call from the [GitHub REST API docs](https://docs.github.com/en/rest). The pattern is consistent: identify the endpoint, use `gh api` with the right HTTP method and fields.

## Adding New Recipes

If a recipe is missing, suggest the user run `/gh-recipes:add` to file an issue requesting it be added to the plugin.
