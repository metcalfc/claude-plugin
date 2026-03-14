#!/usr/bin/env bash
set -euo pipefail

# Validate plugin structure, cross-references, and behavioral contracts.
# Exit code: number of failures (0 = all pass).

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGINS_DIR="$REPO_ROOT/plugins"
MARKETPLACE="$REPO_ROOT/.claude-plugin/marketplace.json"
FAILURES=0
TESTS=0
PASSES=0

# ── Helpers ──────────────────────────────────────────────────────────

red()   { printf '\033[0;31m%s\033[0m\n' "$*"; }
green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[0;90m%s\033[0m\n' "$*"; }

pass() {
  TESTS=$((TESTS + 1))
  PASSES=$((PASSES + 1))
  green "  PASS: $1"
}

fail() {
  TESTS=$((TESTS + 1))
  FAILURES=$((FAILURES + 1))
  red "  FAIL: $1"
  if [[ -n "${2:-}" ]]; then
    dim "        $2"
  fi
}

section() {
  echo
  printf '── %s ──\n' "$1"
}

# Extract YAML frontmatter field from a .md file.
# Usage: frontmatter_field <file> <field>
frontmatter_field() {
  local file="$1" field="$2"
  # Read between first and second '---' lines, then extract the field
  sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | head -1 | sed "s/^${field}:[[:space:]]*//"
}

# Check if a file has YAML frontmatter
has_frontmatter() {
  head -1 "$1" | grep -q '^---$'
}

# ── Test: Plugin manifests ───────────────────────────────────────────

section "Plugin manifests"

for plugin_dir in "$PLUGINS_DIR"/*/; do
  plugin_name="$(basename "$plugin_dir")"
  manifest="$plugin_dir/.claude-plugin/plugin.json"

  if [[ ! -f "$manifest" ]]; then
    fail "$plugin_name: missing plugin.json" "$manifest"
    continue
  fi

  # Required fields
  for field in name version description; do
    val=$(jq -r ".$field // empty" "$manifest")
    if [[ -z "$val" ]]; then
      fail "$plugin_name: plugin.json missing '$field'"
    else
      pass "$plugin_name: plugin.json has '$field'"
    fi
  done

  # Name matches directory
  manifest_name=$(jq -r '.name' "$manifest")
  if [[ "$manifest_name" != "$plugin_name" ]]; then
    fail "$plugin_name: plugin.json name '$manifest_name' != directory name"
  else
    pass "$plugin_name: plugin.json name matches directory"
  fi
done

# ── Test: Marketplace registry ───────────────────────────────────────

section "Marketplace registry"

if [[ ! -f "$MARKETPLACE" ]]; then
  fail "marketplace.json missing" "$MARKETPLACE"
else
  # Every plugin directory has a marketplace entry
  for plugin_dir in "$PLUGINS_DIR"/*/; do
    plugin_name="$(basename "$plugin_dir")"
    entry=$(jq -r ".plugins[] | select(.name == \"$plugin_name\") | .name" "$MARKETPLACE")
    if [[ -z "$entry" ]]; then
      fail "$plugin_name: no marketplace entry"
    else
      pass "$plugin_name: marketplace entry exists"
    fi
  done

  # Version match: plugin.json vs marketplace.json
  for plugin_dir in "$PLUGINS_DIR"/*/; do
    plugin_name="$(basename "$plugin_dir")"
    manifest="$plugin_dir/.claude-plugin/plugin.json"
    [[ -f "$manifest" ]] || continue

    pv=$(jq -r '.version' "$manifest")
    mv=$(jq -r ".plugins[] | select(.name == \"$plugin_name\") | .version" "$MARKETPLACE")
    if [[ "$pv" != "$mv" ]]; then
      fail "$plugin_name: version mismatch — plugin.json=$pv, marketplace=$mv"
    else
      pass "$plugin_name: versions match ($pv)"
    fi
  done
fi

# ── Test: Standard commands ──────────────────────────────────────────

section "Standard commands (/add, /issue, /help)"

for plugin_dir in "$PLUGINS_DIR"/*/; do
  plugin_name="$(basename "$plugin_dir")"
  cmd_dir="$plugin_dir/commands"

  for cmd in add issue help; do
    cmd_file="$cmd_dir/$cmd.md"
    if [[ ! -f "$cmd_file" ]]; then
      fail "$plugin_name: missing commands/$cmd.md"
      continue
    fi
    pass "$plugin_name: commands/$cmd.md exists"

    # Check frontmatter exists
    if ! has_frontmatter "$cmd_file"; then
      fail "$plugin_name/$cmd: no YAML frontmatter"
      continue
    fi

    # Check name field matches
    name_val=$(frontmatter_field "$cmd_file" "name")
    if [[ "$name_val" != "$cmd" ]]; then
      fail "$plugin_name/$cmd: frontmatter name='$name_val', expected '$cmd'"
    else
      pass "$plugin_name/$cmd: frontmatter name correct"
    fi
  done
done

# ── Test: Command frontmatter ────────────────────────────────────────

section "Command frontmatter"

for plugin_dir in "$PLUGINS_DIR"/*/; do
  plugin_name="$(basename "$plugin_dir")"
  cmd_dir="$plugin_dir/commands"
  [[ -d "$cmd_dir" ]] || continue

  for cmd_file in "$cmd_dir"/*.md; do
    [[ -f "$cmd_file" ]] || continue
    cmd_name="$(basename "$cmd_file" .md)"

    if ! has_frontmatter "$cmd_file"; then
      fail "$plugin_name/$cmd_name: missing frontmatter"
      continue
    fi

    # Required: name
    name_val=$(frontmatter_field "$cmd_file" "name")
    if [[ -z "$name_val" ]]; then
      fail "$plugin_name/$cmd_name: frontmatter missing 'name'"
    else
      pass "$plugin_name/$cmd_name: has 'name' field"
    fi

    # Required: description
    desc_val=$(frontmatter_field "$cmd_file" "description")
    if [[ -z "$desc_val" ]]; then
      fail "$plugin_name/$cmd_name: frontmatter missing 'description'"
    else
      pass "$plugin_name/$cmd_name: has 'description' field"
    fi

    # Description prefix: must start with (plugin-name)
    if [[ -n "$desc_val" ]]; then
      expected_prefix="($plugin_name)"
      if [[ "$desc_val" != "$expected_prefix"* ]]; then
        fail "$plugin_name/$cmd_name: description doesn't start with '$expected_prefix'" "got: $desc_val"
      else
        pass "$plugin_name/$cmd_name: description prefix correct"
      fi
    fi

    # Required: allowed-tools (must be present, even if empty [])
    if ! grep -q 'allowed-tools' "$cmd_file"; then
      fail "$plugin_name/$cmd_name: frontmatter missing 'allowed-tools'"
    else
      pass "$plugin_name/$cmd_name: has 'allowed-tools' field"
    fi
  done
done

# ── Test: Agent files ────────────────────────────────────────────────

section "Agent frontmatter"

for plugin_dir in "$PLUGINS_DIR"/*/; do
  plugin_name="$(basename "$plugin_dir")"
  agent_dir="$plugin_dir/agents"
  [[ -d "$agent_dir" ]] || continue

  for agent_file in "$agent_dir"/*.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name="$(basename "$agent_file" .md)"

    if ! has_frontmatter "$agent_file"; then
      fail "$plugin_name/agents/$agent_name: missing frontmatter"
      continue
    fi

    name_val=$(frontmatter_field "$agent_file" "name")
    if [[ -z "$name_val" ]]; then
      fail "$plugin_name/agents/$agent_name: frontmatter missing 'name'"
    else
      pass "$plugin_name/agents/$agent_name: has 'name' field"
    fi

    desc_val=$(frontmatter_field "$agent_file" "description")
    if [[ -z "$desc_val" ]]; then
      fail "$plugin_name/agents/$agent_name: frontmatter missing 'description'"
    else
      pass "$plugin_name/agents/$agent_name: has 'description' field"
    fi
  done
done

# ── Test: code-review.md agent references ────────────────────────────

section "code-review.md agent cross-references"

CODE_REVIEW="$PLUGINS_DIR/chad-tools/commands/code-review.md"
AGENT_DIR="$PLUGINS_DIR/chad-tools/agents"

if [[ -f "$CODE_REVIEW" && -d "$AGENT_DIR" ]]; then
  # Extract agent names: **`agent-name`** (bold backtick in selection list) + "launch `agent-name`"
  # Only match names that look like agent names (contain a hyphen — all agents use kebab-case)
  referenced_agents=$(grep -oE '`[a-z]+-[a-z][-a-z]*`' "$CODE_REVIEW" | sed 's/`//g' | sort -u)

  for agent in $referenced_agents; do
    agent_file="$AGENT_DIR/$agent.md"
    if [[ -f "$agent_file" ]]; then
      pass "code-review.md: agent '$agent' exists"
    else
      fail "code-review.md: references agent '$agent' but $agent_file not found"
    fi
  done

  # Reverse: agents that exist but aren't referenced in code-review.md
  for agent_file in "$AGENT_DIR"/*.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name="$(basename "$agent_file" .md)"
    if ! echo "$referenced_agents" | grep -qx "$agent_name"; then
      # Not necessarily a failure — agent might be used elsewhere (e.g., issue-prepper)
      dim "  INFO: agent '$agent_name' exists but not referenced in code-review.md"
    fi
  done
fi

# ── Test: Skill directories ─────────────────────────────────────────

section "Skill structure"

for plugin_dir in "$PLUGINS_DIR"/*/; do
  plugin_name="$(basename "$plugin_dir")"
  skill_dir="$plugin_dir/skills"
  [[ -d "$skill_dir" ]] || continue

  for skill in "$skill_dir"/*/; do
    [[ -d "$skill" ]] || continue
    skill_name="$(basename "$skill")"

    if [[ ! -f "$skill/SKILL.md" ]]; then
      fail "$plugin_name/skills/$skill_name: missing SKILL.md"
    else
      pass "$plugin_name/skills/$skill_name: SKILL.md exists"

      # Check frontmatter
      if ! has_frontmatter "$skill/SKILL.md"; then
        fail "$plugin_name/skills/$skill_name: SKILL.md missing frontmatter"
      else
        pass "$plugin_name/skills/$skill_name: SKILL.md has frontmatter"
      fi
    fi
  done
done

# ── Test: Agent test fixtures ────────────────────────────────────────

section "Agent test fixtures"

FIXTURES_DIR="$REPO_ROOT/tests/fixtures/agents"
if [[ -d "$FIXTURES_DIR" ]]; then
  for fixture_dir in "$FIXTURES_DIR"/*/; do
    [[ -d "$fixture_dir" ]] || continue
    fixture_name="$(basename "$fixture_dir")"

    # Required files
    if [[ ! -f "$fixture_dir/fixture.diff" ]]; then
      fail "fixture/$fixture_name: missing fixture.diff"
    else
      pass "fixture/$fixture_name: fixture.diff exists"
    fi

    expect_file="$fixture_dir/expect.json"
    if [[ ! -f "$expect_file" ]]; then
      fail "fixture/$fixture_name: missing expect.json"
      continue
    else
      pass "fixture/$fixture_name: expect.json exists"
    fi

    # Valid JSON
    if ! jq empty "$expect_file" 2>/dev/null; then
      fail "fixture/$fixture_name: expect.json is invalid JSON"
      continue
    else
      pass "fixture/$fixture_name: expect.json is valid JSON"
    fi

    # Required fields
    agent_name=$(jq -r '.agent // empty' "$expect_file")
    if [[ -z "$agent_name" ]]; then
      fail "fixture/$fixture_name: expect.json missing 'agent' field"
    else
      pass "fixture/$fixture_name: has 'agent' field ($agent_name)"

      # Agent file must exist
      agent_file="$PLUGINS_DIR/chad-tools/agents/$agent_name.md"
      if [[ -f "$agent_file" ]]; then
        pass "fixture/$fixture_name: agent '$agent_name' exists"
      else
        fail "fixture/$fixture_name: references agent '$agent_name' but file not found"
      fi
    fi

    # expect_status must be a non-empty array
    status_count=$(jq '.expect_status | length' "$expect_file" 2>/dev/null)
    if [[ "$status_count" -gt 0 ]]; then
      pass "fixture/$fixture_name: has expect_status"
    else
      fail "fixture/$fixture_name: expect_status missing or empty"
    fi

    # Description exists
    desc=$(jq -r '.description // empty' "$expect_file")
    if [[ -n "$desc" ]]; then
      pass "fixture/$fixture_name: has description"
    else
      fail "fixture/$fixture_name: missing description"
    fi
  done
else
  dim "  INFO: no agent test fixtures directory found"
fi

# ── Test: Behavioral contracts ───────────────────────────────────────

section "Behavioral contracts"

# Commands that poll CI must have retry limits
for cmd_file in "$PLUGINS_DIR"/chad-tools/commands/*.md; do
  [[ -f "$cmd_file" ]] || continue
  cmd_name="$(basename "$cmd_file" .md)"

  if grep -q 'gh pr checks' "$cmd_file"; then
    if grep -q 'max\|retry\|once\|one retry\|1 retry' "$cmd_file"; then
      pass "$cmd_name: CI polling has retry limit"
    else
      fail "$cmd_name: polls CI but no retry limit documented"
    fi
  fi
done

# Commands that push must use --force-with-lease (not bare --force)
for cmd_file in "$PLUGINS_DIR"/chad-tools/commands/*.md; do
  [[ -f "$cmd_file" ]] || continue
  cmd_name="$(basename "$cmd_file" .md)"

  if grep -q 'git push' "$cmd_file"; then
    # Check for bare --force without --force-with-lease
    if grep -q '\-\-force[^-]' "$cmd_file" && ! grep -q '\-\-force-with-lease' "$cmd_file"; then
      fail "$cmd_name: uses --force without --force-with-lease"
    elif grep -q 'git push' "$cmd_file"; then
      pass "$cmd_name: push commands use safe force options"
    fi
  fi
done

# Commands that use AskUserQuestion before destructive actions
for cmd_file in "$PLUGINS_DIR"/chad-tools/commands/*.md; do
  [[ -f "$cmd_file" ]] || continue
  cmd_name="$(basename "$cmd_file" .md)"

  # Commands with conflict resolution should show complex conflicts to user
  if grep -q 'conflict' "$cmd_file" && grep -q 'AskUserQuestion' "$cmd_file"; then
    pass "$cmd_name: conflict resolution involves user confirmation"
  fi
done

# code-review.md: pr-test-analyzer must trigger on implementation without tests
if grep -q 'Implementation without tests' "$CODE_REVIEW"; then
  pass "code-review.md: pr-test-analyzer triggers on implementation without tests"
else
  fail "code-review.md: pr-test-analyzer only triggers on test files — missing test gap detection"
fi

# code-reviewer.md: must check test coverage
CODE_REVIEWER="$AGENT_DIR/code-reviewer.md"
if [[ -f "$CODE_REVIEWER" ]]; then
  if grep -qi 'test coverage' "$CODE_REVIEWER"; then
    pass "code-reviewer.md: includes test coverage check"
  else
    fail "code-reviewer.md: missing test coverage check in correctness section"
  fi
fi

# pr-test-analyzer.md: missing tests must be blocking severity
PR_TEST="$AGENT_DIR/pr-test-analyzer.md"
if [[ -f "$PR_TEST" ]]; then
  if grep -q 'blocking' "$PR_TEST" && grep -qi 'missing test' "$PR_TEST"; then
    pass "pr-test-analyzer.md: missing tests flagged as blocking"
  else
    fail "pr-test-analyzer.md: missing tests not marked as blocking severity"
  fi
fi

# ── Test: Hooks ──────────────────────────────────────────────────────

section "Hook files"

for plugin_dir in "$PLUGINS_DIR"/*/; do
  plugin_name="$(basename "$plugin_dir")"
  hooks_dir="$plugin_dir/hooks"
  [[ -d "$hooks_dir" ]] || continue

  hooks_json="$hooks_dir/hooks.json"
  if [[ -f "$hooks_json" ]]; then
    # Validate JSON syntax
    if jq empty "$hooks_json" 2>/dev/null; then
      pass "$plugin_name: hooks.json is valid JSON"
    else
      fail "$plugin_name: hooks.json is invalid JSON"
    fi

    # Check that referenced scripts exist
    scripts=$(jq -r '.. | .command? // empty' "$hooks_json" 2>/dev/null | grep -oE '[^ ]*\.sh' || true)
    for script in $scripts; do
      # Resolve ${CLAUDE_PLUGIN_ROOT} to the plugin directory
      resolved="${script/\$\{CLAUDE_PLUGIN_ROOT\}/$plugin_dir}"
      # Also try relative to hooks dir
      if [[ -f "$resolved" ]]; then
        basename_script=$(basename "$script")
        pass "$plugin_name: hook script '$basename_script' exists"
      elif [[ -f "$hooks_dir/$(basename "$script")" ]]; then
        pass "$plugin_name: hook script '$(basename "$script")' exists"
      else
        fail "$plugin_name: hooks.json references '$script' but file not found"
      fi
    done
  fi
done

# ── Summary ──────────────────────────────────────────────────────────

echo
echo "════════════════════════════════════════"
printf 'Tests: %d | ' "$TESTS"
green "Passed: $PASSES" | tr -d '\n'
printf ' | '
if [[ "$FAILURES" -gt 0 ]]; then
  red "Failed: $FAILURES"
else
  green "Failed: 0"
fi
echo "════════════════════════════════════════"

exit "$FAILURES"
