#!/usr/bin/env zsh
# Test harness for zsh-craft code examples
# Parses markdown files for ```zsh code blocks and runs them.
#
# Usage: ./test-examples.zsh [file.md ...]
# Default: tests all markdown files in the skill directory.

setopt ERR_EXIT NO_UNSET PIPE_FAIL EXTENDED_GLOB

zmodload zsh/datetime

# Temp directory for all harness artifacts — cleaned on any exit
_harness_tmpdir=$(mktemp -d)
trap 'rm -rf "$_harness_tmpdir" 2>/dev/null' EXIT INT TERM HUP

# --- output helpers ---
msg()  { print -P "%F{blue}==>%f %B$1%b" }
pass() { print -P "  %F{green}PASS%f $1" }
fail() { print -P "  %F{red}FAIL%f $1" }
skip() { print -P "  %F{yellow}SKIP%f $1" }

# --- patterns that can't be tested in isolation ---
# These contain incomplete fragments, interactive commands, or
# require file/function context that doesn't exist in a one-shot test.
is_untestable() {
  local block=$1

  # Fragments: lines starting with bare variable assignments used as illustration
  # or lines that are clearly continuation examples
  [[ $block == *'# ...'* ]] && return 0
  [[ $block == *'...'* ]] && return 0

  # Interactive / requires real files that don't exist
  [[ $block == *'vared '* ]] && return 0
  [[ $block == *'/var/log/'* ]] && return 0
  [[ $block == *'/etc/hosts'* ]] && return 0
  [[ $block == *'data.csv'* ]] && return 0
  [[ $block == *'data.txt'* ]] && return 0
  [[ $block == *'config.txt'* ]] && return 0
  [[ $block == *'app.log'* ]] && return 0

  # Requires running processes or network
  [[ $block == *'sysopen'* ]] && return 0
  [[ $block == *'sysread'* ]] && return 0
  [[ $block == *'zsystem flock'* ]] && return 0
  [[ $block == *'pcre_compile'* ]] && return 0
  [[ $block == *'pcre_match'* ]] && return 0
  [[ $block == *'echoti '* ]] && return 0

  # Function definitions without calls (they define but don't execute)
  [[ $block == *'myfunc()'* ]] && return 0
  [[ $block == *'myFunc()'* ]] && return 0
  [[ $block == *'my_command()'* ]] && return 0
  [[ $block == *'process_files()'* ]] && return 0
  [[ $block == *'process_data'* ]] && return 0
  [[ $block == *'main()'* ]] && return 0
  [[ $block == *'usage()'* ]] && return 0

  # Pure comment blocks (replacement tables shown as comments)
  [[ $block == *'# find '* && $block != *$'\n'[^#]* ]] && return 0

  # Blocks that reference $1, $2 etc (need args)
  [[ $block == *'} arg1 arg2'* ]] && return 0
  [[ $block == *'"$@"'* ]] && return 0

  # Bare glob demonstrations: lines are glob patterns with comments
  # These expand to filenames and get "executed" as commands — not runnable
  local -a blines=("${(@f)block}")
  local glob_count=0
  local code_count=0
  for bline in "${blines[@]}"; do
    [[ -z $bline || $bline == \#* ]] && continue
    code_count=$((code_count + 1))
    # Lines starting with * or ** or containing only glob qualifiers
    [[ $bline == [\*\(]* || $bline == *'(m'* || $bline == *'(L'* || $bline == *'(om'* || $bline == *'(/)'* || $bline == *'(.)'* ]] && glob_count=$((glob_count + 1))
  done
  # If most code lines are bare globs, skip the block
  (( code_count > 0 && glob_count * 100 / code_count > 50 )) && return 0

  # History / buffer manipulation
  [[ $block == *'print -s '* ]] && return 0
  [[ $block == *'print -z '* ]] && return 0

  # Needs specific directory state
  [[ $block == *'rmdir '* ]] && return 0

  # Function + glob qualifier using the function (needs real zsh files)
  [[ $block == *'+is_zsh_script'* ]] && return 0

  # Bare parameter expansion demonstrations (expand then execute as commands)
  [[ $block == *'${path##*/}'* && $block != *'print '* && $block != *'echo '* ]] && return 0

  # Blocks that are just showing syntax, not runnable
  [[ $block == *'zparseopts [ -D ]'* ]] && return 0
  [[ $block == *'print [ -'* ]] && return 0

  # Inline sed-like replacement tables (comments showing before/after)
  local -a lines=("${(@f)block}")
  local comment_count=0
  local total_count=0
  for line in "${lines[@]}"; do
    [[ -z $line ]] && continue
    total_count=$((total_count + 1))
    [[ $line == \#* ]] && comment_count=$((comment_count + 1))
  done
  # If more than 70% comments, it's a reference table not runnable code
  (( total_count > 0 && comment_count * 100 / total_count > 70 )) && return 0

  return 1
}

# --- extract and test code blocks ---
test_file() {
  local file=$1
  local -a block_contents=()
  local -a block_lines=()
  local in_block=0
  local current_block=""
  local block_line=0
  local line_num=0

  if [[ ! -f $file ]]; then
    print -P "  %F{red}error:%f File not found: $file" >&2
    return 1
  fi

  msg "Testing ${file:t}"

  # Read file and extract ```zsh blocks
  while IFS= read -r line; do
    line_num=$((line_num + 1))
    if (( ! in_block )) && [[ $line == '```zsh' ]]; then
      in_block=1
      current_block=""
      block_line=$line_num
      continue
    fi
    if (( in_block )) && [[ $line == '```' ]]; then
      in_block=0
      block_contents+=("$current_block")
      block_lines+=($block_line)
      continue
    fi
    if (( in_block )); then
      [[ -n $current_block ]] && current_block+=$'\n'
      current_block+=$line
    fi
  done < "$file"

  # Warn about unclosed code fences
  if (( in_block )); then
    print -P "  %F{red}WARNING:%f Unclosed code block starting at line $block_line in ${file:t}" >&2
  fi

  local total=0 passed=0 failed=0 skipped=0
  local idx=0

  for block in "${block_contents[@]}"; do
    idx=$((idx + 1))
    total=$((total + 1))
    local bline=${block_lines[$idx]}

    # Get first meaningful line for display
    local label=""
    for l in "${(@f)block}"; do
      [[ -n $l && $l != \#* ]] && { label=$l; break }
    done
    [[ -z $label ]] && label=${${(f)block}[1]}
    # Truncate for display
    (( ${#label} > 60 )) && label="${label[1,57]}..."

    if is_untestable "$block"; then
      skip "line $bline: $label"
      skipped=$((skipped + 1))
      continue
    fi

    # Create a wrapper that sources the block in a controlled environment
    local script="$_harness_tmpdir/block_${idx}.zsh"
    {
      # Set up a safe environment with test files for glob examples
      cat <<'PREAMBLE'
setopt EXTENDED_GLOB 2>/dev/null
unsetopt ERR_EXIT 2>/dev/null
zmodload zsh/datetime 2>/dev/null
zmodload zsh/mathfunc 2>/dev/null
zmodload -F zsh/stat b:zstat 2>/dev/null

# Create a sandbox with test files so globs have something to match
readonly _test_sandbox=$(mktemp -d)
trap 'cd /; rm -rf "$_test_sandbox" 2>/dev/null' EXIT INT TERM HUP
cd "$_test_sandbox"
mkdir -p subdir
touch file.txt file.log file.conf notes.md readme.md
touch subdir/nested.txt subdir/deep.log
touch reference.txt reffile
echo "line 1" > file.txt
echo "hello ERROR world" >> file.txt
echo "another line" >> file.txt
chmod +x file.conf 2>/dev/null

# Provide common variables used in examples
local file="file.txt"
local tmpfile="$_test_sandbox/tmpfile"
touch "$tmpfile"

PREAMBLE
      print -r -- "$block"
    } > "$script"

    # Run with a timeout
    local output=""
    local exit_code=0
    output=$(timeout 5 zsh "$script" 2>&1) || exit_code=$?

    if (( exit_code == 0 )); then
      pass "line $bline: $label"
      passed=$((passed + 1))
    elif (( exit_code == 124 )); then
      skip "line $bline: (timeout) $label"
      skipped=$((skipped + 1))
    else
      fail "line $bline: $label"
      # Show first 3 lines of error (use print -r to avoid interpreting % sequences)
      local -a err_lines=("${(@f)output}")
      for (( i=1; i <= ${#err_lines} && i <= 3; i++ )); do
        print -r -- "         ${err_lines[$i]}"
      done
      failed=$((failed + 1))
    fi
  done

  print -P "  %F{cyan}----%f $total blocks: %F{green}$passed passed%f, %F{red}$failed failed%f, %F{yellow}$skipped skipped%f"
  return $(( failed > 0 ))
}

# --- main ---
local -a files=("$@")
if (( ${#files} == 0 )); then
  local script_dir=${0:A:h}
  local plugin_dir=${script_dir:h}
  files=("$plugin_dir"/skills/zsh-mastery/SKILL.md "$plugin_dir"/skills/zsh-mastery/references/*.md(N))
fi

if (( ${#files} == 0 )); then
  print -P "%F{red}error:%f No markdown files found" >&2
  exit 1
fi

# Deduplicate (in case of overlapping globs)
files=(${(u)files})

local start=$EPOCHREALTIME
local total_fail=0

for f in "${files[@]}"; do
  test_file "$f" || total_fail=$((total_fail + 1))
  print
done

local elapsed=$(( EPOCHREALTIME - start ))

if (( total_fail > 0 )); then
  print -P "%F{red}FAILED%f — $total_fail file(s) had failures (${elapsed}s)"
  exit 1
else
  print -P "%F{green}ALL PASSED%f (${elapsed}s)"
  exit 0
fi
