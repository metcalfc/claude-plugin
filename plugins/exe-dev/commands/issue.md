---
name: issue
description: Report a bug with an exe-dev command
argument-hint: "<what went wrong>"
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

Report a bug with an exe-dev command. Gather context about the failure, sanitize it, and let the user review before filing.

## Step 1: Gather context

Collect the following automatically:

- The exe-dev command that failed (e.g., `ssh exe.dev ls --json`)
- The error message or unexpected output
- The OS (`uname -s`)
- SSH config for exe.dev if relevant (`grep -A3 'exe.dev' ~/.ssh/config 2>/dev/null` — but redact IdentityFile paths)

Use the user's description and recent conversation context to fill in what went wrong.

## Step 2: Sanitize

Before showing the draft to the user, scrub ALL of the following from the issue body:

- SSH keys, API tokens, passwords, secrets, credentials
- IP addresses (replace with `<redacted-ip>`)
- Email addresses not already public on GitHub (replace with `<redacted-email>`)
- Private hostnames or internal system names
- File paths containing usernames (replace `/Users/username/` with `~/`)
- VM names if the user considers them private (ask if unsure)
- Environment variable values (keep the key names, redact values)

## Step 3: Check for duplicates

Before drafting, search for existing open bug reports:

```bash
gh issue list --repo metcalfc/claude-plugin --label "exe-dev,bug" --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'
```

If any existing issue looks related, show the user the matches and ask:

- **File anyway** — the bug is different
- **Add a comment** — add context to the existing issue instead
- **Skip** — already reported

## Step 4: Draft and review

Present the full issue title and body to the user using AskUserQuestion with options:

- **File it** — create the issue as drafted
- **Edit first** — let the user describe what to change, then re-draft

Do NOT file the issue until the user explicitly approves.

## Step 5: File the issue

```bash
gh label create exe-dev --repo metcalfc/claude-plugin --description "exe-dev plugin" --color 0075ca 2>/dev/null
gh label create bug --repo metcalfc/claude-plugin --description "Something isn't working" --color d73a4a 2>/dev/null
```

```bash
gh issue create \
  --repo metcalfc/claude-plugin \
  --title "exe-dev: <short summary>" \
  --label "exe-dev,bug" \
  --body "<approved body>"
```

The body format:

```markdown
## What happened

<description of the problem>

## Command

<the exe-dev command that failed>

## Error output

```
<sanitized error output>
```

## Environment

- OS: <os>
```

After filing, display the issue URL.
