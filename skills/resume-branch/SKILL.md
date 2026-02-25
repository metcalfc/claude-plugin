---
name: resume-branch
description: Resume work on a feature branch. Checks rebase status,
  shows recent commits, and orients to current state. Use when starting
  or resuming work on any non-default branch, or when the user says
  things like "where was I", "pick up where I left off", "continue
  working on this branch".
---

When resuming work on a branch:

1. Identify the default branch (check for `main`, fall back to `master`)
2. Run `git fetch origin`
3. Check if current branch is behind default:
   `git log HEAD..origin/<default> --oneline`
4. If behind: warn and ask whether to rebase now
5. Show the last 5 commits on this branch:
   `git log --oneline -5`
6. Check for an open PR:
   `gh pr view --json state,url,title 2>/dev/null`
7. Check for uncommitted changes:
   `git status --short`
8. Summarize in a compact format:
   - Branch: name
   - Rebase needed: yes/no (N commits behind)
   - PR: url or "none"
   - Uncommitted changes: yes/no
   - Last commit: message
