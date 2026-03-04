# String Operations Without External Tools

Every `grep`, `sed`, `awk`, `cut`, `tr`, `wc`, and `sort` call in a zsh script can be replaced with native parameter expansion, pattern matching, or builtins.

## Replacing sed

### Substitution
```zsh
str="hello world hello"

# sed 's/hello/hi/'     → first occurrence
${str/hello/hi}          # "hi world hello"

# sed 's/hello/hi/g'    → all occurrences
${str//hello/hi}         # "hi world hi"

# sed 's/^hello/hi/'    → anchor at start
${str/#hello/hi}         # "hi world hello"

# sed 's/hello$/hi/'    → anchor at end
${str/%hello/hi}         # "hello world hi"

# sed '/pattern/d'      → delete matching lines
local -a lines=("${(@f)str}")
print -l ${lines:#*pattern*}    # remove matches

# sed -n '/pattern/p'   → keep matching lines
print -l ${(M)lines:#*pattern*}  # keep matches
```

### Prefix/Suffix Removal
```zsh
path="/home/user/dir/file.tar.gz"

# basename (sed 's|.*/||')
${path##*/}              # file.tar.gz

# dirname (sed 's|/[^/]*$||')
${path%/*}               # /home/user/dir

# Remove extension
${path%.*}               # /home/user/dir/file.tar

# Remove all extensions
${path%%.*}              # /home/user/dir/file

# Get extension only
${path##*.}              # gz

# Nested: basename without extension
${${path##*/}%.*}        # file.tar

# Zsh also has path modifiers:
${path:t}    # file.tar.gz  (tail = basename)
${path:h}    # /home/user/dir  (head = dirname)
${path:r}    # /home/user/dir/file.tar  (remove extension)
${path:e}    # gz  (extension)
${path:t:r}  # file.tar  (basename, remove ext)
```

## Replacing grep

### Filter Array Elements
```zsh
local -a lines=("${(@f)"$(<file)"}")

# grep "pattern"        → keep matching
${(M)lines:#*pattern*}

# grep -v "pattern"     → exclude matching
${lines:#*pattern*}

# grep -i "pattern"     → case insensitive
${(M)lines:#(#i)*pattern*}

# grep -c "pattern"     → count matches
${#${(M)lines:#*pattern*}}
```

### Regex Matching in Scalars
```zsh
# grep -oP 'pattern' (extract match from string)
if [[ $str =~ "([0-9]+)" ]]; then
  print $match[1]    # first capture group
  print $MATCH       # full match
fi

# With EXTENDED_GLOB and #b for native matching:
setopt EXTENDED_GLOB
if [[ $str = (#b)*([0-9]##)* ]]; then
  print $match[1]    # first capture
fi
```

### grep -rl (files containing pattern)
```zsh
# Find files containing a string — no grep subprocess
for f in **/*.zsh(N.); do
  [[ $(<$f) == *zparseopts* ]] && print $f
done
```

## Replacing awk/cut

### Field Extraction
```zsh
line="alice:30:admin:active"

# cut -d: -f2         → field by delimiter
${${(s.:.)line}[2]}    # 30

# cut -d: -f2-4       → field range
${(j.:.)${(s.:.)line}[2,4]}    # 30:admin:active

# awk '{print $2}'    → whitespace-separated
${${(s: :)line}[2]}

# awk -F, '{print $NF}'  → last field
${${(s:,:)line}[-1]}

# awk '{print NF}'    → field count
${#${(s: :)line}}
```

### Columnar Processing
```zsh
# Process each line, extract fields
local -a lines=("${(@f)"$(<data.txt)"}")
for line in "${lines[@]}"; do
  local -a fields=(${=line})    # split on whitespace
  print "${fields[1]} -> ${fields[3]}"
done
```

## Replacing tr

```zsh
str="Hello World"

# tr '[:lower:]' '[:upper:]'
${(U)str}                # HELLO WORLD

# tr '[:upper:]' '[:lower:]'
${(L)str}                # hello world

# tr -d 'aeiou'  (delete chars)
${str//[aeiou]/}         # Hll Wrld

# tr ' ' '_'  (single char replace)
${str// /_}              # Hello_World

# tr -s ' '  (squeeze repeated)
${str//  #/ }            # requires EXTENDED_GLOB; ## means one-or-more
```

## Replacing wc

```zsh
content=$(<file.txt)

# wc -l  (line count)
local -a lines=("${(@f)content}")
print ${#lines}

# wc -w  (word count)
local -a words=(${=content})
print ${#words}

# wc -c  (byte count)
print ${#content}
```

## Replacing sort/uniq

```zsh
local -a items=(banana apple cherry apple banana date)

# sort
print -l ${(o)items}

# sort -r
print -l ${(O)items}

# sort -u (sort + unique)
print -l ${(uo)items}

# sort -n
local -a nums=(10 2 1 20 3)
print -l ${(on)nums}

# sort -f (case-insensitive)
print -l ${(oi)items}

# uniq (deduplicate, preserving order)
print -l ${(u)items}

# uniq -c (count occurrences)
typeset -A counts
for item in "${items[@]}"; do
  (( counts[$item]++ ))
done
for item count in ${(kv)counts}; do
  print -f "%7d %s\n" $count $item
done
```

## Replacing rev

```zsh
str="hello"
# Reverse a string
print ${(j::)${(@Oa)${(s::)str}}}    # olleh
```

## Reading Files

```zsh
# cat file           →
$(<file)

# cat file | head -5  →
local -a lines=("${(@f)"$(<file)"}")
print -l "${lines[1,5]}"

# cat file | tail -5  →
print -l "${lines[-5,-1]}"

# cat file | head -1  →
read -r first_line < file

# Entire file into variable (alternative with zsh/mapfile):
zmodload zsh/mapfile
content=${mapfile[file.txt]}
```

## Pattern Matching Without =~

For simple patterns, use zsh glob matching instead of regex:

```zsh
# Check if string is all digits
[[ $str == [0-9]## ]]     # EXTENDED_GLOB: ## = one or more

# Check if string starts with prefix
[[ $str == prefix* ]]

# Check if string ends with suffix
[[ $str == *suffix ]]

# Check if string contains substring
[[ $str == *substring* ]]

# Case-insensitive match
[[ $str == (#i)pattern* ]]
```

## Composing Operations

Chain parameter expansions for multi-step transforms:

```zsh
# Read CSV, get unique values from column 3, sorted, uppercase
typeset -a col3
local -a lines=("${(@f)"$(<data.csv)"}")
for line in "${lines[@]}"; do
  col3+=(${${(s:,:)line}[3]})
done
print -l ${(uoU)col3}

# Slugify a string: lowercase, replace non-alnum with hyphens, squeeze
slug=${(L)input}
slug=${slug//[^a-z0-9]/-}
slug=${slug//--##/-}        # squeeze multiple hyphens (EXTENDED_GLOB)
slug=${slug#-}              # trim leading
slug=${slug%-}              # trim trailing
```
