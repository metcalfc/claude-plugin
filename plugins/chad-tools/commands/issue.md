---
name: issue
description: Report a bug with a chad-tools skill
argument-hint: "<what went wrong>"
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

Report a bug with a chad-tools skill. Gather context about the failure, sanitize it, and let the user review before filing.

## Step 1: Gather context

Collect the following automatically:

- The skill or command that failed
- The error message or unexpected behavior
- The OS (`uname -s`)
- git version (`git --version`)
- gh version (`gh --version`)

Use the user's description and recent conversation context to fill in what went wrong.

## Step 2: Sanitize

Before showing the draft to the user, scrub ALL of the following from the issue body:

- API tokens, passwords, secrets, credentials
- IP addresses (replace with `<redacted-ip>`)
- Email addresses not already public on GitHub (replace with `<redacted-email>`)
- Private repo names or org names
- Hostnames of internal/private systems
- File paths containing usernames (replace `/Users/username/` with `~/`)
- Environment variable values (keep the key names, redact values)
- Branch names if they contain sensitive project info (ask if unsure)

## Step 3: Draft and review

Present the full issue title and body to the user using AskUserQuestion with options:

- **File it** — create the issue as drafted
- **Edit first** — let the user describe what to change, then re-draft

Do NOT file the issue until the user explicitly approves.

## Step 4: File the issue

```bash
gh label create chad-tools --repo metcalfc/claude-plugin --description "chad-tools plugin" --color 0075ca 2>/dev/null
gh label create bug --repo metcalfc/claude-plugin --description "Something isn't working" --color d73a4a 2>/dev/null
```

```bash
gh issue create \
  --repo metcalfc/claude-plugin \
  --title "chad-tools: <short summary>" \
  --label "chad-tools,bug" \
  --body "<approved body>"
```

The body format:

```markdown
## What happened

<description of the problem>

## Skill / command

<the skill or command that failed>

## Error output

```
<sanitized error output>
```

## Environment

- OS: <os>
- git: <version>
- gh: <version>
```

After filing, display the issue URL.
