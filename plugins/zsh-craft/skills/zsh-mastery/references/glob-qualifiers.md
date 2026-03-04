# Glob Qualifiers

Append `(qualifiers)` to any glob pattern. Requires `setopt EXTENDED_GLOB` for `#b`/`#m` patterns. Bare `(...)` qualifiers work by default.

## File Type

| Qualifier | Matches |
|-----------|---------|
| `/` | Directories |
| `F` | Non-empty directories |
| `.` | Regular (plain) files |
| `@` | Symbolic links |
| `=` | Sockets |
| `p` | Named pipes (FIFOs) |
| `*` | Executable files |
| `%` | Device files |

## Permissions

| Qualifier | Matches |
|-----------|---------|
| `r` / `w` / `x` | Owner readable / writable / executable |
| `A` / `I` / `E` | Group readable / writable / executable |
| `R` / `W` / `X` | World readable / writable / executable |
| `s` / `S` | setuid / setgid |
| `t` | Sticky bit |
| `U` | Owned by current user |
| `G` | Owned by current group |
| `u:name:` | Owned by specific user |
| `g:name:` | Owned by specific group |

## Time

Pattern: `(Xunit±n)` where X is `m` (mtime), `a` (atime), `c` (ctime).

Units: `M` (months), `w` (weeks), `d` (days, default), `h` (hours), `m` (minutes), `s` (seconds).

```zsh
*(m0)       # modified today
*(m-2)      # modified within last 2 days
*(m+7)      # modified more than 7 days ago
*(mh-4)     # modified within last 4 hours
*(mm+30)    # modified more than 30 minutes ago
*(ms-90)    # modified within last 90 seconds
*(mw-2)     # modified within last 2 weeks
```

## Size

Pattern: `(L[unit]±n)`. Units: `k` (KB), `m` (MB), `g` (GB), `p` (512-byte blocks).

```zsh
*(L0)        # empty files (0 bytes)
*(L+0)       # non-empty files
*(Lk+100)    # larger than 100 KB
*(Lm-5)      # smaller than 5 MB
*(Lm+10)     # larger than 10 MB
*(Lg+1)      # larger than 1 GB
```

## Sorting

Prefix with `o` (ascending) or `O` (descending):

| Qualifier | Sort by |
|-----------|---------|
| `on` | Name (default) |
| `oL` | File size |
| `om` | Modification time (newest first) |
| `oa` | Access time |
| `oc` | Inode change time |
| `ol` | Link count |
| `oN` | No sorting (filesystem order) |

## Selection

```zsh
*(N)        # Nullglob: no error if no matches (expands to nothing)
*(D)        # Dotfiles: include hidden files
*(n)        # Numeric sort (10 after 9, not after 1)
*(Y5)       # Short-circuit: at most 5 matches
*([1,3])    # First 3 matches
*([1])      # First match only
*(^/)       # NOT directories (negate with ^)
```

## Combining Qualifiers

Qualifiers concatenate. Read left to right:

```zsh
# Plain files, modified in last day, larger than 1KB, sorted by size descending
**/*(.m-1Lk+1OL)

# Directories owned by me, non-empty
**/*(UF/)

# Executable files, not symlinks, sorted by name
**/*(*^@on)

# Log files modified in last hour, newest first
**/*.log(.mh-1om)

# 5 largest files in tree
**/*(OL.[1,5])

# Empty directories (for cleanup)
**/*(D/^F)
```

## Replacing find

| find command | Glob equivalent |
|-------------|-----------------|
| `find . -type f` | `**/*(.)`  |
| `find . -type d` | `**/*(/)`  |
| `find . -name "*.log"` | `**/*.log` |
| `find . -name "*.log" -type f` | `**/*.log(.)` |
| `find . -mtime -1` | `**/*(m-1)` |
| `find . -mtime +7` | `**/*(m+7)` |
| `find . -size +1M` | `**/*(Lm+1)` |
| `find . -size 0` | `**/*(L0)` |
| `find . -empty -type d` | `**/*(D/^F)` |
| `find . -perm /u+x -type f` | `**/*(.*)`  |
| `find . -user chad` | `**/*(u:chad:)` |
| `find . -newer ref` | `**/*(e:'[[ $REPLY -nt ref ]]':)` |
| `find . -maxdepth 1 -type f` | `*(.)`  |
| `find . -name "*.tmp" -delete` | `rm -f **/*.tmp(N.)` |

## Eval Qualifier — Custom Filters

`e:'code':` runs shell code for each match. `$REPLY` is set to the filename. Return 0 to include, non-zero to exclude.

```zsh
# Files newer than a reference file
**/*(e:'[[ $REPLY -nt reference.txt ]]':)

# Files containing a specific string (without grep -rl)
**/*.zsh(e:'[[ $(<$REPLY) == *zparseopts* ]]':)

# Files where first line is a shebang
**/*(e:'read -r line < $REPLY; [[ $line == "#!"* ]]':)
```

## Function Qualifier

`+funcname` calls a function instead of inline code:

```zsh
is_zsh_script() {
  [[ $REPLY == *.zsh ]] || {
    read -r line < $REPLY
    [[ $line == "#!/"*zsh* ]]
  }
}
**/*(+is_zsh_script)
```

## Rename During Expansion

Set `$REPLY` to a different value, or `$reply` to multiple values:

```zsh
# Add .bak extension to each match
*.txt(e:'REPLY+=.bak':)

# Expand each match to two entries
*.txt(e:'reply=($REPLY ${REPLY%.txt}.md)':)
```

## Prepend Qualifier

`P:string:` prepends a string before each match:

```zsh
# Generate -f flags for each file
*.conf(P:-f:)
# Expands to: -f a.conf -f b.conf -f c.conf
```

## Practical Recipes

```zsh
# Most recently modified file in current directory
newest=(*(Dom[1]))

# 3 largest log files
print -l **/*.log(.OL[1,3])

# Delete empty directories recursively (leaves first)
rmdir **/*(D/od^F)

# All zsh files modified in last 3 hours, excluding .git
print -l ^.git/**/*.zsh(.mh-3)

# Files modified today, sorted newest first, with sizes
for f in **/*(D.m0om); do
  zstat -H st $f
  print -f "%10d  %s\n" ${st[size]} $f
done

# Count files by extension
typeset -A ext_count
for f in **/*(.); do
  ext=${f:e}
  (( ext_count[${ext:-none}]++ ))
done
for ext count in ${(kv)ext_count}; do
  print -f "%5d  .%s\n" $count $ext
done
```
