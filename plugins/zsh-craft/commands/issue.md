---
name: issue
description: Report a bug with zsh-craft
argument-hint: "<what went wrong>"
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

Report a bug with a zsh-craft recipe or pattern. Gather context about the failure, sanitize it, and let the user review before filing.

## Step 1: Gather context

Collect the following automatically:

- `zsh --version`
- The zsh code or pattern that was wrong
- What was incorrect about it (syntax error, bash-ism, wrong module, etc.)
- The OS (`uname -s`)
- The expected idiomatic zsh behavior

Use the user's description and recent conversation context to fill in what went wrong.

## Step 2: Sanitize

Before showing the draft to the user, scrub ALL of the following from the issue body:

- SSH keys, API tokens, passwords, secrets, credentials
- IP addresses (replace with `<redacted-ip>`)
- Email addresses not already public on GitHub (replace with `<redacted-email>`)
- Private repo names or org names if not the plugin repo itself
- Hostnames of internal/private systems
- VM hostnames like `*.exe.xyz` (replace with `<vm>.exe.xyz`)
- File paths containing usernames (replace `/Users/username/` or `/home/username/` with `~/`)
- Environment variable values (keep the key names, redact values)
- Branch names if they contain sensitive project info (ask if unsure)

## Step 3: Check for duplicates

Before drafting, search for existing open bug reports:

```bash
gh issue list --repo metcalfc/claude-plugin --label "zsh-craft,bug" --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'
```

If any existing issue looks related, show the user the matches and ask:

- **File anyway** — the bug is different enough to warrant a new issue
- **Add a comment** — post a comment on the existing issue with this new context
- **Skip** — already reported, nothing to add

If the user picks **Add a comment**, post a comment on the matching issue using the sanitized context from Step 2. Frame it as potentially related, not definitively the same:

```bash
gh issue comment ISSUE_NUMBER --repo metcalfc/claude-plugin --body "<comment>"
```

The comment format:

```markdown
This might be related — I hit something similar:

<sanitized description of what happened, the code that was wrong, and what the correct zsh should be>

Let me know if this is a separate issue and I'll file one.
```

Show the user the draft comment for approval before posting, same as with new issues.

## Step 4: Draft and review

Present the full issue title and body to the user using AskUserQuestion with options:

- **File it** — create the issue as drafted
- **Edit first** — let the user describe what to change, then re-draft

Do NOT file the issue until the user explicitly approves.

## Step 5: File the issue

```bash
gh label create zsh-craft --repo metcalfc/claude-plugin --description "zsh-craft plugin" --color 1d76db 2>/dev/null
gh label create bug --repo metcalfc/claude-plugin --description "Something isn't working" --color d73a4a 2>/dev/null
```

```bash
gh issue create \
  --repo metcalfc/claude-plugin \
  --title "zsh-craft: <short summary>" \
  --label "zsh-craft,bug" \
  --body "<approved body>"
```

The body format:

```markdown
## What happened

<description of the problem — what zsh-craft generated vs what it should have>

## Code generated

```zsh
<the zsh code that was wrong>
```

## Expected idiomatic zsh

```zsh
<what the correct zsh should look like>
```

## Environment

- zsh version: <version>
- OS: <os>
```

After filing, display the issue URL.
