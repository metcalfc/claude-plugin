---
name: help
description: (claude-craft) Plugin help
allowed-tools: []
---

Display the following help text to the user:

```
claude-craft — Claude Code CLI knowledge, plugin management, and guardrails

SKILLS (auto-activate based on context):
  claude-cli-knowledge          Correct CLI syntax, TTY limitations, /plugin commands,
                                version bumping rules, marketplace operations
  claude-automation-recommender Analyze codebase and recommend hooks, skills, MCP servers,
                                subagents, and plugins
  claude-api-knowledge          Model strings, cross-platform IDs, effort parameter,
                                extended thinking, and prompt patterns for Claude API

HOOKS:
  PreToolUse (Bash)             Catches common CLI mistakes before execution:
                                - "claude plugins" → "claude plugin" (singular)
                                - "marketplace add github:" → no github: prefix
                                - Running claude CLI commands that need a TTY

COMMANDS:
  /claude-craft:add       Request a new feature (files an issue)
  /claude-craft:issue     Report a bug (gathers context, you review before filing)
  /claude-craft:help      This help text

USAGE:
  Skills activate automatically when you work with Claude CLI commands or
  plugin management. The hook catches mistakes at execution time.
```
