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
  /chad-tools:audit-plugins  Review/test gh-recipes and exe-dev for accuracy
  /chad-tools:add            Request a new skill (files an issue)
  /chad-tools:issue          Report a bug (gathers context, you review before filing)
  /chad-tools:help           This help text

USAGE:
  Skills activate automatically. Use commands with /chad-tools:<command>.
```
