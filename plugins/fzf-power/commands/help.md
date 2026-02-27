---
name: help
description: Show fzf-power plugin help
allowed-tools: []
---

Display the following help text to the user:

```
fzf-power — Teaches Claude to use fzf's full capabilities

WHAT IT DOES:
  When Claude writes scripts involving user selection, this plugin ensures
  fzf is used with preview windows, keybindings, headers, theming, and
  proper formatting — not bare "| fzf".

SKILL (auto-activates when writing interactive scripts):
  fzf-mastery       Preview windows, --bind actions, theming, advanced patterns

REFERENCES (loaded as needed):
  options           Full fzf option reference
  bind-actions      The --bind action system, placeholders, events, transforms
  theming           Color system, 8 built-in themes, theme gallery
  patterns          Advanced: ripgrep launcher, mode switching, state toggle
  examples          Real-world recipes: git, docker, k8s, processes, files

COMMANDS:
  /fzf-power:theme  Browse and apply fzf color themes
  /fzf-power:add    Request a new fzf recipe or pattern (files an issue)
  /fzf-power:issue  Report a bug (gathers context, you review before filing)
  /fzf-power:help   This help text

USAGE:
  Just ask Claude to write any interactive script — the plugin activates
  automatically. For best results, mention what you're selecting from.
  Examples: "pick a git branch", "choose a docker container", "select a file"
```
