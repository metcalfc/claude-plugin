# Parameter Expansion Flags

Syntax: `${(flags)varname}`. Flags compose by concatenation: `${(ufj:,:)array}` means unique + join with comma.

## Case and Text

| Flag | Effect | Example |
|------|--------|---------|
| `L` | Lowercase | `${(L)word}` |
| `U` | Uppercase | `${(U)word}` |
| `C` | Capitalize each word | `${(C)str}` → `Hello World` |

## Splitting and Joining

| Flag | Effect | Example |
|------|--------|---------|
| `f` | Split on newlines | `${(f)"$(<file)"}` |
| `F` | Join with newlines | `${(F)array}` |
| `s:sep:` | Split on separator | `${(s:,:)csv}` |
| `j:sep:` | Join with separator | `${(j:, :)array}` |
| `0` | Split on null bytes | `${(0)"$(find . -print0)"}` |
| `z` | Split using shell parsing (respects quoting) | `${(z)cmdstring}` |

## Array Operations

| Flag | Effect | Example |
|------|--------|---------|
| `u` | Deduplicate | `${(u)array}` |
| `o` | Sort ascending | `${(o)array}` |
| `O` | Sort descending | `${(O)array}` |
| `i` | Case-insensitive (combine with `o`/`O`) | `${(oi)array}` |
| `n` | Numeric sort | `${(on)array}` |

## Associative Array Access

| Flag | Effect | Example |
|------|--------|---------|
| `k` | Substitute keys instead of values | `${(k)assoc}` |
| `v` | Substitute values (with `k`, gives both) | `${(kv)assoc}` |

## Quoting

| Flag | Effect | Example |
|------|--------|---------|
| `q` | Backslash-quote | `${(q)str}` |
| `qq` | Single-quote | `${(qq)str}` |
| `qqq` | Double-quote | `${(qqq)str}` |
| `Q` | Remove one level of quoting | `${(Q)quoted}` |
| `b` | Quote only glob pattern chars | `${(b)pattern}` |

## Type and Indirection

| Flag | Effect | Example |
|------|--------|---------|
| `t` | Parameter type (scalar/array/assoc/integer) | `${(t)var}` |
| `P` | Indirect expansion (treat value as param name) | `${(P)varname}` |
| `e` | Perform further expansion on result | `${(e)str}` |
| `%` | Expand prompt sequences | `${(%)str}` |

## Padding

| Flag | Effect | Example |
|------|--------|---------|
| `l:n::fill:` | Left-pad to width n | `${(l:10::0:)num}` → `0000000042` |
| `r:n::fill:` | Right-pad to width n | `${(r:20::.:)str}` → `hello...............` |

## Match Extraction

Use with `${var/pattern/repl}` or `${var#pattern}`:

| Flag | Effect |
|------|--------|
| `S` | Shortest match (with `##`/`%%`) |
| `M` | Include matched portion in result |
| `R` | Include unmatched remainder |
| `B` | Index where match begins |
| `E` | Position after match end |
| `N` | Match length |
| `I:n:` | Select the nth match |

## Escape Processing

| Flag | Effect |
|------|--------|
| `p` | Recognize print-style escapes in `s`/`j` separators |
| `g:opts:` | Process escapes: `e` for `\e`, `o` for octal, `c` for `^X` |
| `#` | Evaluate as character code |

## Composition Examples

```zsh
# Read file → split lines → deduplicate → uppercase → join with commas
result=${(j:,:)${(uU)${(f)"$(<file.txt)"}}}

# Unique sorted dirnames from an array of paths
local -a paths=(/a/b/c /a/b/d /x/y/z /a/b/e)
print -l ${(uo)${paths:h}}

# Split CSV line, get 3rd field, lowercase
val=${(L)${(s:,:)line}[3]}

# Reverse sort an array, take first 5
top5=(${(On)scores}[1,5])

# Join array with newlines, each element right-padded to 30 chars
print ${(pj:\n:)${(r:30:: :)items}}

# Read file into array, filter lines containing "ERROR", count them
local -a lines=("${(@f)"$(<app.log)"}")
local -a errors=(${(M)lines:#*ERROR*})
print "Error count: ${#errors}"

# Serialize associative array to string and back
typeset -A orig=(host localhost port 8080)
serialized="${(j: :)${(qkv@)orig}}"
typeset -A restored=("${(Q@)${(z@)serialized}}")
```

## The `@` Flag

`@` preserves empty elements during expansion. Critical inside double quotes:

```zsh
arr=("" "hello" "" "world")
print -l "${(@)arr}"      # Preserves all 4 elements including empty ones
print -l "${arr[@]}"      # Same thing — @ in subscript
print -l "$arr[@]"        # Same
print -l "${arr}"         # WRONG — joins into single string
```

Use `"${(@f)...}"` (not `${(f)...}`) when you need to preserve empty lines from a file.

## Nested Expansion

Zsh allows nesting `${...}` for multi-step transformations:

```zsh
path="/home/user/src/project/main.rs"

# Basename without extension:
${${path##*/}%.*}          # main

# Directory name only (not full path):
${${path%/*}##*/}          # project

# Replace extension:
${path%.rs}.go             # /home/user/src/project/main.go
```
