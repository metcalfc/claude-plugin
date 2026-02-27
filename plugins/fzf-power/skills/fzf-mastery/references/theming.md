# fzf Theming & Colors

## Syntax

```bash
--color=[BASE],[NAME[:COLOR][:ATTR]]...
```

**Base schemes**: `dark`, `light`, `16`, `bw`

**Color values**:
- `-1` = default terminal color
- `0-15` = ANSI 16 colors (`black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`, `bright-*`)
- `16-255` = ANSI 256 palette
- `#rrggbb` = 24-bit true color

**Attributes**: `bold`, `underline`, `italic`, `reverse`, `dim`, `strikethrough`, `regular`

## Key Color Names

| Name | Aliases | What it colors |
|------|---------|---------------|
| `fg` | | Default text |
| `bg` | | Background |
| `hl` | | Match highlight |
| `current-fg` | `fg+` | Current line text |
| `current-bg` | `bg+` | Current line background |
| `current-hl` | `hl+` | Match highlight on current line |
| `query` | `input-fg` | Query string |
| `prompt` | | Prompt string |
| `pointer` | | Current line pointer |
| `marker` | | Multi-select marker |
| `info` | | Match counter |
| `header` | `header-fg` | Header text |
| `border` | | Window borders |
| `separator` | | Horizontal separator |
| `spinner` | | Streaming indicator |
| `preview-fg` | | Preview text |
| `preview-bg` | | Preview background |
| `preview-border` | | Preview border |
| `gutter` | | Left gutter |
| `selected-fg` | | Selected line text |
| `selected-bg` | | Selected line background |

## Applying Themes

Set via `FZF_DEFAULT_OPTS` in shell profile for a global theme:

```bash
export FZF_DEFAULT_OPTS='--color=...'
```

Or per-invocation with `--color=...`.

## Example Themes

### Gruvbox Dark
```bash
--color='bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'
```

### Catppuccin Mocha
```bash
--color='bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,selected-bg:#45475a,border:#6c7086'
```

### Tokyo Night
```bash
--color='bg+:#2a2b3d,bg:#1a1b26,spinner:#bb9af7,hl:#565f89,fg:#c0caf5,header:#565f89,info:#7dcfff,pointer:#bb9af7,marker:#7dcfff,fg+:#c0caf5,prompt:#bb9af7,hl+:#bb9af7,border:#3b4261'
```

### Nord
```bash
--color='bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88,fg:#D8DEE9,header:#616E88,info:#8FBCBB,pointer:#81A1C1,marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1,border:#4C566A'
```

### Dracula
```bash
--color='bg+:#44475a,bg:#282a36,spinner:#ff79c6,hl:#6272a4,fg:#f8f8f2,header:#6272a4,info:#50fa7b,pointer:#ff79c6,marker:#ff79c6,fg+:#f8f8f2,prompt:#ff79c6,hl+:#ff79c6,border:#6272a4'
```

### One Dark
```bash
--color='bg+:#353b45,bg:#282c34,spinner:#c678dd,hl:#5c6370,fg:#abb2bf,header:#5c6370,info:#61afef,pointer:#c678dd,marker:#c678dd,fg+:#abb2bf,prompt:#c678dd,hl+:#c678dd,border:#5c6370'
```

### Solarized Dark
```bash
--color='bg+:#073642,bg:#002b36,spinner:#2aa198,hl:#586e75,fg:#839496,header:#586e75,info:#b58900,pointer:#2aa198,marker:#2aa198,fg+:#93a1a1,prompt:#2aa198,hl+:#2aa198,border:#586e75'
```

### Rose Pine
```bash
--color='bg+:#26233a,bg:#191724,spinner:#ebbcba,hl:#6e6a86,fg:#e0def4,header:#6e6a86,info:#9ccfd8,pointer:#ebbcba,marker:#ebbcba,fg+:#e0def4,prompt:#ebbcba,hl+:#ebbcba,border:#403d52'
```

## Theme Gallery

Browse and generate themes interactively at: https://vitormv.github.io/fzf-themes/

The generated `--color` string can be pasted directly into `FZF_DEFAULT_OPTS`.

## Tips

- Check `$FZF_DEFAULT_OPTS` before applying a theme — the user may have one set globally
- When writing scripts, respect the user's existing theme by not overriding `--color` unless asked
- If no theme is set, apply one — unstyled fzf looks flat
- Use `--style=full` with `--border` for the most polished look
- Match the theme to the user's terminal theme if known
