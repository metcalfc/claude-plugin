---
name: pick-next
description: Suggest open issues to work on next and launch worktrees
allowed-tools:
  - Bash
  - AskUserQuestion
---

Fetch open issues and PRs, prioritize them, let the user pick what to work on, then launch worktrees via `cwm`.

## Step 1: Fetch open issues and PRs

Run both in parallel:

```bash
gh issue list --repo metcalfc/claude-plugin --state open --limit 30 --json number,title,labels,body,updatedAt
```

```bash
gh pr list --repo metcalfc/claude-plugin --state open --limit 10 --json number,title,isDraft,reviewDecision,updatedAt
```

## Step 2: Prioritize

Analyze the fetched issues and PRs. Rank by these criteria (highest priority first):

1. **Open PRs needing review** — non-draft PRs without an approved reviewDecision
2. **Bug-labeled issues** — anything with a `bug` label
3. **Recently active issues** — sort by `updatedAt` descending
4. **Dependency clusters** — group issues that reference each other or could be tackled together

From the ranked list, pick the top 4 candidates. For each, write a one-line rationale explaining why it's a good next pick.

## Step 3: Present choices

Use AskUserQuestion with `multiSelect: true` and up to 4 options. Format each option:

- **label**: `#<number>: <title>` (truncate title to fit)
- **description**: The one-line rationale from the prioritization step

If there are no open issues or PRs, tell the user there's nothing to pick from and stop.

## Step 4: Launch worktrees

Collect the selected issue/PR numbers. Run:

```bash
cwm <number1> <number2> ...
```

This creates worktrees in tmux. If already in a tmux session it attaches; otherwise it creates a new session.

After launching, confirm which worktrees were started.
