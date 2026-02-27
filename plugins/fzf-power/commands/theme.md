---
name: theme
description: Browse and apply fzf color themes
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

Help the user pick and apply an fzf theme.

## Step 1: Check current theme

Check if `FZF_DEFAULT_OPTS` is already set:

```bash
echo "${FZF_DEFAULT_OPTS:-<not set>}"
```

Check which shell profile is in use:

```bash
echo "$SHELL"
```

## Step 2: Show available themes

Load the theme reference from `references/theming.md` and present the built-in themes to the user:

- Gruvbox Dark
- Catppuccin Mocha
- Tokyo Night
- Nord
- Dracula
- One Dark
- Solarized Dark
- Rose Pine

Use AskUserQuestion with options listing each theme. Mention that the user can also browse https://vitormv.github.io/fzf-themes/ for more options and paste a custom `--color` string.

## Step 3: Preview the theme

After the user picks a theme, run a live fzf demo with it:

```bash
echo -e "Preview Line 1\nPreview Line 2\nPreview Line 3\nPreview Line 4\nPreview Line 5" | \
  fzf --color='<selected theme colors>' \
      --layout=reverse --border=rounded --height=40% \
      --header='Theme preview — press Esc to close' \
      --preview='echo "This is the preview pane with your selected theme"' \
      --preview-window=right,50%,wrap \
      --bind 'esc:abort'
```

## Step 4: Apply the theme

Ask the user where to apply:

- **Shell profile** — add/update `FZF_DEFAULT_OPTS` in `~/.bashrc`, `~/.zshrc`, or appropriate profile
- **Just show me** — print the export line so the user can paste it manually

If applying to shell profile:
1. Read the profile file
2. Check if `FZF_DEFAULT_OPTS` already exists
3. If yes, update the existing line
4. If no, append the export at the end
5. Show the user the exact change before writing

The export line format:

```bash
export FZF_DEFAULT_OPTS='--color=<theme colors>'
```

If the user already has `FZF_DEFAULT_OPTS` with non-color options, preserve those and only add/replace the `--color` portion.
