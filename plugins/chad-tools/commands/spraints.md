---
name: spraints
description: (chad-tools) Nightly lookback — grade merged PRs, identify tooling improvements, write report to raft
argument-hint: "[kelp|otto|holt|all] [--days N]"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Agent
  - Write
  - Edit
---

Nightly retrospective agent. Reviews merged PRs across Abri repos, grades the work, and writes a structured report to the raft wiki.

## Step 0: Parse Arguments

`$ARGUMENTS` controls scope:

- `kelp`, `otto`, `holt` → review only that repo
- `all` or empty → review all three repos (kelp, otto, holt)
- `--days N` → look back N days instead of 1

Default: all repos, last 1 day.

Set `RAFT_DIR` to `$HOME/src/github.com/abrihq/raft`.
Set `REPORT_DIR` to `$RAFT_DIR/05-areas/engineering/spraints`.
Set `DATE` to today's date in `YYYY-MM-DD` format.

If `$REPORT_DIR/$DATE.md` already exists, tell the user and ask if they want to overwrite.

## Step 1: Gather Merged PRs

For each repo in scope, fetch PRs merged since the lookback window:

Compute the cutoff as a full ISO 8601 timestamp (e.g., `2026-03-09T00:00:00Z` for 1 day ago). The `mergedAt` field includes time, so the cutoff must too.

```bash
gh pr list -R abrihq/<repo> --state merged --json number,title,mergedAt,body,author,headRefName,baseRefName --limit 100 --jq '[.[] | select(.mergedAt > "<YYYY-MM-DDT00:00:00Z>")]'
```

If no PRs were merged in any repo during the window, write a short "quiet day" report and stop.

Tell the user how many PRs were found per repo.

## Step 2: Gather PR Details

For each merged PR, fetch in parallel:

### Diff
```bash
gh pr diff <number> -R abrihq/<repo>
```

### Commits
```bash
gh api repos/abrihq/<repo>/pulls/<number>/commits --jq '[.[] | {sha: .sha, message: .commit.message, author: .commit.author.name}]'
```

### Reviews and comments
```bash
gh api repos/abrihq/<repo>/pulls/<number>/reviews --jq '[.[] | {user: .user.login, state: .state, body: .body}]'
gh api repos/abrihq/<repo>/pulls/<number>/comments --jq '[.[] | {user: .user.login, body: .body, path: .path, line: .line}]'
```

### Linked issue
Extract issue number from:
1. PR body — look for `Fixes #N`, `Closes #N`, `Resolves #N`, or `#N` references
2. Branch name — look for numeric prefix (e.g., `42-add-feature`)

If found:
```bash
gh issue view <number> -R abrihq/<repo> --json title,body,labels,milestone
```

## Step 3: Grade Each PR

Launch a **lookback-grader** agent for each PR (up to 5 in parallel). Pass each agent:

- The full diff
- PR metadata (title, body, author, branch names)
- Commit list with messages and authors
- Review comments and review decisions
- The linked issue body (if found)
- The repo name

Tell each agent: "Follow the instructions in the lookback-grader agent definition. Return your grading as the specified JSON object."

Collect all grading results.

## Step 4: Compute Aggregates

From the collected grades, compute:

- **Overall daily grade**: weighted average of all PR overall_numeric scores, weighted by diff size (lines changed)
- **Per-repo grades**: average overall_numeric per repo
- **Per-dimension averages**: average of each dimension across all PRs (excluding n/a)
- **Attribution breakdown**: count of human / claude / pair PRs
- **Tooling actions**: deduplicated list of all tooling_actions across PRs, sorted by priority

### Trend data (if previous reports exist)

Read the last 7 reports from `$REPORT_DIR/` (by filename sort). Extract `grade_numeric` from frontmatter to compute:
- 7-day rolling average
- Trend direction (up/down/flat — compare last 3 days to previous 4)
- Per-dimension trends

## Step 5: Write Report

Create `$REPORT_DIR/$DATE.md` with the following structure:

### Frontmatter

```yaml
---
date: <DATE>
type: spraints
grade: <letter>
grade_numeric: <0-100>
total_prs: <count>
repos:
  kelp: { prs: <n>, grade_numeric: <n> }
  otto: { prs: <n>, grade_numeric: <n> }
  holt: { prs: <n>, grade_numeric: <n> }
attribution:
  human: <count>
  claude: <count>
  pair: <count>
test_quality: <0-100>
commit_hygiene: <0-100>
issue_fidelity: <0-100>
review_effectiveness: <0-100>
prep_quality: <0-100>
trend_7d: <0-100 or null>
trend_direction: <up|down|flat|null>
tags:
  - spraints
  - engineering
  - quality
---
```

### Body

Use this template:

```markdown
# Spraints — <DATE>

## Summary

- **<N> PRs merged** across <repos> (<breakdown by repo>)
- **Overall: <grade> (<numeric>)** <trend arrow if available>
- **Attribution**: <N> human, <N> Claude, <N> pair
<if trend data>
- **7-day average**: <avg> (trending <direction>)
</if>

## Grades by PR

<for each PR, sorted by grade ascending (worst first)>

### <repo>#<number> — <title>
- **Author**: <attribution> | **Issue**: <#number or "none">
- Test quality: <grade> — <reason>
- Commit hygiene: <grade> — <reason>
- Issue fidelity: <grade> — <reason>
- Review effectiveness: <grade> — <reason>
- Prep quality: <grade> — <reason>
- **Overall: <grade>**
<if highlights>
- 💡 <highlights>
</if>
<if concerns>
- ⚠️ <concerns>
</if>

</for each>

## Dimension Averages

| Dimension | Today | 7-day Avg | Trend |
|---|---|---|---|
| Test quality | <score> | <avg or —> | <arrow or —> |
| Commit hygiene | <score> | <avg or —> | <arrow or —> |
| Issue fidelity | <score> | <avg or —> | <arrow or —> |
| Review effectiveness | <score> | <avg or —> | <arrow or —> |
| Prep quality | <score> | <avg or —> | <arrow or —> |

## Tooling Improvements

<group by target, sorted by priority>

### chad-tools
<for each action targeting chad-tools>
- **<target file>**: <finding> → <recommendation> (<priority>)
</for each>

### den
<for each action targeting den>
- **<finding>** → <recommendation> (<priority>)
</for each>

### Other
<anything else>

## Raw Data

<collapsed details block with the full JSON grading results for each PR>
```

Use `> [!info]` Obsidian callouts for the summary section.
Use `> [!warning]` callouts for any F-graded dimensions.
Link to PRs using full GitHub URLs: `https://github.com/abrihq/<repo>/pull/<number>`.

## Step 6: Update Dashboard Index

Check if `$REPORT_DIR/index.md` exists. If not, create it using the dashboard template (see below). If it exists, leave it alone — the DataviewJS queries are dynamic and self-updating.

### Dashboard Template (only created once)

Create `$REPORT_DIR/index.md` with the content from the spraints dashboard template. This includes:
- DataviewJS queries for summary stats
- Charts via `window.renderChart()` for grade trends
- Attribution breakdown chart
- Dimension radar chart
- Table of recent reports
- Tooling actions aggregation

Read the dashboard template from the spraints skill reference file at `skills/spraints/references/dashboard-template.md` and write it to `$REPORT_DIR/index.md`.

## Step 7: Commit Raft Changes

```bash
cd $RAFT_DIR
git add "05-areas/engineering/spraints/$DATE.md"
if [[ -f "05-areas/engineering/spraints/index.md" ]]; then
  git add "05-areas/engineering/spraints/index.md"
fi
git commit -m "feat: spraints report for $DATE"
```

Note: raft commits go directly to main — this is an Obsidian vault with auto-commit, not a code repo. No PR required.

## Step 8: Summary

Report to the user:
- How many PRs graded across which repos
- Overall grade and trend
- Top concerns (any F or D grades)
- Tooling improvements identified (count by target)
- Path to the report file

## Philosophy

- **Honest grading.** A is exceptional. Most good work is B. C is acceptable. Don't grade inflate.
- **Actionable findings only.** Every tooling improvement must be specific enough to implement.
- **Worst first.** Show the lowest grades first — that's where attention is needed.
- **Trends matter more than daily scores.** A bad day is fine. A bad week is a signal.
- **Attribution without blame.** The point is to improve tooling, not to rank people vs. AI.
