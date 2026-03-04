---
name: audit-plugins
description: Review and test gh-recipes, exe-dev, fzf-power, zsh-craft, and claude-code-setup plugins for accuracy
argument-hint: "[gh-recipes|exe-dev|fzf-power|zsh-craft|claude-code-setup|all]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - WebSearch
  - Task
---

Run a review and test cycle on the gh-recipes, exe-dev, fzf-power, zsh-craft, and claude-code-setup plugins to verify recipes are still accurate and discover gaps. Default target is `all`.

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

### 7. Test fzf-power

If fzf-power is in scope:

1. Check `fzf --version` to verify fzf is installed
2. Verify the skill's minimum template works:
   ```bash
   echo -e "test1\ntest2\ntest3" | fzf --version
   ```
3. Test that `--preview` works: run a quick fzf invocation with `--filter=test1` (non-interactive) to verify options are accepted
4. Check if any referenced fzf options have been deprecated by checking `fzf --help` output
5. Verify theme color names are still valid

Report fzf-power results in the same table format.

### 8. Test zsh-craft

If zsh-craft is in scope:

1. Check `zsh --version` to verify zsh is installed
2. Test a few core zsh features the skill teaches:
   ```bash
   zsh -c 'print -P "%F{green}print -P works%f"'
   zsh -c 'zmodload zsh/datetime; print $EPOCHSECONDS'
   zsh -c 'typeset -A m=(a 1 b 2); print ${(k)m}'
   ```
3. Verify parameter expansion examples from the reference files are syntactically correct by running a sample:
   ```bash
   zsh -c 'str="hello world"; print ${(U)str}'
   zsh -c 'arr=(c a b a); print ${(uo)arr}'
   ```
4. Check that zparseopts examples work:
   ```bash
   zsh -c 'zparseopts -D -F -- h=help v=verbose; print "ok"' -- -h -v
   ```
5. Verify glob qualifier syntax with a simple test:
   ```bash
   zsh -c 'setopt EXTENDED_GLOB; print -l *.md(N.om[1,3])' 2>/dev/null
   ```

Report zsh-craft results in the same table format.

### 9. Test claude-code-setup

If claude-code-setup is in scope:

1. Check `claude --version` to verify Claude CLI is installed
2. Verify the correct subcommand names:
   ```bash
   claude plugin --help 2>&1 | head -5
   claude plugin marketplace --help 2>&1 | head -5
   ```
3. Verify the skill's CLI reference matches current `claude --help` output — check for any new subcommands or flags not yet documented
4. Confirm the hook catches known bad patterns by reviewing `hooks/hooks.json` against the current CLI behavior
5. Compare the automation-recommender skill against the upstream version for any drift

Report claude-code-setup results in the same table format.

### 10. Recommended Actions

If any recipes need updating, offer to fix them. If new recipes should be added, offer to create them or suggest running `/gh-recipes:add`, `/fzf-power:add`, `/zsh-craft:add`, or `/claude-code-setup:add`.
