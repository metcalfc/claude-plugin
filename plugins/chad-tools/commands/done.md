---
name: done
description: (chad-tools) Mark worktree done for cleanup
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

Mark this worktree as done and ready for cleanup. **This command enforces completion gates — it will block until all gates pass.**

1. First, check if we're in a git worktree by running `git rev-parse --is-inside-work-tree` and `git worktree list`. If the current directory is the main worktree (not a linked worktree), tell the user "Not in a worktree — nothing to mark done." and stop.

2. **Detect worktree mode.** Check for a `den-issue` file in the git worktree metadata directory (the path from `git rev-parse --git-dir`, then look for a `den-issue` file there). Also check if the `$DEN_TARGET` env var is set or the cwd matches `*-worktrees/*`.

   - **Den-managed**: `den-issue` file exists, OR `$DEN_TARGET` is set, OR cwd matches `*-worktrees/*`. Read the issue number from `den-issue` if present.
   - **Lite**: None of the above. This is a Claude-managed worktree (created via `EnterWorktree` or manual `git worktree add`).

3. **Completion gates** — check ALL of these before proceeding. If any gate fails, fix it and re-check. Do NOT skip gates or ask the user to skip them.

   **Gate 1: CI is green.**
   Run `gh pr checks $(gh pr view --json number --jq .number)` to check CI status. If any check is still running, wait and re-check. If any check has failed, investigate the failure (read the logs with `gh run view <id> --log-failed`), fix the issue, push, and re-check. Do not proceed with a red build.

   **Gate 2: No merge conflicts.**
   Run `git fetch origin main && git rebase origin/main`. If there are conflicts, resolve them, push the rebased branch, and re-verify CI (gate 1 again).

   **Gate 3: Review feedback resolved.**
   Run `gh api repos/{owner}/{repo}/pulls/{pr}/comments --jq '[.[] | select(.in_reply_to_id == null)] | length'` to check for review comments. If there are unresolved review threads, address every one: fix it, reject it with a reason, or file a tracking issue. Use /resolve-reviews to reply and resolve threads. "Acknowledged" or "will look at later" are not valid dispositions.

   If all gates pass, tell the user: "All gates green — CI passing, no conflicts, reviews resolved."

4. Produce a structured summary. Review the work done in this session by looking at the git log for this branch (commits since diverging from the default branch). Organize the summary into these sections:

   **## Summary**
   What was done — 2-3 bullet points max.

   **## Learnings** (only if applicable)
   Anything surprising discovered during implementation — unexpected complexity, undocumented behavior, tech debt found, assumptions that turned out wrong. Skip this section if there's nothing notable.

   **## Follow-up work** (only if applicable)
   If the implementation revealed work that still needs to be done — related issues to file, TODOs left in code, things intentionally deferred. Skip if the work is fully complete.

   **## Questions for review** (only if applicable)
   Specific things the reviewer should pay attention to — risky changes, design decisions that could go either way, areas where you're least confident. Skip if straightforward.

   **## New questions** (only if applicable)
   Questions that came up during implementation that the user should think about. These are broader than review concerns — architectural questions, product decisions, etc. Use AskUserQuestion for anything blocking; this section is for non-blocking open questions.

4. If you found an issue number in step 2, post the summary as a comment on the issue using `gh issue comment <number> --body '...'`. This creates a durable record.

5. **Cleanup — depends on worktree mode.**

   **Den-managed:** Use the Write tool to create an empty file called `.den-done` in the git repo root directory. Display the summary and tell the user to exit this session and run `den prune` from the main repo to clean up.

   **Lite:** Display the summary and tell the user the worktree is done. Tell them to run `ExitWorktree` (or just exit the session) — the worktree will be cleaned up automatically. Do NOT create `.den-done`.
