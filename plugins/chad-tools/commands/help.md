---
name: help
description: Show chad-tools plugin help
allowed-tools: []
---

Display the following help text to the user:

```
chad-tools — Dev workflow skills and utilities

SKILLS (auto-activate based on context):
  resume-branch       Check rebase status, PR state, orient to current work
  gen-script          Generate standalone bash/python/JS scripts
  crystallize         Turn a repeated pattern into a new skill
  protect-branch      Add branch protection hooks to a repo
  resolve-reviews     Reply to PR review comments and resolve conversations

COMMANDS:
  /chad-tools:review-pr      Multi-agent PR review with inline GH comments
  /chad-tools:pick-next      Prioritize open issues and launch worktrees
  /chad-tools:audit-plugins  Review/test all plugins for accuracy
  /chad-tools:add            Request a new skill (files an issue)
  /chad-tools:issue          Report a bug (gathers context, you review before filing)
  /chad-tools:help           This help text

AGENTS (used by review-pr):
  code-reviewer              Security, correctness, architecture, style (always)
  silent-failure-hunter      Swallowed errors, lost context (if error handling in diff)
  pr-test-analyzer           Test correctness, coverage gaps (if test files in diff)
  comment-analyzer           Doc accuracy, misleading comments (if comments in diff)
  type-design-analyzer       Type design, breaking changes (if types in diff)

USAGE:
  Skills activate automatically. Use commands with /chad-tools:<command>.
```
