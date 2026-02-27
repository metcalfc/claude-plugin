---
name: fzf-mastery
description: This skill should be used when Claude is writing a bash script that
  involves user selection, interactive filtering, file picking, process selection,
  or any interactive list. Triggers when the user asks to "write a script",
  "make a selector", "pick from a list", "choose a file", "select a process",
  "interactive menu", "fuzzy finder", "use fzf", "fzf preview", "fzf theme",
  or when Claude would otherwise pipe output into basic `| fzf`. Also triggers
  when the user says "make it interactive", "let me choose", or "add a picker".
---

# fzf Mastery

When writing scripts that involve user selection, always use fzf with its full capabilities. Never write bare `| fzf` — always include preview, formatting, and keybinding hints.

## Core Principle

Every fzf invocation should have at minimum:
1. **A preview** (`--preview`) showing context for the current selection
2. **A header** (`--header`) explaining available keys
3. **Proper formatting** (`--border`, `--height`, `--layout=reverse`)
4. **ANSI color support** (`--ansi`) when piping colored output

## Minimum Template

```bash
something | fzf \
  --ansi \
  --layout=reverse \
  --border=rounded \
  --height=80% \
  --header='Enter: select / Esc: cancel' \
  --preview='echo {}' \
  --preview-window=right,50%,wrap
```

## Preview Window

The preview window is fzf's superpower. Configure it properly:

```
--preview-window=POSITION,SIZE%,FLAGS
```

- **Position**: `right` (default), `up`, `down`, `left`
- **Size**: percentage like `50%` or `60%`
- **Flags**: `wrap`, `follow` (auto-scroll), `hidden`, `cycle`
- **Responsive**: `<80(up,50%)` — if terminal < 80 cols, switch to up layout
- **Fixed header**: `~3` — fix top 3 lines of preview
- **Scroll offset**: `+{2}+3/3` — scroll to line from field 2

Common preview commands by context:
- **Files**: `bat --color=always {}` or `cat {}`
- **Directories**: `tree -C {} | head -50`
- **Git commits**: `git show --color=always {1}`
- **Processes**: `ps -p {2} -o pid,ppid,cmd,rss,etime`
- **Docker**: `docker inspect {1} | jq .`
- **JSON fields**: `echo {} | jq .`

## The --bind Action System

`--bind` transforms fzf from a selector into a full TUI application.

Key actions to use:
- `reload(CMD)` — replace list with new command output
- `become(CMD)` — replace fzf with another command (clean exit)
- `execute(CMD)` — run command, return to fzf
- `change-preview(CMD)` — swap preview content
- `change-preview-window(A|B|C)` — cycle preview layouts
- `toggle-preview` — show/hide preview
- `change-prompt(STR)` — update prompt (useful for mode state)

Placeholders in commands:
- `{}` — current line
- `{+}` — all selected lines
- `{q}` — current query
- `{1}`, `{2}` — delimiter-separated fields

## Theming

Always apply a theme via `--color`. The user prefers themed fzf — never leave it at defaults.

Check if `FZF_DEFAULT_OPTS` is already set (user may have a global theme). If not, apply a tasteful theme. See `references/theming.md` for the color system and example themes.

## Key Patterns

Detailed patterns are in the `references/` directory:

- **`references/options.md`** — Full option reference (display, layout, search, scripting)
- **`references/bind-actions.md`** — The `--bind` action system, events, placeholders, transform patterns
- **`references/theming.md`** — Color system, color names, theme examples
- **`references/patterns.md`** — Advanced patterns: ripgrep launcher, state toggle, reload, mode switching
- **`references/examples.md`** — Real-world recipes: git, docker, processes, files, kubernetes

## Common Mistakes to Avoid

1. **Bare `| fzf`** — Always add preview, header, and formatting
2. **No `--ansi`** — Required when piping colored output (git, bat, ls --color)
3. **No height** — Full-screen fzf in scripts is usually wrong; use `--height=80%`
4. **Ignoring `--header-lines`** — When piping tabular output (ps, docker ps), use `--header-lines=1` to pin the header row
5. **Using `execute` when `become` is better** — For "select then open" workflows, `become` is cleaner
6. **No `--multi`** — When multiple selection makes sense, add `-m` with tab/shift-tab
7. **Not using `--delimiter` + `--nth`** — Search only relevant fields, not IDs or metadata
8. **Missing `--select-1` / `--exit-0`** — For scripting: auto-select on single match, exit cleanly on no match
