---
name: babysit-prs
description: (chad-tools) Rebase conflict-blocked PRs, fix conflicts, review, push, verify CI
argument-hint: "<owner/repo>"
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - Agent
  - Skill
  - AskUserQuestion
  - WebFetch
---

Automated PR maintenance loop. Finds open PRs blocked by merge conflicts, rebases them, fixes conflicts, reviews the fix, and pushes. Designed to be run with `/loop` (e.g., `/loop 10m /chad-tools:babysit-prs continuedev/continue`).

## Step 0: Resolve Target Repo

`$ARGUMENTS` is required and must be an `owner/repo` string (e.g., `continuedev/continue`).

If `$ARGUMENTS` is empty, use AskUserQuestion to ask "Which repo?" and stop.

Store the repo as `REPO` and pass `--repo $REPO` to all `gh` commands throughout this workflow.

Clone the repo into a temp directory if not already local:

```bash
WORKDIR=$(mktemp -d)
gh repo clone $REPO "$WORKDIR" -- --depth=50
cd "$WORKDIR"
```

If the repo is already cloned locally (check `gh repo view $REPO --json url --jq .url` against git remotes in cwd), use the local clone instead of creating a temp one.

### Establish clean baseline

Before doing anything else, get onto a clean, up-to-date default branch:

1. Detect the default branch:
   ```bash
   git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
   ```
2. Check out the default branch and pull latest:
   ```bash
   git checkout <default-branch>
   git fetch origin
   git rebase origin/<default-branch>
   ```
3. Verify the working tree is clean (`git status --porcelain`). If dirty, abort with a message — don't process PRs from a dirty state.

Record `DEFAULT_BRANCH` for use in later steps. All PR checkouts branch off from this clean state.

## Step 1: Find Blocked PRs

Get open PRs and their mergeable status:

```bash
gh pr list --repo $REPO --state open --json number,title,headRefName,mergeable,reviewDecision,statusCheckRollup --limit 50
```

Filter to PRs where:
- `mergeable` is `"CONFLICTING"`
- `reviewDecision` is `"APPROVED"` or `""` (no reviews requested)
- Status checks are passing or neutral (ignore merge-conflict-related failures)

If no PRs match, report "No conflict-blocked PRs found" and stop.

List the matching PRs (number + title) so the user can see what's being processed.

## Step 2: Process Each PR

Work through the filtered PRs **one at a time**, sequentially. For each PR:

### 2a: Setup

```bash
gh pr checkout <number> --repo $REPO
git fetch origin
```

Determine the base branch from the PR metadata (`baseRefName`). Then rebase:

```bash
git rebase origin/<base-branch>
```

### 2b: Fix Merge Conflicts

If rebase reports conflicts:

1. Run `git status` to see conflicted files
2. For each conflicted file, read the file and resolve the conflict markers
3. Classify each conflict:
   - **Trivial**: lock files, import ordering, auto-generated files, whitespace-only → fix silently
   - **Complex**: logic changes, overlapping edits to the same function, structural changes → fix, then show the diff to the user via AskUserQuestion with options: "Looks good, continue" or "Let me fix this manually" or "Skip this PR"
4. After resolving all conflicts: `git add <files>` then `git rebase --continue`
5. If rebase has multiple conflict steps, repeat until complete

If the user says "Skip this PR", abort the rebase (`git rebase --abort`) and move to the next PR.

### 2c: Review the Conflict Resolution

Run `/review` on the changes introduced by the conflict resolution. The review scope is the diff between the original HEAD and the new rebased HEAD — use the commit range.

If `/review` produces **Fix Now** items, fix them.

### 2d: Simplify Gate

Run `/simplify` as a second review pass on the same changes. Fix anything it flags.

### 2e: Push

Force push with lease (safe for rebased branches):

```bash
git push --force-with-lease
```

### 2f: Wait for CI

Check CI status in a loop (max 5 checks, 60 seconds apart):

```bash
gh pr checks <number> --repo $REPO --json name,state,conclusion
```

Outcomes:
- **All passing** → PR is unblocked. Log success, move to the next PR.
- **Still pending** after max checks → Log "CI still running for #N", move on. It'll be rechecked next loop cycle.
- **Failure** → go to Step 3.

## Step 3: CI Failure Recovery

If CI fails after pushing:

1. Read the failing check details:
   ```bash
   gh pr checks <number> --repo $REPO --json name,state,conclusion,detailsUrl
   ```
2. Fetch the failure logs if possible (use the detailsUrl or `gh run view`)
3. Diagnose and fix the issue
4. Run `/simplify` on the fix (this is the second-pass reviewer — fresh eyes, no memory of the first review)
5. If `/simplify` has feedback, fix it
6. Commit the fix, then `git push --force-with-lease`
7. Go back to Step 2f (wait for CI) — but only retry **once**. If CI fails a second time, log "CI still failing for #N after fix attempt" and move to the next PR.

## Step 4: Cleanup

After processing all PRs (or if none were found):

- If working in a temp clone, delete it: `rm -rf "$WORKDIR"`
- If working in an existing local clone, return to the default branch: `git checkout $DEFAULT_BRANCH`

## Step 5: Summary

Report what happened:
- PRs processed (number + title)
- For each: outcome (unblocked / CI pending / CI failed / skipped)
- Conflict complexity (trivial vs. complex) per PR
- Any PRs that need manual attention

## Philosophy

- **Don't break things.** `--force-with-lease` not `--force`. Review gates before every push.
- **Trivial conflicts are trivial.** Don't waste the user's time on lock file conflicts.
- **Complex conflicts deserve eyes.** Show the user anything that touches real logic.
- **One retry, then move on.** Don't get stuck in a fix loop on one PR. Flag it and continue.
- **Leave the worktree clean.** Always return to the original branch.
