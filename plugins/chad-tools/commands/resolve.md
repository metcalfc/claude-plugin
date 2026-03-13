---
name: resolve
description: (chad-tools) Fix PR review findings, push, resolve threads, verify CI
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - Skill
---

Fix code issues flagged by PR review comments, push the fixes, verify CI, then delegate to `resolve-reviews` for thread bookkeeping.

## Phase 1: Gather Context

1. Get the PR number:
   ```bash
   gh pr view --json number --jq '.number'
   ```

2. Get repo owner and name:
   ```bash
   gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'
   ```

3. Fetch all top-level review comments (these are the findings — exclude reply-to-reply threads):
   ```bash
   gh api repos/{owner}/{repo}/pulls/{pr}/comments --jq '[.[] | select(.in_reply_to_id == null) | {id: .id, path: .path, line: .line, original_line: .original_line, body: .body, author: .user.login, diff_hunk: .diff_hunk}]'
   ```

4. If there are zero comments, report "No review comments found" and stop.

5. Read any CLAUDE.md files in the repo root for project conventions.

## Phase 2: Triage Each Comment

For each top-level review comment:

1. Read the file at the path mentioned in the comment. Use the `line` (or `original_line`) and `diff_hunk` to locate the exact code.

2. Check if a commit already addresses the finding — look at commits since the review was posted:
   ```bash
   git log --oneline --since="<comment_created_at>" -- <path>
   ```
   Read those diffs to see if they fix the issue.

3. Classify the comment into one of three dispositions:

   - **Already Fixed** — a commit already addresses it. Record the SHA.
   - **Needs Fix** — valid finding, code still has the issue.
   - **Reject** — doesn't apply or is incorrect. Record the reason.

Log each classification so the summary is accurate.

## Phase 3: Apply Fixes

**Scope constraint (critical):** Only fix what reviewers flagged. No feature additions, no nearby refactoring, no pre-existing issues, no style changes beyond what was called out. If a comment asks for something out of scope, classify it as Reject with a reason.

For each "Needs Fix" item:

1. Read the relevant file and surrounding context.
2. Make the minimal edit that addresses the reviewer's concern.
3. Verify the edit is correct by re-reading the file.

After all fixes are applied:

1. If there are zero "Needs Fix" items, skip to Phase 5 (no commit needed).

2. Stage only the changed files:
   ```bash
   git add <file1> <file2> ...
   ```

3. Create a single commit with a body listing what was fixed:
   ```bash
   git commit -m "fix: address PR review feedback

   - <brief description of fix 1>
   - <brief description of fix 2>
   ..."
   ```

4. Push:
   ```bash
   git push
   ```

## Phase 4: Verify CI

Only run this phase if fixes were pushed in Phase 3.

Poll CI status (max 5 checks, 30 seconds apart):

```bash
gh pr checks {pr} --json name,state,conclusion
```

Outcomes:

- **All passing** — continue to Phase 5.
- **Still pending** after max checks — report "CI still running" and continue to Phase 5. The `/done` gate will catch it.
- **Failure** — attempt one fix cycle:
  1. Read the failing check logs:
     ```bash
     gh run view <run-id> --log-failed
     ```
  2. Diagnose and fix the issue.
  3. Commit: `fix: address CI failure from review fixes`
  4. Push and re-check CI (same polling loop, max 5 checks).
  5. If CI fails a second time, report "CI still failing after one retry" and continue to Phase 5. Do not loop further.

## Phase 5: Delegate to Skill

Invoke the `resolve-reviews` skill to handle the bookkeeping:
- Reply to each comment with disposition + commit SHA
- Resolve all review threads via GraphQL

Use the Skill tool:
```
skill: "resolve-reviews"
```

The skill runs at haiku tier and handles all GitHub API calls for replies and thread resolution.

## Phase 6: Summary

Report a final summary:

```
## Review Resolution

- **Comments found:** N
- **Already fixed:** N (before this run)
- **Newly fixed:** N (this run)
- **Rejected:** N
- **CI status:** passing / pending / failing

Threads resolved via resolve-reviews skill.
```
