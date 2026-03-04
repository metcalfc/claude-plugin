---
name: review
description: Review code using specialized agents. Auto-detects local changes, or review a PR by number.
argument-hint: "[#PR|unstaged|staged|last|HEAD~N|<file>...]"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Agent
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

## Step 6: Post or Report

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

## Step 7: Summary

Report to the user:
- Scope reviewed (PR #N / unstaged / staged / last commit / etc.)
- Which agents ran
- How many raw findings vs. filtered findings
- If PR: what was posted (event type, number of inline comments) + link to PR
- If no PR: total findings shown

## Review Philosophy

- **Every comment matters.** Don't write it if it doesn't matter.
- **No [Required]/[Optional] labels.** If you wrote it, it matters. If it doesn't, delete it.
- **Security + correctness = blocking.** Architecture = blocking if mismatched. Style = never blocking alone.
- **Questions are real questions** that need answers, not suggestions.
