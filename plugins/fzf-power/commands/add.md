---
name: add
description: Request a new fzf recipe or pattern
argument-hint: "<description of what's missing>"
allowed-tools:
  - Bash
  - AskUserQuestion
---

File a GitHub issue on the fzf-power plugin repo requesting a new recipe or pattern.

Take the user's argument as the description of what they want added.

## Step 1: Check for duplicates

Before filing, search for existing open issues:

```bash
gh issue list --repo metcalfc/claude-plugin --label "fzf-power" --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'
```

If any existing issue looks related, show the user the matches and ask:

- **File anyway** — the request is different enough to warrant a new issue
- **Add a comment** — add context to the existing issue
- **Skip** — an existing issue already covers it

If the user picks **Add a comment**, post a comment on the matching issue:

```bash
gh issue comment ISSUE_NUMBER --repo metcalfc/claude-plugin --body "<comment>"
```

The comment format:

```markdown
This might be related — I also ran into this:

<brief description of what the user wants and why>

Adding context in case it helps.
```

Show the user the draft comment for approval before posting.

## Step 2: File the issue

```bash
gh label create fzf-power --repo metcalfc/claude-plugin --description "fzf-power plugin" --color 1d76db 2>/dev/null
```

```bash
gh issue create \
  --repo metcalfc/claude-plugin \
  --title "fzf-power: <short summary>" \
  --label "fzf-power,enhancement" \
  --body "<body>"
```

The body should include:
- What the user wanted to do with fzf
- The context (what kind of data is being selected/filtered)
- Any specific fzf features they'd like to see used (preview, keybindings, etc.)

After filing, display the issue URL.
