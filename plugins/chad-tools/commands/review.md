---
name: review
description: (chad-tools) Multi-agent code review — local diff or PR
argument-hint: "[#PR|unstaged|staged|last|HEAD~N|<file>...]"
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

## Step 1: Determine Mode

Check `$ARGUMENTS` to decide between **PR mode** and **local mode**.

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

Tell the user which agents will run (one short line).

## Step 4: Launch Review Agents

Launch all selected agents **in parallel** using the Agent tool. Each agent receives:

- The full diff
- The changed file list
- Any CLAUDE.md content found
- The PR title and body (if a PR is involved)

Tell each agent to follow the instructions in its agent definition file and return findings as the specified JSON array.

## Step 5: Collect and Filter Results

Parse the JSON array from each agent's response.

**Filter out:**
- Findings with `confidence` < 80
- Duplicate findings on the same file + line (keep the highest confidence one)

**Tag each finding** with its source agent: prepend `[agent-name, confidence]` to the body.
Example: `[silent-failure-hunter, 92] This catch block swallows...`

## Step 6: Triage and Act

Categorize each filtered finding into one of four buckets:

### Fix Now
Small fixes that take under ~10 minutes — typos, missing error checks, obvious bugs, simple refactors. **Fix these immediately** using Edit/Write tools. Track what was fixed for the summary.

### Call Out
Larger issues that need the author's attention. These stay as review findings (inline comments on PR, or terminal output for local mode). No action taken — just reported.

### Question
Genuine questions about intent, design choices, or unclear code. Use **AskUserQuestion** to surface these during the review. Wait for answers before proceeding — the answer may change the triage of other findings.

### File Issue
Changes that should happen but are tangential to the current diff or have a high blast radius. Use **AskUserQuestion** to propose filing an issue:
- Explain what needs to change and why
- Note the blast radius or why it's tangential
- Offer options: "File an issue", "Fix it now anyway", or "Skip"
- If filing: `gh issue create --repo metcalfc/claude-plugin` with appropriate labels

Process findings in this order: Questions first (answers inform triage), then Fix Now, then File Issue decisions, then Call Out items remain as review comments.

## Step 7: Post or Report

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
- `body`: the tagged finding body

Post via GitHub API:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input - <<'REVIEW'
{
  "event": "COMMENT|REQUEST_CHANGES|APPROVE",
  "body": "Review summary here.",
  "comments": [
    {
      "path": "file.rs",
      "line": 42,
      "side": "RIGHT",
      "body": "[code-reviewer, 92] Description of issue."
    }
  ]
}
REVIEW
```

If there are no inline comments, omit the `comments` array entirely.

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

## Step 8: Summary

Report to the user:
- Scope reviewed (PR #N / unstaged / staged / last commit / etc.)
- Which agents ran
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
