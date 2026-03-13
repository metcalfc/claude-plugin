---
name: code-review
description: (chad-tools) Multi-agent code review — local diff or PR
argument-hint: "[--fast] [#PR|unstaged|staged|last|HEAD~N|<file>...]"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Agent
  - Edit
  - Write
  - AskUserQuestion
  - WebFetch
---

Review code using the specialized agent fleet. Works on local changes (auto-detected) or a specific PR by number.

Agents run in two sequential passes by default: Pass 1 checks correctness, Pass 2 checks design. If Pass 1 finds blocking issues, Pass 2 is skipped — fix the bugs before worrying about style. Use `--fast` to run all agents in parallel (single pass, current behavior).

## Step 1: Determine Mode

Check `$ARGUMENTS` for `--fast` flag first. If present, set `fast_mode = true` and strip it from arguments before further processing. Then decide between **PR mode** and **local mode**.

### PR mode — if the argument is a PR number or URL:

- A bare number like `123` or `#123` → PR mode, extract the number
- A GitHub PR URL → PR mode, parse the number from the URL

### Local mode — everything else:

If arguments are provided, interpret as:

- `unstaged` → `git diff`
- `staged` → `git diff --cached`
- `last` or `HEAD~1` → `git diff HEAD~1 HEAD`
- `HEAD~N` (any number) → `git diff HEAD~N HEAD`
- A commit range like `abc123..def456` → `git diff abc123..def456`
- File paths/globs → `git diff -- <files>` (include both staged and unstaged)

If NO arguments, auto-detect by trying in order:

1. Run `git diff --stat` — if output is non-empty → scope is **unstaged**, use `git diff`
2. Run `git diff --cached --stat` — if output is non-empty → scope is **staged**, use `git diff --cached`
3. Otherwise → scope is **last commit**, use `git diff HEAD~1 HEAD`

Tell the user what mode and scope was selected (one short line).

## Step 2: Pre-flight and Context

### PR mode:

Get PR metadata:
```
gh pr view <number> --json state,isDraft,reviews,author,title,body,headRefName,baseRefName,number
```

Abort with a clear message if:
- `state` is `CLOSED` or `MERGED`
- `isDraft` is `true`
- `reviews` already contains a review from the current user (check with `gh api user --jq '.login'`)

Get repo info:
```
gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'
```

Get the diff and file list:
```
gh pr diff <number>
gh pr diff <number> --name-only
```

### Local mode:

Get the full diff and changed file list using the diff command from Step 1 (without `--stat`, then with `--name-only`).

Check if the current branch has an open PR:
```
gh pr view --json number,state,author,title,body,headRefName,baseRefName 2>/dev/null
```

If this succeeds and `state` is `OPEN`, record the PR metadata — findings will also be posted as a GitHub review.

### Both modes:

Look for CLAUDE.md files that provide project context:
- Check the repo root and any parent directories of changed files
- Read any CLAUDE.md files found — these contain project conventions

Tell the user whether findings will be posted to a PR or shown locally.

## Step 3: Select Agents

Always launch `code-reviewer`.

Conditionally launch others based on the diff content and changed file names:

- **`silent-failure-hunter`** — if the diff contains any error-handling pattern:
  - **Go:** `if err != nil`, `errors.New`, `fmt.Errorf`, `errors.Is`, `errors.As`, `errors.Wrap`
  - **Rust:** `Result<`, `unwrap(`, `expect(`, `.ok()`, `match.*Err`, `?;`, `anyhow!`, `bail!`
  - **JS/TS:** `try`, `catch`, `.catch(`, `Promise`, `reject`, `throw `, `new Error`
  - **Python:** `try`, `except`, `raise`, `finally`, `logging.error`, `logging.exception`
  - **Ruby:** `begin`, `rescue`, `ensure`, `raise`, `retry`
  - **Bash/Zsh:** `trap `, `set -e`, `|| true`, `|| :`, `|| exit`, `2>/dev/null`, `|| return`
  - **General:** `on_error`, `errdefer`, `recover`, `panic`

- **`pr-test-analyzer`** — if any changed file matches test patterns:
  - **Go:** `_test.go`
  - **Rust:** files in `tests/`, `#[test]`, `#[cfg(test)]`
  - **JS/TS:** `.test.`, `.spec.`, `__tests__/`, `*.test.ts`, `*.spec.ts`
  - **Python:** `test_`, `_test.py`, `tests/`, `conftest.py`
  - **Ruby:** `_spec.rb`, `_test.rb`, `spec/`, `test/`, `minitest`
  - **Bash:** `.bats`, `test/`
  - **General:** `fixtures/`, `testdata/`, `mocks/`

- **`comment-analyzer`** — if the diff adds lines containing doc patterns:
  - **C-style:** `//`, `/*`, `*/`, `///`, `/** `
  - **Python:** `"""`, `'''`, `Args:`, `Returns:`, `Raises:`, `:param`, `:returns:`, `:rtype:`
  - **Ruby:** `=begin`, `=end`, `# @param`, `# @return`, `# @raise`, `yard` tags
  - **Rust:** `///`, `//!`, `#[doc`
  - **Shell:** `# `, comment blocks
  - **Tags:** `@param`, `@returns`, `@deprecated`, `@example`, `@see`, `@since`, `@throws`, `TODO`, `FIXME`, `HACK`, `XXX`

- **`type-design-analyzer`** — if the diff adds lines containing type definitions:
  - **Go:** `type `, `struct {`, `interface {`, `func (`, method receivers
  - **Rust:** `struct `, `enum `, `trait `, `impl `, `type `, `pub struct`, `pub enum`
  - **JS/TS:** `interface `, `type `, `class `, `enum `, `extends `, `implements `
  - **Python:** `class `, `@dataclass`, `TypedDict`, `NamedTuple`, `Protocol`, `Enum`, `BaseModel`
  - **Ruby:** `class `, `module `, `include `, `extend `, `attr_accessor`, `attr_reader`
  - **General:** `abstract `, `sealed `

### Rails-specific agents (from [compound-engineering](https://github.com/EveryInc/compound-engineering-plugin), MIT)

These launch when the diff touches Ruby/Rails files (`.rb`, `.erb`, `Gemfile`, `config/routes.rb`):

- **`rails-convention-reviewer`** — if any changed file is `.rb` or `.erb`:
  - Checks for Rails Way violations, unnecessary abstractions, JS-world patterns

- **`rails-security-reviewer`** — if any changed file is in `app/controllers/`, `app/models/`, `config/`, or touches auth/session logic:
  - Rails-specific security: mass assignment, CSRF, SQL injection, auth bypass

- **`rails-performance-reviewer`** — if any changed file is in `app/` or `lib/`:
  - N+1 queries, missing indexes, unbounded queries, memory-heavy patterns

- **`schema-drift-detector`** — if `db/schema.rb` is in the changed file list:
  - Cross-references schema.rb changes against migrations in the diff

- **`rails-data-reviewer`** — if any changed file is in `db/migrate/` or `app/models/`:
  - Migration safety, transaction boundaries, referential integrity, PII exposure

- **`rails-layering-advisor`** — if any changed file is `.rb` or `.erb`:
  - One-way gates: patterns that are cheap to fix now but expensive after the app grows (auth sprawl, callback business logic, nested attributes, query duplication). Quantifies now-vs-later cost.

### Cross-platform agents

- **`platform-portability-reviewer`** — if any changed file is `.rs`, `.swift`, `.c`, `.h`, or touches IPC/SSH/protocol code:
  - Catches platform lock-in: hardcoded Unix sockets, `SSH_AUTH_SOCK` assumptions, macOS-specific paths, heavy Swift business logic, streaming-only protocols, SQLite extension loading assumptions. Quantifies now-vs-later cost for Windows, iOS, and Android portability.

### Efficiency and reuse agents

- **`code-efficiency-reviewer`** — if the diff adds non-trivial logic (functions, loops, I/O operations, async code) in any language **except** Ruby/Rails files (which are covered by `rails-performance-reviewer`):
  - Unnecessary work, missed concurrency, hot-path bloat, memory/resource leaks, overly broad operations, TOCTOU anti-patterns

- **`code-reuse-reviewer`** — if the diff adds new functions or substantial logic blocks (> 10 lines of new non-test code):
  - Searches the codebase for existing utilities that duplicate the new code. Flags exact duplicates and missed reuse opportunities.

Tell the user which agents will run (one short line).

### Classify into passes

Unless `fast_mode` is set, classify each selected agent into its pass:

**Pass 1 — "Is it correct?"** (always runs):
- `code-reviewer`
- `silent-failure-hunter`
- `pr-test-analyzer`
- `schema-drift-detector`
- `rails-data-reviewer`
- `rails-security-reviewer`
- `code-efficiency-reviewer`

**Pass 2 — "Is it well-designed?"** (gated on Pass 1):
- `comment-analyzer`
- `type-design-analyzer`
- `rails-convention-reviewer`
- `rails-performance-reviewer`
- `rails-layering-advisor`
- `code-reuse-reviewer`
- `platform-portability-reviewer`

Tell the user which agents are in each pass (or "Fast mode — all agents in parallel" if `fast_mode`).

## Step 4: Launch Pass 1 Agents

**If `fast_mode`:** Launch ALL selected agents in parallel (skip to Step 5 after collecting results). Note in output: "Fast mode — all agents ran in parallel."

**Otherwise:** Launch only Pass 1 agents in parallel using the Agent tool.

Each agent receives:

- The full diff
- The changed file list
- Any CLAUDE.md content found
- The PR title and body (if a PR is involved)

Tell each agent to follow the instructions in its agent definition file and return its response using the **status envelope format**:

```json
{
  "status": "DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED",
  "summary": "one-line description of what the agent found or why it couldn't proceed",
  "findings": [],
  "concerns": []
}
```

Status meanings:
- **DONE**: Review complete, findings array has all results (may be empty for a clean review)
- **DONE_WITH_CONCERNS**: Review complete, but the agent has meta-concerns (e.g., "the diff is too large to review thoroughly", "I couldn't determine the project's conventions"). Concerns go in `concerns[]`, findings go in `findings[]`
- **NEEDS_CONTEXT**: Agent can't produce reliable findings without more information. The `summary` field describes what's missing (e.g., "need to see the test file for this module to assess coverage")
- **BLOCKED**: Agent hit a hard stop and produced no findings. The `summary` field explains why (e.g., "diff is binary/unreadable", "language not supported")

## Step 5: Collect and Filter Pass 1 Results

### Handle agent statuses

For each agent response:

- **DONE**: Process findings normally (continue to filtering)
- **DONE_WITH_CONCERNS**: Process findings normally, but collect concerns to surface in the summary (Step 11)
- **NEEDS_CONTEXT**: Surface to the user via AskUserQuestion — the agent needs help. Include the agent name and what it needs. The user can provide context (re-run the agent with it) or skip that agent.
- **BLOCKED**: Note in the summary that this agent couldn't run and why. Do not treat as a failure — just report it.

### Filter findings

Parse the JSON array from each agent's response.

**Filter out:**
- Findings with `confidence` < 80
- Duplicate findings on the same file + line (keep the highest confidence one)

**Tag each finding** with its source agent: prepend `[agent-name, confidence]` to the body.
Example: `[silent-failure-hunter, 92] This catch block swallows...`

**If `fast_mode`:** Skip Steps 6–7, jump directly to Step 8 (Triage and Act) with all filtered findings.

## Step 6: Gate Decision

Evaluate filtered Pass 1 findings:

- **If any Pass 1 finding has `severity: "blocking"`** → set `pass2_skipped = true`. Tell the user: "Pass 2 skipped — fix blocking correctness issues first. Agents not run: [list Pass 2 agents that were selected]."
- **Otherwise** → proceed to Step 7.

## Step 7: Launch Pass 2 Agents

Launch Pass 2 agents in parallel using the Agent tool. Each agent receives the same context as Pass 1 (diff, file list, CLAUDE.md, PR metadata).

Collect and filter results using the same process as Step 5 (status handling, confidence >= 80 filter, dedup, agent tagging). Merge Pass 2 findings with Pass 1 findings.

## Step 8: Triage and Act

Every filtered finding gets exactly one of three outcomes:

### Reject
The finding doesn't apply. State why — the pattern is intentional, the agent misread the
code, or the concern doesn't hold in this context. Rejected findings are NOT posted as
review comments. Track rejections for the summary (agent name + one-line reason).

### Fix Now
The finding is valid. Fix it immediately using Edit/Write tools, regardless of size.
"Pre-existing" is not a reason to skip — if the file is in the diff, broken windows
get fixed. Track what was fixed for the summary.

**Use ` ```suggestion ` blocks** when posting review comments for fixes that are obvious but belong to the PR author. GitHub renders these as clickable "Apply suggestion" buttons. Format:

````
```suggestion
const fixed = "like this";
```
````

Use suggestions for: typo fixes, missing null checks, naming improvements, simple refactors. Do NOT use suggestions for: architectural changes, multi-file fixes, or when the "right" fix is ambiguous — use plain text comments for those.

For multi-line suggestions, include `start_line` to specify the range being replaced. The suggestion must contain the complete replacement for all lines in the range.

### File Issue
The finding is valid but the fix touches enough code to warrant its own PR (blast radius).
This is about review safety, not effort avoidance — the fix needs its own review cycle.
Use AskUserQuestion to confirm, then file: `gh issue create --repo metcalfc/claude-plugin` with appropriate labels.

**Not valid outcomes:**
- "Skipped" / "nice-to-have" / "too small to fix" — if it's valid, fix it
- "Pre-existing" — if the file is in the diff, it's in scope
- "Call out" with no action — don't post a comment you aren't going to address

### Questions
Genuine questions about intent or design go through AskUserQuestion before triage.
The answer determines whether the related finding is rejected or accepted.

Process findings in this order: Questions first (answers inform triage), then Fix Now,
then File Issue decisions. Rejected findings are noted in the summary but not posted.

## Step 9: Review Preview & Approval

**Before posting anything to GitHub**, show the user exactly what will be posted and get explicit approval.

Use **AskUserQuestion** to present the complete review:

1. **Event type**: APPROVE, REQUEST_CHANGES, or COMMENT (with reasoning)
2. **Review body**: The 1-2 sentence summary
3. **Each inline comment**, formatted as:
   - File path and line number
   - Agent tag and confidence
   - Full comment body (including any ` ```suggestion ` blocks)
4. **Fixed inline**: List of Fix Now items already applied (for context, not posted)

Example preview format:

```
**Event:** REQUEST_CHANGES
**Summary:** "Auth changes look solid but token validation has a bypass path that needs fixing."

**Inline comments (3):**

1. src/auth.ts:20 [code-reviewer, 95]
   Token expiry check is missing — expired tokens pass validation.
   ```suggestion
   if (token.exp < Date.now() / 1000) {
     throw new TokenExpiredError();
   }
   ```

2. src/auth.ts:35 [silent-failure-hunter, 88]
   This catch block swallows the connection error silently.

3. tests/auth.test.ts:12 [pr-test-analyzer, 82]
   Missing test for expired token rejection.

**Already fixed inline (1):**
- src/auth.ts:50 — fixed typo in error message
```

Options:
- **Post it** — submit the review as shown
- **Let me revise** — user provides feedback, adjust and re-preview

**Skip this step** only in local mode with no PR (findings go to terminal only).

## Step 10: Post or Report

### If a PR is involved (PR mode, or local mode with an open PR):

Determine review event:
- If ANY finding has `severity: "blocking"` → event is `REQUEST_CHANGES`
- If NO findings at all AND author is not current user → event is `APPROVE`
- Otherwise → event is `COMMENT`

**Review body** (1-2 sentences):
- Summarize what the changes do and overall assessment
- Include a "What's Good" note if appropriate
- Do NOT include file-specific feedback in the body

**Inline comments** from filtered findings:
- `path`: the `file` field
- `line`: the `line` field
- `side`: `"RIGHT"`
- `body`: the tagged finding body, with ` ```suggestion ` blocks where applicable
- `start_line` (optional): for multi-line suggestions

**Always use the 2-step pending review pattern.** This batches all comments into one notification and is more robust — if step 2 fails, the pending review can be retried.

Get the latest commit SHA first:
```bash
gh pr view <number> --json commits --jq '.commits[-1].oid'
```

**Step 1: Create a PENDING review with all inline comments:**

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  -X POST \
  -f commit_id="<COMMIT_SHA>" \
  -f 'comments[][path]=src/auth.ts' \
  -F 'comments[][line]=20' \
  -f 'comments[][side]=RIGHT' \
  -f 'comments[][body]=[code-reviewer, 95] Token expiry check missing.

```suggestion
if (token.exp < Date.now() / 1000) {
  throw new TokenExpiredError();
}
```' \
  -f 'comments[][path]=src/auth.ts' \
  -F 'comments[][line]=35' \
  -f 'comments[][side]=RIGHT' \
  -f 'comments[][body]=[silent-failure-hunter, 88] Catch block swallows connection error.' \
  --jq '{id, state}'
```

This returns `{"id": <REVIEW_ID>, "state": "PENDING"}`.

**Syntax rules:**
- Use **single quotes** around parameters with `[]`: `'comments[][path]'`
- Use **`-f`** for string values (path, side, body)
- Use **`-F`** for numeric values (line, start_line)
- For multi-line suggestions, include `start_line`: `-F 'comments[][start_line]=18'`

**Step 2: Submit the pending review with event type and summary:**

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews/<REVIEW_ID>/events \
  -X POST \
  -f event="REQUEST_CHANGES" \
  -f body="Auth changes look solid but token validation has a bypass path that needs fixing."
```

If there are no inline comments, skip step 1 and post the review directly:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  -X POST \
  -f event="APPROVE" \
  -f body="Clean changes, no issues found."
```

### If no PR:

Report findings to the terminal, grouped by file:

```
## path/to/file.rs

**Line 42** [code-reviewer, 95] — Description of the issue found.

**Line 87** [silent-failure-hunter, 88] — This catch block swallows the connection error.

## path/to/other.ts

**Line 12** [type-design-analyzer, 82] — This interface exposes internal implementation details.
```

If no findings, tell the user the review is clean.

## Step 11: Summary

Report to the user:
- Scope reviewed (PR #N / unstaged / staged / last commit / etc.)
- **Pass structure**: "Pass 1: N agents, Pass 2: M agents" (or "Pass 2: skipped" or "Fast mode: all N agents in parallel")
- If Pass 2 was skipped: explain why (blocking findings in Pass 1) and list which agents didn't run
- Which agents ran and their statuses
- **Blocked agents**: if any agent reported BLOCKED, note which and why
- **Agent concerns**: if any agent reported DONE_WITH_CONCERNS, list the concerns
- How many raw findings vs. filtered findings
- **Fixed now**: list what was fixed inline (file + one-line summary each)
- **Called out**: count of review comments posted or shown
- **Questions asked**: note any unresolved questions
- **Issues filed**: links to any issues created
- If PR: what was posted (event type, number of inline comments) + link to PR
- If no PR: total findings shown

## Review Philosophy

- **Every comment matters.** Don't write it if it doesn't matter.
- **No [Required]/[Optional] labels.** If you wrote it, it matters. If it doesn't, delete it.
- **Security + correctness = blocking.** Architecture = blocking if mismatched. Style = never blocking alone.
- **Questions are real questions** that need answers, not suggestions.
- **No skipping.** If a finding passed the confidence filter and isn't rejected, it gets fixed or filed. "Pre-existing", "too small", and "nice-to-have" are not valid reasons to skip.
- **Broken windows get fixed.** If a file is in the diff, everything in it is in scope.
