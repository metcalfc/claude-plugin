---
name: review-pr
description: Multi-agent PR review that posts inline GitHub comments
argument-hint: "<PR number or URL>"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Agent
  - WebFetch
---

Review a pull request using specialized review agents, then post findings as inline GitHub comments.

## Input

The user provides a PR number or URL as `$ARGUMENTS`. Extract the PR number. If a URL, parse the number from it. If no argument, try `gh pr view --json number --jq '.number'` for the current branch's PR.

## Step 1: Pre-flight Checks

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

## Step 2: Gather Context

Get the diff and file list:
```
gh pr diff <number>
gh pr diff <number> --name-only
```

Look for CLAUDE.md files that provide project context:
- Check the repo root and any parent directories of changed files
- Read any CLAUDE.md files found — these contain project conventions

## Step 3: Select and Launch Agents

Always launch `code-reviewer`.

Conditionally launch others based on the diff content:

- **`silent-failure-hunter`**: if the diff contains `try`, `catch`, `except`, `rescue`, `recover`, `on_error`, `errdefer`, or `Result<`
- **`pr-test-analyzer`**: if any changed file matches common test patterns: `test_`, `_test.`, `.test.`, `.spec.`, `tests/`, `__tests__/`, `*_test.go`
- **`comment-analyzer`**: if the diff adds lines containing `//`, `#`, `/*`, `"""`, `'''`, `///`, or `@param`/`@returns`/`@deprecated` doc tags
- **`type-design-analyzer`**: if the diff adds lines containing `interface `, `type `, `struct `, `class `, `enum `, `@dataclass`, or `TypedDict`

Launch all selected agents **in parallel** using the Agent tool. Each agent receives:
- The full diff
- The changed file list
- Any CLAUDE.md content found
- The PR title and body for context

Tell each agent to follow the instructions in its agent definition file and return findings as the specified JSON array.

## Step 4: Collect and Filter Results

Parse the JSON array from each agent's response.

**Filter out:**
- Findings with `confidence` < 80
- Duplicate findings on the same file + line (keep the highest confidence one)

**Tag each finding** with its source agent: prepend `[agent-name, confidence]` to the body.
Example: `[silent-failure-hunter, 92] This catch block swallows...`

## Step 5: Determine Review Event

Examine the filtered findings:

- If ANY finding has `severity: "blocking"` → event is `REQUEST_CHANGES`
- If NO findings at all (clean review) AND author is not current user → event is `APPROVE`
- Otherwise → event is `COMMENT`

## Step 6: Build and Post Review

**Review body** (1-2 sentences):
- Summarize what the PR does and overall assessment
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

## Step 7: Summary

Report to the user:
- Which agents ran
- How many raw findings vs. filtered findings
- What was posted (event type, number of inline comments)
- Link to the PR

## Review Philosophy

- **Every comment matters.** Don't write it if it doesn't matter.
- **No [Required]/[Optional] labels.** If you wrote it, it matters. If it doesn't, delete it.
- **Security + correctness = blocking.** Architecture = blocking if mismatched. Style = never blocking alone.
- **Questions are real questions** that need answers, not suggestions.
