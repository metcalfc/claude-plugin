# Zsh Modules

Load with `zmodload module-name`. Use `zmodload -F module b:builtin` for selective loading to avoid overriding external commands.

## zsh/datetime — Timestamps Without date

```zsh
zmodload zsh/datetime

# Current unix timestamp (integer)
print $EPOCHSECONDS

# High-resolution timestamp (float, microsecond precision)
print $EPOCHREALTIME

# Format timestamps (replaces date +FORMAT)
strftime "%Y-%m-%d %H:%M:%S" $EPOCHSECONDS
strftime "%Y-%m-%d" $EPOCHSECONDS

# Store in variable
strftime -s formatted "%Y-%m-%d" $EPOCHSECONDS

# Benchmarking
local start=$EPOCHREALTIME
# ... operation ...
local elapsed=$(( EPOCHREALTIME - start ))
print -f "Took %.3f seconds\n" $elapsed

# Parse date string to timestamp (strftime -r)
strftime -r -s timestamp "%Y-%m-%d" "2024-03-15"
```

### Replacing date Commands
```zsh
# date +%s                → $EPOCHSECONDS
# date +"%Y-%m-%d"        → strftime "%Y-%m-%d" $EPOCHSECONDS
# date -d @1234567890     → strftime "%Y-%m-%d %H:%M:%S" 1234567890
# date -d "2024-03-15" +%s → strftime -r -s ts "%Y-%m-%d" "2024-03-15"
```

## zsh/stat — File Metadata Without stat/ls

Load selectively to avoid shadowing GNU/BSD `stat`:

```zsh
zmodload -F zsh/stat b:zstat
```

### Basic Usage
```zsh
# Get specific fields
zstat +size file.txt       # size in bytes
zstat +mtime file.txt      # modification time (unix timestamp)
zstat +mode file.txt       # permissions (decimal integer, e.g. 33188 = 0100644)
zstat +uid file.txt        # owner UID
zstat +nlink file.txt      # hard link count

# Store all fields in associative array
local -A st
zstat -H st file.txt
print "size=${st[size]} mtime=${st[mtime]} mode=${st[mode]}"

# Human-readable mode string
zstat -s +mode file.txt    # -rw-r--r--
```

### Symlinks and lstat
```zsh
zmodload -F zsh/stat b:zstat

# Don't follow symlinks (lstat)
ln -s file.txt mylink
zstat -L +size mylink      # size of symlink itself
```

### Available Fields
`device`, `inode`, `mode`, `nlink`, `uid`, `gid`, `rdev`, `size`, `atime`, `mtime`, `ctime`, `blksize`, `blocks`, `link` (symlink target)

### Practical Examples
```zsh
zmodload -F zsh/stat b:zstat
zmodload zsh/datetime

# File age in seconds
local -A st
zstat -H st file.txt
local age=$(( EPOCHSECONDS - st[mtime] ))
print "File is $age seconds old"

# Find largest file in directory
local largest="" largest_size=0
for f in *(N.); do
  zstat -H st $f
  (( st[size] > largest_size )) && { largest=$f; largest_size=$st[size] }
done
print "$largest: $largest_size bytes"

# List files with human-readable sizes
for f in *(N.oL); do
  zstat -H st $f
  local size=$st[size]
  if (( size >= 1048576 )); then
    print -f "%6.1fM  %s\n" $(( size / 1048576.0 )) $f
  elif (( size >= 1024 )); then
    print -f "%6.1fK  %s\n" $(( size / 1024.0 )) $f
  else
    print -f "%6dB  %s\n" $size $f
  fi
done
```

## zsh/mapfile — File I/O Without cat

```zsh
zmodload zsh/mapfile

# Read entire file
content=${mapfile[/path/to/file]}

# Write to file (overwrites)
mapfile[/path/to/output]="new content"

# Delete a file
unset 'mapfile[/path/to/file]'

# Check if file exists and is readable
[[ -v mapfile[/path/to/file] ]]   # won't work — always "exists"
# Use [[ -r file ]] instead for existence checking

# Read into array of lines
local -a lines=("${(@f)mapfile[file.txt]}")

# Process without temp variables
for line in "${(@f)mapfile[config.txt]}"; do
  [[ $line == \#* ]] && continue    # skip comments
  [[ -z $line ]] && continue        # skip empty
  print "Config: $line"
done
```

**Caveat**: Entire file is loaded into memory. Not suitable for huge files.

## zsh/mathfunc — Math Without bc

```zsh
zmodload zsh/mathfunc

# Trigonometry
print $(( sin(3.14159 / 2) ))    # ~1.0
print $(( cos(0) ))              # 1.0
print $(( atan(1) * 4 ))         # pi
print $(( atan2(1, 1) ))         # pi/4

# Powers and logarithms
print $(( sqrt(2) ))             # 1.41421...
print $(( exp(1) ))              # e = 2.71828...
print $(( log(100) ))            # 4.60517... (natural log)
print $(( log10(1000) ))         # 3.0
print $(( pow(2, 10) ))          # 1024 (or use 2**10)

# Rounding
print $(( floor(3.7) ))          # 3
print $(( ceil(3.2) ))           # 4
print $(( int(3.9) ))            # 3 (truncate)

# Absolute value
print $(( abs(-42) ))            # 42
print $(( abs(-3.14) ))          # 3.14

# Random float [0,1)
print $(( rand48() ))

# Min/max (load zmathfunc first)
autoload -Uz zmathfunc && zmathfunc
print $(( max(3, 7, 1) ))        # 7
print $(( min(3, 7, 1) ))        # 1
print $(( sum(1, 2, 3, 4) ))     # 10
```

### Zsh Arithmetic Basics
```zsh
# Integer
typeset -i x=10
(( x++ ))
(( x += 5 ))

# Float (must declare or use float literal)
typeset -F result
(( result = 22.0 / 7 ))    # 3.142857

# Base conversion
print $(( 16#ff ))          # 255 (hex → decimal)
print $(( 2#1010 ))         # 10  (binary → decimal)
print $(( [#16] 255 ))      # 16#FF (decimal → hex)
print $(( [#2] 10 ))        # 2#1010 (decimal → binary)

# Ternary
print $(( x > 5 ? 1 : 0 ))

# Bitwise
print $(( x & 0xff ))       # AND
print $(( x | 0x80 ))       # OR
print $(( x << 2 ))         # left shift
```

## zsh/pcre — Perl-Compatible Regex

```zsh
zmodload zsh/pcre

# Compile and test
pcre_compile "^[a-z]+(\d+)$"
if pcre_match "hello123"; then
  print $MATCH       # hello123
  print $match[1]    # 123
fi

# In [[ ]] with -pcre-match
setopt RE_MATCH_PCRE    # make =~ use PCRE
if [[ "2024-03-15" =~ "^(\d{4})-(\d{2})-(\d{2})$" ]]; then
  print "Year:  $match[1]"
  print "Month: $match[2]"
  print "Day:   $match[3]"
fi
```

## zsh/zutil — zparseopts, zstyle, zformat

See `references/zparseopts.md` for zparseopts detail.

### zstyle — Configuration System
```zsh
# Set styles (like a hierarchical key-value store)
zstyle ':myapp:server:*' timeout 30
zstyle ':myapp:server:prod' timeout 60
zstyle ':myapp:*' verbose true

# Retrieve
local timeout
zstyle -s ':myapp:server:prod' timeout timeout    # 60 (most specific wins)
zstyle -s ':myapp:server:dev' timeout timeout     # 30 (wildcard match)

# Boolean test
zstyle -t ':myapp:' verbose && print "Verbose mode"

# Array values
zstyle ':myapp:' allowed-hosts host1 host2 host3
local -a hosts
zstyle -a ':myapp:' allowed-hosts hosts
```

### zformat — Named Formatting
```zsh
# Named format specifiers
local result
zformat -f result "%-20n %5a years" "n:Alice" "a:30"

# Column alignment
local -a aligned
zformat -a aligned ' -- ' "name:Alice" "age:30" "city:NYC"
print -l $aligned
```

## zsh/terminfo — Portable Terminal Colors

```zsh
zmodload zsh/terminfo

# Non-parameterized capabilities via associative array
print "${terminfo[bold]}bold text${terminfo[sgr0]}"
print "${terminfo[smul]}underlined${terminfo[rmul]}"

# Parameterized capabilities use echoti (not ${terminfo[...]})
echoti setaf 1; print "red"; echoti sgr0
echoti setaf 2; print "green"; echoti sgr0

# Store in variable for reuse
local red=$(echoti setaf 1) green=$(echoti setaf 2) reset=$(echoti sgr0)
print "${red}error${reset}: ${green}ok${reset}"
```

Note: `${terminfo[bold]}` works for non-parameterized capabilities. For colors (which take a parameter), use `echoti setaf N`. For most scripting, `print -P "%F{red}..."` is simpler. Use `zsh/terminfo` when you need terminal capability detection or portability beyond zsh.

## zsh/system — Low-Level System Calls

```zsh
zmodload zsh/system

# File locking (advisory locks)
zsystem flock /tmp/myapp.lock
# ... critical section ...
zsystem flock -u /tmp/myapp.lock

# Or with a file descriptor:
exec {lockfd}>/tmp/myapp.lock
zsystem flock -f lockfd
# ... critical section ...
exec {lockfd}>&-    # close releases lock

# System read/write (low-level I/O)
sysopen -r -o creat -u 3 /tmp/data
sysread -i 3 -o 1 -c 100    # read 100 bytes from fd 3 to stdout
```

## Module Loading Patterns

```zsh
# Load only if available (graceful degradation)
zmodload zsh/datetime 2>/dev/null || {
  # Fallback: define strftime wrapper using date
  strftime() { date -d "@$2" +"$1" }
}

# Selective loading (avoid overriding external commands)
zmodload -F zsh/stat b:zstat    # only load zstat, not stat

# Check if module is loaded
if zmodload -e zsh/datetime; then
  print "datetime module available"
fi

# List loaded modules
zmodload    # prints all currently loaded modules
```

## Quick Reference: Which Module For What

| Instead of | Use module | Feature |
|------------|-----------|---------|
| `date +%s` | `zsh/datetime` | `$EPOCHSECONDS` |
| `date +FORMAT` | `zsh/datetime` | `strftime` |
| `stat -c %s file` | `zsh/stat` | `zstat +size` |
| `cat file` | `zsh/mapfile` | `$mapfile[file]` |
| `bc <<< "sqrt(2)"` | `zsh/mathfunc` | `$(( sqrt(2) ))` |
| `grep -P 'regex'` | `zsh/pcre` | `pcre_match` / `-pcre-match` |
| `flock /tmp/lock` | `zsh/system` | `zsystem flock` |
| `tput bold` | `zsh/terminfo` | `$terminfo[bold]` |
