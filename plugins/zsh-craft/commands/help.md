---
name: help
description: Show zsh-craft plugin help
allowed-tools: []
---

Display the following help text to the user:

```
zsh-craft — Teaches Claude to write idiomatic zsh, not bash-in-disguise

WHAT IT DOES:
  When Claude writes zsh scripts, this plugin ensures it uses native zsh
  features — parameter expansion flags, zparseopts, glob qualifiers, print,
  and modules — instead of spawning grep, sed, awk, cut, date, stat, and cat.

SKILL (auto-activates when writing zsh scripts):
  zsh-mastery       Core principles, anti-patterns, patterns, module overview

REFERENCES (loaded as needed):
  param-expansion   40+ parameter expansion flags with composition examples
  zparseopts        Full API, spec format, short+long options, gotchas
  print-and-output  print flags, prompt colors, zformat, column output
  glob-qualifiers   Complete qualifier table, replacing find entirely
  string-ops        Replacing grep, sed, awk, cut, tr with pure zsh
  modules           zsh/datetime, zsh/stat, zsh/mapfile, zsh/mathfunc, zsh/pcre

COMMANDS:
  /zsh-craft:add    Request a new zsh pattern or recipe (files an issue)
  /zsh-craft:issue  Report a bug (gathers context, you review before filing)
  /zsh-craft:help   This help text

USAGE:
  Just ask Claude to write a zsh script — the plugin activates automatically.
  For best results, be explicit: "write a zsh script to..." or "use zparseopts".
  If you want portable sh, say so. If you say zsh, you get real zsh.
```
