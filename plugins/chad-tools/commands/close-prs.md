---
name: close-prs
description: (chad-tools) Batch merge PRs with cascade rebase
argument-hint: "<pr#> <pr#> ... [--repo owner/repo]"
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - AskUserQuestion
---

Merge a list of PRs sequentially, rebasing the remaining queue after each merge to handle cascading conflicts.

## Step 0: Parse Arguments

`$ARGUMENTS` must contain one or more PR numbers. An optional `--repo owner/repo` flag specifies the target repo.

If `$ARGUMENTS` is empty, use AskUserQuestion to ask "Which PRs should I merge? (space-separated numbers)" and stop.

If `--repo` is not provided, detect it from the current git remote:
```bash
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'
```

Store as `REPO` and pass `--repo $REPO` to all `gh` commands.

## Step 1: Validate and Order PRs

1. Fetch metadata for all specified PRs:
   ```bash
   gh pr view <number> --repo $REPO --json number,title,headRefName,mergeable,state,reviewDecision,additions,deletions
   ```

2. Filter out any PRs that are:
   - Already merged or closed — report and skip
   - Review decision is `CHANGES_REQUESTED` — report and skip

3. Order remaining PRs by total diff size (additions + deletions), smallest first. Smaller PRs merge cleanly and cause fewer cascading conflicts for later PRs.

4. Display the merge queue to the user:
   ```
   Merge queue (smallest first):
   1. #42 — "Fix typo in README" (+3 -1)
   2. #38 — "Add retry logic" (+47 -12)
   3. #35 — "Refactor auth middleware" (+210 -85)
   ```

## Step 2: Clone or Navigate to Repo

If not already in a local clone of `$REPO`:
```bash
WORKDIR=$(mktemp -d)
gh repo clone $REPO "$WORKDIR" -- --depth=50
cd "$WORKDIR"
```

Establish clean baseline:
```bash
DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
git checkout $DEFAULT_BRANCH
git fetch origin
git rebase origin/$DEFAULT_BRANCH
```

Verify working tree is clean. If dirty, abort.

## Step 3: Process Each PR

Work through the queue **sequentially**. For each PR:

### 3a: Checkout and Rebase

```bash
gh pr checkout <number> --repo $REPO
git fetch origin
git rebase origin/$DEFAULT_BRANCH
```

### 3b: Fix Conflicts (if any)

If rebase reports conflicts:

1. Run `git status` to see conflicted files
2. For each conflicted file, read it and resolve conflict markers
3. Classify each conflict:
   - **Trivial**: lock files, import ordering, auto-generated files, whitespace → fix silently
   - **Complex**: logic changes, overlapping edits to the same function → fix, then show the resolution via AskUserQuestion with options: "Looks good, continue" / "Let me fix this manually" / "Skip this PR"
4. After resolving: `git add <files>` then `git rebase --continue`
5. Repeat if rebase has multiple conflict steps

If user says "Skip this PR", abort rebase (`git rebase --abort`), move to next PR.

After conflict resolution, push:
```bash
git push --force-with-lease
```

### 3c: Verify CI

Poll CI status (max 5 checks, 30 seconds apart):
```bash
gh pr checks <number> --repo $REPO --json name,state,conclusion
```

Outcomes:
- **All passing** → proceed to merge
- **Still pending** after max checks → report "CI still running for #N", ask user: "Wait longer" or "Merge anyway" or "Skip this PR"
- **Failure** → attempt one fix:
  1. Read failing check logs via `gh run view <run-id> --log-failed`
  2. Diagnose and fix
  3. Commit, push, re-check (same polling, max 5 checks)
  4. If still failing, report and skip this PR

### 3d: Merge

```bash
gh pr merge <number> --repo $REPO --rebase
```

If merge fails (e.g., branch protection, required reviews), report the error and skip this PR.

### 3e: Cascade Update

After a successful merge, update the baseline for remaining PRs:

```bash
git checkout $DEFAULT_BRANCH
git pull --rebase origin $DEFAULT_BRANCH
```

The next PR in the queue will rebase against this updated main in step 3a.

## Step 4: Cleanup

- If working in a temp clone: `rm -rf "$WORKDIR"`
- If in an existing clone: `git checkout $DEFAULT_BRANCH`

## Step 5: Summary

```
## Close PRs Summary

Merge queue: N PRs

| PR | Title | Result |
|----|-------|--------|
| #42 | Fix typo in README | Merged ✓ |
| #38 | Add retry logic | Merged ✓ (conflicts resolved) |
| #35 | Refactor auth middleware | Skipped — CI failing |

Merged: N/M
Conflicts resolved: N
Skipped: N
```

## Philosophy

- **Smallest first.** Merge the easy ones early — fewer cascading conflicts.
- **One retry, then skip.** Don't get stuck on one PR. Report it and move on.
- **Always `--rebase` merge.** Linear history, per project convention.
- **`--force-with-lease` only.** Never `--force`.
- **Complex conflicts get human eyes.** Show the resolution, don't assume.
- **Leave the worktree clean.** Always return to the default branch.
