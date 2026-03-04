# print and Output

`print` is zsh's replacement for both `echo` and `printf`. Use it everywhere — it handles edge cases they cannot.

## Why print Over echo

- `echo` has unportable behavior with `-n` and backslash interpretation
- `print -r` is always literal; `print` always expands `\n`, `\t`
- `print -P` enables prompt-style colors without subshells
- `print -v` stores to variable without subshells
- `print -l` prints one-per-line (replaces `printf '%s\n'`)
- `print -f` replaces `printf` with same format syntax

## Key Flags

| Flag | Effect | Example |
|------|--------|---------|
| (none) | Print with escape expansion | `print "hello\nworld"` |
| `-r` | Raw — no escape expansion | `print -r "$raw_data"` |
| `-n` | No trailing newline | `print -n "prompt: "` |
| `-l` | Separate args with newlines | `print -l "${array[@]}"` |
| `-0` | Separate with null bytes | `print -0 "${array[@]}" \| xargs -0` |
| `-f fmt` | printf-style format | `print -f "%-20s %5d\n" "$name" "$count"` |
| `-P` | Prompt expansion (colors!) | `print -P "%F{red}error%f: $msg"` |
| `-v name` | Store in variable, don't print | `print -v result -f "%04d" $n` |
| `-u n` | Print to file descriptor n | `print -u 2 "to stderr"` |
| `-c` | Print in columns (row-major) | `print -c "${items[@]}"` |
| `-C n` | Print in exactly n columns | `print -rC2 -- "${items[@]}"` |
| `-a` | With `-c`/`-C`, use column-major order | `print -aC3 -- "${items[@]}"` |
| `-o` | Sort ascending before printing | `print -lo "${array[@]}"` |
| `-O` | Sort descending before printing | `print -lO "${array[@]}"` |
| `-i` | Case-insensitive sort | `print -loi "${array[@]}"` |
| `-D` | Replace paths with `~` abbreviations | `print -D "$HOME/file"` → `~/file` |
| `-s` | Push to history | `print -s "command to remember"` |
| `-z` | Push to editing buffer | `print -z "cmd to edit"` |

## Prompt Expansion Colors (-P flag)

```zsh
# Foreground colors
print -P "%F{red}red text%f"
print -P "%F{green}green%f %F{blue}blue%f"
print -P "%F{208}orange (256-color)%f"
print -P "%F{#ff5500}hex color%f"    # true color

# Named colors: black, red, green, yellow, blue, magenta, cyan, white
# Plus 0-255 for 256-color, #rrggbb for true color

# Formatting
print -P "%Bbold%b"
print -P "%Uunderline%u"
print -P "%Sstandout (reverse)%s"

# Combining
print -P "%B%F{red}bold red%f%b"
print -P "%F{green}==>%f %Bheading%b"

# Conditionals
print -P "%(?.%F{green}ok%f.%F{red}fail%f)"  # based on exit status
```

## Common Output Patterns

### Colored Message Functions
```zsh
msg()  { print -P "%F{blue}==>%f %B$1%b" }
warn() { print -P "%F{yellow}warning:%f $1" >&2 }
err()  { print -P "%F{red}error:%f $1" >&2 }
die()  { err "$1"; return ${2:-1} }
```

### Formatted Tables
```zsh
# Simple table with printf-style formatting
print -f "%-30s %10s %8s\n" "NAME" "SIZE" "MODIFIED"
print -f "%-30s %10s %8s\n" "----" "----" "--------"
for item in "${items[@]}"; do
  print -f "%-30s %10d %8s\n" "$name" "$size" "$date"
done
```

### Column Output
```zsh
# Automatic columns (like ls)
print -c -- "${files[@]}"

# Exactly 3 columns
print -rC3 -- "${items[@]}"

# Column-major (down then across)
print -raC3 -- "${items[@]}"
```

### Store in Variable
```zsh
# Avoid $(printf ...) subshell
print -v padded -f "%05d" $number
print -v line -f "%-20s = %s" "$key" "$value"
```

## zformat — Named Format Strings

From `zsh/zutil`. Uses `%name` sequences instead of positional `%s`:

```zsh
local result
zformat -f result "%n is %a years old" "n:Alice" "a:30"
print $result  # "Alice is 30 years old"

# Width control: %10n (right-pad), %-10n (left-pad), %10.5n (max 5 chars)

# Ternary: %(c.true.false) — "true" if c is non-empty, "false" otherwise
zformat -f result "Status: %(s.active.inactive)" "s:${running}"
```

### Column Alignment with zformat -a
```zsh
local -a aligned
zformat -a aligned ' -- ' \
  "build:Compile the project" \
  "test:Run test suite" \
  "deploy:Deploy to production"
print -l $aligned
# build  -- Compile the project
# test   -- Run test suite
# deploy -- Deploy to production
```

## Replacing printf Entirely

```zsh
# printf "%s\n" "${arr[@]}"  →
print -l "${arr[@]}"

# printf "%05d" $n  →
print -v result -f "%05d" $n

# printf "%-20s %s\n" "key" "value"  →
print -f "%-20s %s\n" "key" "value"

# printf '\e[31m%s\e[0m\n' "error"  →
print -P "%F{red}error%f"
```
