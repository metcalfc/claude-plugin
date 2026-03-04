---
name: done
description: (chad-tools) Mark worktree done for cwprune
allowed-tools:
  - Bash
  - Write
---

Mark this worktree as done and ready for cleanup.

1. First, check if we're in a git worktree by running `git rev-parse --is-inside-work-tree` and `git worktree list`. If the current directory is the main worktree (not a linked worktree), tell the user "Not in a worktree — nothing to mark done." and stop.
2. Use the Write tool to create an empty file called `.cw-done` in the git repo root directory
3. Tell the user the worktree is marked done
4. Tell the user to exit this session and run `cwprune` from the main repo to clean up
