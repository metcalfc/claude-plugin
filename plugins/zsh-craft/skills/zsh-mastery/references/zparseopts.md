# zparseopts — Native Argument Parsing

`zparseopts` is zsh's builtin option parser from `zsh/zutil`. It fills zsh arrays directly, supports long options, and eliminates while-shift loops entirely.

## Syntax

```
zparseopts [-D] [-E] [-F] [-K] [-M] [-a array] [-A assoc] [--] spec ...
```

## zparseopts Flags

| Flag | Meaning |
|------|---------|
| `-D` | Remove parsed options from `$@` (most common — use always) |
| `-E` | Don't stop at first non-option argument (extract mode) |
| `-F` | Fail on unknown options (print error, return 1) |
| `-K` | Keep existing array values as defaults when option not given |
| `-M` | Map mode: `=array` aliases another spec |
| `-a array` | Store all parsed options in one array |
| `-A assoc` | Store as associative array (option → value) |

## Spec Format

| Spec | Meaning | Array result |
|------|---------|--------------|
| `name` | Boolean flag (no argument) | `(-name)` |
| `name+` | Accumulating flag (count occurrences) | `(-name -name ...)` |
| `name:` | Required argument | `(-name value)` |
| `name:-` | Required argument in same element | `(-name=value)` |
| `name::` | Optional argument | `(-name)` or `(-name value)` |
| `name=arr` | Store in specific array | stored in `$arr` |
| `-longname` | Long option (one `-` in spec = `--` on CLI) | `(--longname)` |

## The Standard Pattern

```zsh
my_command() {
  local -a flag_help flag_verbose flag_dry
  local -a arg_output arg_count
  zparseopts -D -E -F -- \
    {h,-help}=flag_help \
    {v,-verbose}=flag_verbose \
    {n,-dry-run}=flag_dry \
    {o,-output}:=arg_output \
    {c,-count}:=arg_count \
    || return 1

  # Boolean check: array non-empty = flag was given
  (( $#flag_help )) && { usage; return 0 }

  # Value extraction: last element of the pair array
  local output=${arg_output[-1]:-/dev/stdout}
  local count=${arg_count[-1]:-10}

  # Remaining positional args (after -D removed parsed opts)
  local -a args=("$@")

  # ...
}
```

## Short + Long Option Aliases

Use `{short,-long}=array` to accept both forms storing into the same array:

```zsh
zparseopts -D -F -- \
  {h,-help}=flag_help \
  {v,-verbose}=flag_verbose \
  {f,-file}:=arg_file
```

This accepts `-h` or `--help`, `-v` or `--verbose`, `-f FILE` or `--file FILE`.

## Using the Associative Array Form

```zsh
my_command() {
  local -A opts
  zparseopts -D -F -A opts -- \
    h -help \
    v -verbose \
    f: -file: \
    || return 1

  # Check via key existence:
  [[ -v opts[-h] ]] || [[ -v opts[--help] ]] && { usage; return 0 }
  local file=${opts[-f]:-${opts[--file]:-default.txt}}
}
```

## Accumulating Flags

Use `+` spec to count occurrences (like `-vvv` for verbosity):

```zsh
local -a verbosity=()
zparseopts -D -F -- v+=verbosity || return 1
local level=${#verbosity}  # 0, 1, 2, 3...
```

## Defaults with -K

Set array values before calling, then `-K` preserves them if the option isn't given:

```zsh
local -a arg_port=(-p 8080)  # default
zparseopts -D -K -- p:=arg_port || return 1
local port=${arg_port[-1]}  # 8080 if -p not given
```

## When to Use `-E` (Extract Mode)

Without `-E`, zparseopts **stops at the first non-option argument**. This means flags after positional args are silently ignored:

```zsh
# BUG: --verbose is never parsed because "file.txt" comes first
my_cmd() {
  local -a flag_verbose
  zparseopts -D -F -- {v,-verbose}=flag_verbose || return 1
  # my_cmd file.txt --verbose  →  flag_verbose is EMPTY
  # my_cmd --verbose file.txt  →  flag_verbose is set
}
```

Add `-E` when your command accepts **positional args mixed with flags** (GNU-style):

```zsh
# FIXED: -E tells zparseopts to scan past non-option args
my_cmd() {
  local -a flag_verbose
  zparseopts -D -E -F -- {v,-verbose}=flag_verbose || return 1
  # my_cmd file.txt --verbose  →  flag_verbose is set ✓
  # my_cmd --verbose file.txt  →  flag_verbose is set ✓
}
```

**Rule of thumb:**
- `-D -F` — flags must come before positional args (strict POSIX style)
- `-D -E -F` — flags can appear anywhere (GNU style, what most users expect)

If your tool accepts positional arguments, default to `-D -E -F` unless you have a specific reason to enforce strict ordering.

## Gotchas

### Flags after positional args are silently ignored without `-E`
This is the most common zparseopts footgun. Without `-E`, `cmd arg --flag` silently drops `--flag` — no error, no warning, even with `-F`. The flag passes through as a positional arg, where it can cause downstream parsing failures. See the `-E` section above.

### Value is the last array element
`-f filename` produces `arg_file=( -f filename )`. The value is `${arg_file[-1]}`, not `${arg_file[1]}`.

### `--opt=value` requires `:-` spec
With `:` spec, the argument must be a separate word. `--file=foo` parses as `--file` with argument `=foo` (leading `=`). Use `:-` spec for same-word syntax: `--file=foo` is parsed correctly with `-file:-`.

### `-F` requires zsh 5.4+
If targeting older zsh, omit `-F` and handle unknown options manually.

### Don't stack zparseopts' own flags
`-DE` is interpreted as a spec for `--DE`, not as `-D -E`. Always separate: `-D -E`.

### `--` separator
Always include `--` before specs to clearly separate zparseopts flags from option specs:
```zsh
zparseopts -D -F -- h=help v=verbose  # correct
zparseopts -D -F h=help v=verbose     # ambiguous — avoid
```

## Complete Example: A File Processing Tool

```zsh
#!/usr/bin/env zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL

process_files() {
  local -a flag_help=() flag_verbose=() flag_recursive=()
  local -a arg_pattern=() arg_output=() arg_exclude=()
  zparseopts -D -E -F -- \
    {h,-help}=flag_help \
    {v,-verbose}=flag_verbose \
    {r,-recursive}=flag_recursive \
    {p,-pattern}:=arg_pattern \
    {o,-output}:=arg_output \
    {e,-exclude}:=arg_exclude \
    || { usage >&2; return 1 }

  (( $#flag_help )) && { usage; return 0 }

  local verbose=$(( $#flag_verbose > 0 ))
  local recursive=$(( $#flag_recursive > 0 ))
  local pattern=${arg_pattern[-1]:-"*"}
  local output=${arg_output[-1]:-/dev/stdout}
  local exclude=${arg_exclude[-1]:-""}
  local -a targets=("$@")

  (( ${#targets} )) || { print -P "%F{red}error:%f no files specified" >&2; return 1 }

  for target in "${targets[@]}"; do
    (( verbose )) && print -P "%F{blue}==>%f Processing $target"
    # ... process
  done
}

usage() {
  print -rC1 -- \
    "Usage: ${0:t} [options] <files...>" \
    "" \
    "Options:" \
    "  -h, --help           Show this help" \
    "  -v, --verbose        Verbose output" \
    "  -r, --recursive      Process directories recursively" \
    "  -p, --pattern PAT    File pattern to match (default: *)" \
    "  -o, --output FILE    Output file (default: stdout)" \
    "  -e, --exclude PAT    Exclude pattern"
}

process_files "$@"
```
