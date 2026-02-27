# fzf Options Reference

## Search

| Option | Description |
|--------|-------------|
| `--exact` / `-e` | Exact-match mode (no fuzzy) |
| `--scheme=path\|history` | Scoring tuned for input type |
| `--smart-case` | Case-insensitive unless uppercase in query |
| `--disabled` | No fuzzy matching — fzf becomes a pure selector. Key for ripgrep-launcher pattern |
| `--nth N[,..]` | Limit search to specific fields |
| `--with-nth N[,..]` | Transform display (doesn't affect search) |
| `--accept-nth N[,..]` | Which fields to output on accept |
| `--delimiter STR` | Field delimiter regex |
| `--tac` | Reverse input order |
| `--no-sort` | Don't sort results |
| `--track` | Track current selection when list updates |

**Field expressions**: `1` (first), `-1` (last), `3..5` (range), `2..` (to end), `..-3` (from start)

## Display & Layout

| Option | Description |
|--------|-------------|
| `--height=[~]H[%]` | Non-fullscreen; `~` = fit content |
| `--layout=reverse` | Prompt at top, list below (usually best for scripts) |
| `--border=rounded\|sharp\|bold\|double\|none` | Border style |
| `--border-label=STR` | Label on the border |
| `--margin=T,R,B,L` | Margins around finder |
| `--padding=T,R,B,L` | Padding inside border |
| `--info=inline\|inline-right\|hidden` | Match count display |
| `--separator=STR` | Horizontal separator character |
| `--no-scrollbar` | Hide scrollbar |
| `--style=minimal\|full` | Style presets |
| `--tmux=[pos][,W%][,H%]` | Run in tmux popup |

## List

| Option | Description |
|--------|-------------|
| `--multi` / `-m [MAX]` | Multi-select with tab/shift-tab |
| `--cycle` | Cyclic scrolling |
| `--wrap` | Line wrapping |
| `--highlight-line` | Highlight entire current line |
| `--pointer=STR` | Current line pointer character |
| `--marker=STR` | Multi-select marker character |
| `--gap[=N]` | Empty lines between items |
| `--ansi` | Process ANSI color codes in input |

## Input

| Option | Description |
|--------|-------------|
| `--prompt=STR` | Input prompt (default `> `) |
| `--query=STR` | Pre-fill query |
| `--ghost=TEXT` | Placeholder ghost text |

## Header & Footer

| Option | Description |
|--------|-------------|
| `--header=STR` | Sticky header text |
| `--header-lines=N` | First N input lines become header (great for table output) |
| `--header-first` | Header before prompt |
| `--header-border[=STYLE]` | Border around header |
| `--footer=STR` | Sticky footer text |

## Preview Window

| Option | Description |
|--------|-------------|
| `--preview=CMD` | Preview command; `{}` is current selection |
| `--preview-window=SPEC` | Position, size, and flags |
| `--preview-border[=STYLE]` | Preview border style |
| `--preview-label=STR` | Label on preview border |

**Preview window spec**: `--preview-window=[POSITION],[SIZE%],[FLAGS],[+SCROLL],[~HEADER],[<THRESHOLD(ALT)]`

Position: `up`, `down`, `left`, `right`
Flags: `wrap`, `follow`, `cycle`, `hidden`, `noinfo`
Scroll: `+{2}+3/3` = scroll to field 2 line, offset +3, at 1/3 screen
Header: `~3` = fix top 3 lines
Responsive: `<80(up,50%)` = switch layout if narrow

## Scripting

| Option | Description |
|--------|-------------|
| `--select-1` / `-1` | Auto-select if single match |
| `--exit-0` / `-0` | Exit if no match |
| `--filter=STR` | Non-interactive filter mode |
| `--print-query` | Print query as first output line |
| `--expect=KEY[,...]` | Print pressed key as first output line |
| `--read0` | NUL-delimited input |
| `--print0` | NUL-delimited output |
| `--sync` | Synchronous search |
| `--listen[=PORT]` | Start HTTP server for external control |

## Extended Search Syntax

| Token | Match Type |
|-------|-----------|
| `term` | Fuzzy match |
| `'exact` | Exact match |
| `^prefix` | Prefix exact match |
| `suffix$` | Suffix exact match |
| `!term` | Inverse match |
| `!^prefix` | Inverse prefix |
| `term1 \| term2` | OR operator |

Multiple terms are AND'd by default.

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Normal exit with selection |
| `1` | No match |
| `2` | Error |
| `130` | Interrupted (CTRL-C / ESC) |
