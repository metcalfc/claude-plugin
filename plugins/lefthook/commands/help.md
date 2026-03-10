---
name: help
description: (lefthook) Plugin help
allowed-tools: []
---

Display the following help text to the user:

```
lefthook — Git hooks expertise and setup wizard

SKILLS (auto-activate based on context):
  lefthook-mastery    Deep lefthook configuration knowledge — hook types,
                      job options, file placeholders, parallel execution,
                      and best practices

COMMANDS:
  /lefthook:punch     Analyze repo and interactively set up lefthook guardrails
  /lefthook:setup     Configure a shared lefthook config repo for this project
  /lefthook:add       Request a new feature (files an issue)
  /lefthook:issue     Report a bug (gathers context, you review before filing)
  /lefthook:help      This help text

USAGE:
  The lefthook-mastery skill activates automatically when you're working
  with lefthook configs or discussing git hooks.

  Use /lefthook:punch in any repo to get an interactive setup wizard that
  detects your project type, finds existing linters/formatters/test runners,
  and generates a lefthook.yml with the hooks you choose.

SHARED CONFIG:
  If your org has a shared lefthook config repo, run:
    /lefthook:setup https://github.com/org/lefthook-config

  This saves settings to .claude/lefthook.local.md (not committed).
  Then /lefthook:punch will include the shared config via `remotes:`
  and layer project-specific hooks on top.
```
