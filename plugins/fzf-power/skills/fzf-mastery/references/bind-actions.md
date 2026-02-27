# The --bind Action System

`--bind` transforms fzf from a simple selector into a full TUI application.

**Syntax**: `--bind 'KEY:ACTION1+ACTION2'` or `--bind 'EVENT:ACTION'`

## Core Actions

| Action | Syntax | Use for |
|--------|--------|---------|
| `reload` | `reload(CMD)` | Replace item list with new command output |
| `become` | `become(CMD)` | Replace fzf process with command (clean exit) |
| `execute` | `execute(CMD)` | Run command, return to fzf |
| `execute-silent` | `execute-silent(CMD)` | Run silently |
| `change-preview` | `change-preview(CMD)` | Swap preview content |
| `change-preview-window` | `change-preview-window(A\|B\|C)` | Cycle preview layouts |
| `toggle-preview` | | Show/hide preview |
| `change-prompt` | `change-prompt(STR)` | Update prompt (useful for state) |
| `change-header` | `change-header(STR)` | Update header |
| `change-query` | `change-query(STR)` | Set query |
| `transform` | `transform(CMD)` | Conditionally emit actions |
| `transform-query` | `transform-query(CMD)` | Modify query via command |
| `enable-search` | | Enable fuzzy matching |
| `disable-search` | | Disable fuzzy matching |
| `toggle-search` | | Toggle fuzzy matching |
| `search` | `search(STR)` | Trigger search with string |
| `clear-query` | | Empty the query |
| `unbind` | `unbind(KEYS)` | Disable key bindings |
| `rebind` | `rebind(KEYS)` | Re-enable key bindings |
| `accept` | | Select and exit |
| `abort` | | Exit without selection |
| `print` | `print(STR)` | Add string to output |
| `refresh-preview` | | Reload current preview |
| `toggle-sort` | | Toggle result sorting |
| `toggle-all` | | Toggle all selections |
| `select-all` | | Select all items |
| `deselect-all` | | Deselect all items |
| `first` / `last` | | Jump to first/last |

## Placeholders

| Placeholder | Content |
|-------------|---------|
| `{}` | Current line |
| `{+}` | All selected lines |
| `{q}` | Current query |
| `{n}` | Zero-based line index |
| `{+n}` | Indices of all selected |
| `{1}`, `{2}` | Delimiter-separated fields |
| `{q:1}`, `{q:2..}` | Query split by spaces |

## Events

| Event | Trigger |
|-------|---------|
| `start` | Once when fzf starts |
| `load` | Input stream complete |
| `change` | Query changes |
| `focus` | Cursor moves to new item |
| `result` | Filtering complete |
| `resize` | Terminal resized |
| `one` | Single match remaining |
| `zero` | No matches |
| `backward-eof` | Backspace on empty query |

## Environment Variables (in actions)

| Variable | Content |
|----------|---------|
| `FZF_QUERY` | Current query |
| `FZF_PROMPT` | Current prompt (use for state detection) |
| `FZF_ACTION` | Last action |
| `FZF_KEY` | Last key pressed |
| `FZF_MATCH_COUNT` | Number of matches |
| `FZF_SELECT_COUNT` | Number of selected |
| `FZF_TOTAL_COUNT` | Total items |
| `FZF_POS` | Cursor position |

## Transform Pattern

`transform` runs a command and uses its stdout as actions to execute. Use for conditional logic:

```bash
--bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
  echo "change-prompt(Files> )+reload(fd --type file)" ||
  echo "change-prompt(Directories> )+reload(fd --type directory)"'
```

All `change-*` actions have `transform-*` counterparts:
- `transform-prompt(CMD)`, `transform-header(CMD)`, `transform-query(CMD)`, etc.

## Preview Layout Cycling

Pipe-separated layouts cycle on each press:

```bash
--bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)'
```

First press: 80% bottom. Second: hidden. Third: back to default.

## Common Keybinding Patterns

```bash
# Reload data
--bind 'ctrl-r:reload(CMD)'

# Toggle between two modes
--bind 'ctrl-t:transform:[[ $FZF_PROMPT =~ Mode1 ]] &&
  echo "change-prompt(Mode2> )+reload(cmd2)" ||
  echo "change-prompt(Mode1> )+reload(cmd1)"'

# Open in editor
--bind 'enter:become(vim {})'
--bind 'ctrl-e:execute(vim {})'

# Copy to clipboard
--bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort'

# Preview toggle
--bind 'ctrl-/:toggle-preview'

# Select all then accept
--bind 'ctrl-a:select-all+accept'
```
