---
name: prep
description: (chad-tools) Prep GitHub issues for autonomous AI execution
argument-hint: "<issue#> | <epic#> | <range like 1-3,5,7>"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

Post structured execution plans as comments on GitHub issues, optimized for autonomous AI execution. Preserves the original issue body and links to the plan comment. Supports single issues, umbrella/epic issues with sub-issues, and arbitrary ranges.

## Step 1: Parse arguments

The argument `$ARGUMENTS` specifies which issues to prep. Parse it into a list of issue numbers.

**Formats:**

- **Single issue**: `5` — one issue number
- **Range**: `1-3,5,7,13-20` — comma-separated numbers and ranges, expand to individual numbers
- **No argument**: error — tell the user to provide an issue number

## Step 2: Detect the repo

Determine the GitHub repo to operate on:

```bash
gh repo view --json nameWithOwner -q '.nameWithOwner'
```

## Step 3: Repo preflight

Scan the repo root for available verification tools. Build a context string listing what's available:

- `CLAUDE.md` — repo-level instructions
- `lefthook.yml` / `.lefthook.yml` — git hook stages (pre-commit, pre-push, etc.)
- `Makefile` — targets: test, lint, check, format, build
- `package.json` — scripts: test, lint, format, check, build, typecheck. Detect package manager (bun/pnpm/yarn/npm) from lock files.
- `Cargo.toml` — cargo: test, build, clippy
- `go.mod` — go: test, build, vet
- `pyproject.toml` / `setup.py` — pytest, ruff
- `Gemfile` — rake, rspec, rails test
- `.github/workflows/` — GitHub Actions CI

Format as a bulleted list under `## Repo Tools`.

## Step 4: Route by count

### Single issue (1 issue number)

Do the prep inline — proceed to Step 5.

### Multiple issues (2+ issue numbers)

First, check if any of the issues are umbrella/epic issues. For each issue number, fetch its body and check for a task list pattern (`- [ ] #123` or `- [x] #123`). If an issue has sub-issues:

1. Extract the sub-issue numbers from the task list
2. Add those to the prep list (deduplicating)
3. Mark the umbrella issue to be prepped LAST (after all sub-issues are done)

Then launch parallel `issue-prepper` agents for all non-umbrella issues. Pass each agent:
- The issue number
- The repo name
- The repo tools context from Step 3

Wait for all agents to complete, then prep any umbrella issues (also in parallel if multiple). For umbrellas, include a summary of what the sub-issues cover so the umbrella prep has full context.

### Single issue that's an epic

If there's only 1 issue number but it has a task list with sub-issue references (`- [ ] #123`):

Use AskUserQuestion to ask:
- **Prep as umbrella** — prep all sub-issues in parallel, then prep the umbrella
- **Prep just this issue** — treat it as a regular single issue

## Step 5: Prep a single issue (inline path)

### 5a: Fetch issue context

```bash
gh issue view <number> --repo <repo> --json number,title,body,labels,comments
```

Extract: title, body, comments (formatted as `[author]: comment body`).

### 5b: Build the rewrite prompt

Construct a prompt with:
- The issue number and title
- The current issue body
- Comments (if any)
- Repo tools context from Step 3
- The structured format template (see below)

### 5c: Build the execution plan

Build a structured execution plan from the issue, keeping all existing requirements and context — don't lose information:

```markdown
## Goal
One sentence: what does "done" look like?

## Success Criteria
- [ ] Checkboxes with verifiable conditions (test commands, lint checks, behavior)
- [ ] Include specific commands to run when the repo has them

## Steps
1. Numbered, ordered implementation steps
2. Reference specific files and functions when known
3. Include what to read/understand first

## Context
- Links to related issues/PRs
- Key decisions already made
- Things NOT to touch (scope boundaries)

## Constraints
- Technical constraints (no new deps, backwards compat, etc.)
- If the original issue is too vague for concrete steps, add a ## Open Questions section
```

### 5d: Review and confirm

Show the proposed execution plan to the user via AskUserQuestion. Options:
- **Post plan** — add as a comment and link from the body
- **Edit first** — let user provide feedback, then revise and ask again
- **Skip** — don't update this issue

### 5e: Post the plan as a comment and link from the body

Post the execution plan as a comment on the issue:

```bash
gh issue comment <number> --repo <repo> --body-file <(cat <<'BODY'
## Execution Plan

<plan content here>
BODY
)
```

Then append a link to the plan comment at the bottom of the **original** issue body. Fetch the comment URL from the command output or via `gh api`, then update the body:

```bash
gh issue edit <number> --repo <repo> --body-file <(cat <<'BODY'
<original body unchanged>

---
📋 [Execution plan](#issuecomment-<id>)
BODY
)
```

**Important:** The original issue body MUST be preserved verbatim. Only append the plan link after a horizontal rule.

If the title starts with `WIP:`, strip that prefix:

```bash
gh issue edit <number> --repo <repo> --title "<clean title>"
```

Confirm the update to the user.

## Agent dispatch format

When launching `issue-prepper` agents in parallel, use this prompt template:

```
Prep GitHub issue #<NUMBER> in repo <REPO> for autonomous AI execution.

## Repo Tools
<repo tools context>

Fetch the issue, build a structured execution plan, show the user for review, and post it as a comment on the issue (preserving the original body).
```

The agent knows the structured format and the full workflow. Pass it everything it needs in the prompt.
