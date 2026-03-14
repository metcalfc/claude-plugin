---
name: test-agents
description: (chad-tools) Run review agents against known-bad diff fixtures to verify correctness
argument-hint: "[fixture-name|all]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Agent
  - AskUserQuestion
---

Self-test for review agents. Runs each agent against a known-bad diff fixture and verifies it produces the expected findings. This catches regressions when agent prompts are modified.

## Step 1: Discover Fixtures

Find all fixture directories under `tests/fixtures/agents/` in the repo root:

```bash
git rev-parse --show-toplevel
```

Then list subdirectories of `<repo_root>/tests/fixtures/agents/`. Each subdirectory is a fixture containing:
- `fixture.diff` — the diff to review
- `expect.json` — expected agent behavior

If `$ARGUMENTS` specifies a fixture name (not "all" and not empty), run only that fixture. Otherwise run all.

Validate each fixture before running: both files must exist and `expect.json` must be valid JSON. Skip invalid fixtures with a warning.

## Step 2: Load Fixture Expectations

Read `expect.json` for each fixture. Schema:

```json
{
  "agent": "agent-name",
  "description": "Human-readable description of what this tests",
  "expect_status": ["DONE"],
  "expect_findings_min": 1,
  "expect_findings": [
    {
      "category": "security|correctness",
      "severity": "blocking|non-blocking",
      "file_pattern": "partial filename match",
      "description": "What the finding should be about (for human reference, not matched)"
    }
  ],
  "expect_no_blocking": false
}
```

Fields:
- `agent` — which agent to run (must match a file in `plugins/chad-tools/agents/`)
- `expect_status` — array of acceptable status values
- `expect_findings_min` — minimum number of findings expected
- `expect_findings` — specific findings to look for (matched by subset of fields)
- `expect_no_blocking` — if true, assert that NO findings have severity "blocking"

## Step 3: Read Agent Definition

For each fixture, read the agent definition file:
```
plugins/chad-tools/agents/<agent-name>.md
```

This contains the agent's system prompt and review instructions.

## Step 4: Run Agent

For each fixture, launch the agent using the Agent tool. The prompt should be:

```
You are running as a review agent in self-test mode. Review the following diff and return your findings in the status envelope JSON format.

## Agent Instructions

<contents of the agent .md file, excluding frontmatter>

## Diff to Review

<contents of fixture.diff>

## Changed Files

<file list extracted from the diff headers>

## Instructions

Follow the agent instructions above. Return ONLY a JSON status envelope:
{
  "status": "DONE|DONE_WITH_CONCERNS|NEEDS_CONTEXT|BLOCKED",
  "summary": "...",
  "findings": [...],
  "concerns": [...]
}

Do not include any text before or after the JSON.
```

Use the agent's model from its frontmatter (typically `sonnet`). Run fixtures **sequentially** — each agent call costs API tokens, so don't blast them all at once.

## Step 5: Validate Response

Parse the agent's response. Extract the JSON status envelope. If the response contains text before/after the JSON, extract the JSON block (look for `{` to `}` matching).

For each fixture, check:

### Status Check
The response `status` must be one of the values in `expect_status`. If not → **FAIL**.

### Finding Count Check
The number of findings must be >= `expect_findings_min`. If not → **FAIL**.

### Specific Finding Checks
For each entry in `expect_findings`, check that at least one finding in the response matches ALL specified fields:
- `category` — exact match if specified
- `severity` — exact match if specified
- `file_pattern` — the finding's `file` field contains this substring

If any expected finding has no match → **FAIL**.

### No-Blocking Check
If `expect_no_blocking` is true, verify that NO finding has `severity: "blocking"`. If any do → **FAIL**.

### Confidence Check
All findings should have `confidence >= 80` (the same threshold used in production). Findings below 80 are a warning, not a failure — but note them.

## Step 6: Report

For each fixture, report:

```
## <fixture-name>: PASS|FAIL
Agent: <agent-name>
Description: <from expect.json>
Status: <agent status> (expected: <expect_status>)
Findings: <count> (expected min: <expect_findings_min>)
<for each expected finding: MATCHED|MISSING with details>
<if expect_no_blocking: "No blocking findings: PASS|FAIL">
<if any low-confidence findings: "Warning: N findings below confidence 80">
```

## Step 7: Summary

```
## Agent Self-Test Results

| Fixture | Agent | Result |
|---------|-------|--------|
| missing-tests | pr-test-analyzer | PASS |
| swallowed-error | silent-failure-hunter | PASS |
| sql-injection | code-reviewer | FAIL — expected blocking security finding |
| clean-code | code-reviewer | PASS |

Passed: N/M
```

If any fixture failed, suggest what to investigate (the agent prompt may have drifted, or the fixture expectations need updating).

## When to Add Fixtures

Don't add fixtures speculatively for coverage. Add them in response to observable events:

1. **A prompt change breaks detection.** You modify an agent and later discover it stopped catching something it used to catch. Write a fixture for the missed issue, then fix the prompt. Bug-first, then test.

2. **A false positive pattern recurs.** An agent keeps flagging the same non-issue across multiple PRs (e.g., flagging intentional error suppression in cleanup code). Write a negative fixture asserting it does NOT flag that pattern. The `clean-code` fixture is this type.

3. **A new agent is added.** Every new agent gets at least one positive fixture (known-bad diff it must catch) and one negative fixture (clean diff it must not flag). This is part of the agent creation workflow.

4. **Den JSONL data shows a pattern.** Once den collects review results, look at which agents produce the most rejected findings (false positives) or which finding categories recur. Those are the highest-value new fixtures.
