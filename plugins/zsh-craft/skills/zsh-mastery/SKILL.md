---
name: zsh-mastery
description: >-
  This skill should be used when the user asks to write a zsh script, create a
  zsh function, build a CLI tool in zsh, write a shell script and zsh is the
  target, fix or improve a zsh script, parse command-line arguments in zsh,
  or when Claude is about to write a script with #!/bin/zsh or #!/usr/bin/env zsh.
  Also triggers when the user says "make it zsh", "use zsh not bash", "convert bash
  to zsh", "port to zsh", "rewrite in zsh", "zsh version",
  "idiomatic zsh", "use zparseopts", "zsh modules", or when editing .zshrc,
  .zshenv, .zprofile, or .zlogin files. Provides comprehensive knowledge of
  idiomatic zsh scripting — modules, builtins, parameter expansion, and patterns
  that eliminate external process spawning.
---

# Zsh Mastery

Write idiomatic zsh. If the user wanted bash, they'd ask for bash. If they wanted portable sh, they'd ask for sh. When they say zsh, use the full power of the language.

## Core Principle

**If it spawns a subprocess, there's a zsh builtin for it.** Every `grep`, `sed`, `awk`, `cut`, `tr`, `wc`, `cat`, `stat`, `date`, and `find` invocation in a zsh script is a missed opportunity. Zsh has native equivalents that are faster and compose better.

## The Anti-Pattern Table

Stop writing bash with a zsh shebang. These are the most common mistakes:

| Instead of (bash-ism) | Use (idiomatic zsh) | Why |
|------------------------|---------------------|-----|
| `echo "text"` | `print "text"` | `print` has `-P` (prompt colors), `-f` (printf), `-l` (per-line), `-C` (columns) |
| `echo "$str" \| tr '[:lower:]' '[:upper:]'` | `${(U)str}` | Parameter expansion flag, no subprocess |
| `echo "$str" \| sed 's/foo/bar/g'` | `${str//foo/bar}` | Native substitution |
| `echo "$str" \| grep -o 'pattern'` | `${(M)str:#pattern}` or `[[ $str =~ pattern ]] && print $MATCH` | Pattern matching, no subprocess |
| `echo "$str" \| cut -d, -f2` | `${${(s:,:)str}[2]}` | Split + index |
| `echo "$str" \| wc -l` | `${#${(f)str}}` | Split on newlines + count |
| `cat file.txt` | `$(<file.txt)` | No subprocess at all |
| `declare -A assoc` | `typeset -A assoc` or `local -A assoc` | `typeset` is the zsh native |
| `${!varname}` (indirect) | `${(P)varname}` | `(P)` flag for indirection |
| `${BASH_REMATCH[1]}` | `$match[1]` | Zsh uses `$MATCH` and `$match` array |
| `read -a arr` | `read -A arr` | `-A` for array in zsh |
| `arr[0]` (first element) | `arr[1]` | Zsh arrays are 1-indexed |
| `find . -name "*.log" -mtime -1` | `**/*.log(.m-1)` | Glob qualifiers replace `find` entirely |
| `stat -c %s file` | `zstat +size file` | `zsh/stat` module, no subprocess |
| `date +%s` | `$EPOCHSECONDS` | `zsh/datetime` module |
| `getopts` / `getopt` | `zparseopts` | Native, supports long opts, fills arrays |

## Script Template

Start every zsh script with this foundation:

```zsh
#!/usr/bin/env zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL
setopt EXTENDED_GLOB

# Load modules as needed:
# zmodload zsh/zutil      # zparseopts (usually auto-loaded)
# zmodload zsh/datetime    # $EPOCHSECONDS, strftime
# zmodload zsh/stat        # zstat for file metadata
# zmodload -F zsh/stat b:zstat  # selective: only zstat builtin
# zmodload zsh/mathfunc    # sin, cos, sqrt, floor, ceil, abs
# zmodload zsh/mapfile     # read/write files via $mapfile assoc array
# zmodload zsh/pcre        # Perl-compatible regexes
```

Note: `setopt ERR_EXIT NO_UNSET PIPE_FAIL` is the zsh equivalent of bash's `set -euo pipefail`. Use the long option names — they're self-documenting and case/underscore insensitive.

## The 10 Most Impactful Features

### 1. Parameter Expansion Flags
Compose with `${(flags)var}`. The most useful: `(f)` split on newlines, `(s:sep:)` split on separator, `(j:sep:)` join, `(U)` uppercase, `(L)` lowercase, `(u)` unique, `(o)` sort, `(k)` keys, `(v)` values, `(q)` quote, `(P)` indirect.

See `references/param-expansion.md` for the full flag table and composition examples.

### 2. zparseopts
Native argument parsing that fills zsh arrays directly. Supports long options, boolean flags, required/optional arguments. Never use `getopts`, `getopt`, or manual while-shift loops.

See `references/zparseopts.md` for the full API and patterns.

### 3. print Builtin
Replace `echo` and `printf` everywhere. Key flags: `-P` for prompt-style colors (`%F{red}`, `%B`), `-f` for printf formatting, `-l` for one-per-line, `-C n` for n columns, `-r` for raw output, `-v name` to store in variable.

See `references/print-and-output.md` for all flags and patterns.

### 4. Glob Qualifiers
Append `(qualifiers)` to any glob pattern. `(.)` plain files, `(/)` directories, `(N)` nullglob (no error if empty), `(om)` sort by mtime, `(Lm+10)` larger than 10MB, `(m-1)` modified in last day. Composable. Replaces `find` entirely.

See `references/glob-qualifiers.md` for the full qualifier table.

### 5. Anonymous Functions
`() { body } args` — immediately-invoked, scoped. Use for local variable isolation in scripts and .zshrc. No function name pollution.

### 6. Always Blocks
`{ try } always { cleanup }` — zsh's try-finally. The always block runs regardless of errors, `return`, or `break`. Use for guaranteed cleanup (temp files, locks, traps).

### 7. Associative Arrays
`typeset -A map=(key1 val1 key2 val2)`. Access keys with `${(k)map}`, values with `${(v)map}`, both with `${(kv)map}`. Check existence with `[[ -v map[key] ]]`. 1-indexed like all zsh arrays.

### 8. String Operations Without Subprocesses
Pattern removal (`${var##*/}`, `${var%.*}`), substitution (`${var//old/new}`), splitting (`${(s:,:)var}`), filtering (`${(M)array:#pattern}`). Replaces sed, awk, cut, tr, grep.

See `references/string-ops.md` for the complete replacement table.

### 9. Modules
Load with `zmodload`. The essential ones: `zsh/datetime` (timestamps without `date`), `zsh/stat` (file metadata without `stat`), `zsh/mathfunc` (floating-point math without `bc`), `zsh/mapfile` (file I/O without `cat`), `zsh/pcre` (Perl regexes).

See `references/modules.md` for all modules with examples.

### 10. $(<file) File Reading
`$(<file)` reads a file's contents without spawning `cat`. Note: trailing newlines are stripped (same as command substitution). Combine with `(f)` to get an array of lines: `lines=("${(@f)"$(<file)"}")`.

## Common Patterns

### CLI Tool Pattern
```zsh
main() {
  local -a flag_help flag_verbose
  local -a arg_output
  zparseopts -D -E -F -- \
    {h,-help}=flag_help \
    {v,-verbose}=flag_verbose \
    {o,-output}:=arg_output \
    || { print -P "%F{red}Invalid options%f"; return 1 }

  (( $#flag_help )) && { usage; return 0 }

  local verbose=$(( $#flag_verbose > 0 ))
  local output=${arg_output[-1]:-/dev/stdout}
  local -a positional=("$@")  # remaining args after -D

  # ... rest of logic
}

usage() {
  print -rC1 -- \
    "Usage: ${0:t} [options] <args>" \
    "" \
    "Options:" \
    "  -h, --help       Show this help" \
    "  -v, --verbose    Verbose output" \
    "  -o, --output F   Output file"
}

main "$@"
```

### Colored Output Pattern
```zsh
msg()  { print -P "%F{blue}==>%f %B${1//%/%%}%b" }
warn() { print -P "%F{yellow}warning:%f ${1//%/%%}" >&2 }
err()  { print -P "%F{red}error:%f ${1//%/%%}" >&2 }
die()  { err "$1"; return ${2:-1} }  # return + ERR_EXIT = script exits
```

### File Processing Without External Tools
```zsh
() {
  local -a lines=("${(@f)"$(<$1)"}")
  local -a matches=(${(M)lines:#*ERROR*})
  print -l "Found ${#matches} errors:" $matches
} /var/log/app.log
```

### Temp File with Guaranteed Cleanup
```zsh
{
  local tmpfile=$(mktemp)
  process_data > $tmpfile
  use_result < $tmpfile
} always {
  [[ -f $tmpfile ]] && rm -f $tmpfile
}
```

## Reference Files

Detailed documentation for each major feature area:

- `references/param-expansion.md` — All 40+ parameter expansion flags with composition
- `references/zparseopts.md` — Full API, spec format, patterns, gotchas
- `references/print-and-output.md` — print flags, prompt expansion, zformat
- `references/glob-qualifiers.md` — Complete qualifier table, replacing find
- `references/string-ops.md` — Replacing grep, sed, awk, cut, tr with pure zsh
- `references/modules.md` — zsh/datetime, zsh/stat, zsh/mapfile, zsh/mathfunc, zsh/pcre, zsh/zutil
