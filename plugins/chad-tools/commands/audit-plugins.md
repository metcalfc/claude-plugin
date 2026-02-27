---
name: audit-plugins
description: Review and test gh-recipes and exe-dev plugins for accuracy
argument-hint: "[gh-recipes|exe-dev|all]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - WebSearch
  - Task
---

Run a review and test cycle on the gh-recipes and exe-dev plugins to verify recipes are still accurate and discover gaps. Default target is `all`.

## Workflow

### 1. Check gh CLI version and built-in commands

Run `gh --version` and `gh help` to get the current list of built-in subcommands. Compare against gh-recipes — if any recipe now covers something that has a built-in subcommand, flag it as potentially redundant.

### 2. Test gh-recipes endpoints

For each reference file in the gh-recipes skill, pick 1-2 read-only (GET) commands and run them against the current repo to verify they still work. Do NOT run any write operations (POST, PUT, PATCH, DELETE).

Examples of safe test commands:
- `gh api repos/:owner/:repo/milestones --jq 'length'`
- `gh api repos/:owner/:repo/collaborators --jq 'length'`
- `gh api repos/:owner/:repo/traffic/views --jq '.count'`
- `gh api repos/:owner/:repo/actions/permissions`
- `gh api repos/:owner/:repo/dependabot/alerts -f state=open --jq 'length'`

If an endpoint returns an error, note it. Common issues:
- 404: endpoint may have changed or feature not enabled on this repo
- 403: insufficient permissions (note but don't fail)
- Changed response format: flag for recipe update

### 3. Check for new gh CLI features

Search the web for recent GitHub CLI changelog / release notes to see if new subcommands have been added that overlap with existing recipes or fill gaps we should know about.

### 4. Test exe-dev commands

If exe-dev is in scope, run `ssh exe.dev ls --json 2>/dev/null` to verify the SSH CLI still responds. Check if the command format has changed.

### 5. Check for missing recipes

Search the web for commonly requested `gh api` operations and compare against what gh-recipes already covers. Note any high-demand gaps.

### 6. Report

Present a summary table:

```
## Audit Results

### gh-recipes
| Recipe | Status | Notes |
|--------|--------|-------|
| milestones | OK | Endpoints working |
| collaborators | OK | |
| ... | ... | ... |

### Redundancy Check
- No built-in subcommands overlap with recipes (or list any that do)

### Gaps Found
- [any new high-demand operations not yet covered]

### exe-dev
| Command | Status | Notes |
|---------|--------|-------|
| exe-ls | OK | SSH CLI responding |
| ... | ... | ... |

### Recommended Actions
- [specific items to update or add]
```

If any recipes need updating, offer to fix them. If new recipes should be added, offer to create them or suggest running `/gh-recipes:add`.
