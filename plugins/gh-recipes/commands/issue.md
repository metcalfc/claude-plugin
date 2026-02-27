---
name: issue
description: Report a bug with a gh-recipes recipe
argument-hint: "<what went wrong>"
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

Report a bug with a gh-recipes recipe. Gather context about the failure, sanitize it, and let the user review before filing.

## Step 1: Gather context

Collect the following automatically:

- `gh --version`
- The recipe or `gh api` command that failed
- The error message or unexpected output
- The OS (`uname -s`)

Use the user's description and recent conversation context to fill in what went wrong.

## Step 2: Sanitize

Before showing the draft to the user, scrub ALL of the following from the issue body:

- API tokens, passwords, secrets, credentials
- IP addresses (replace with `<redacted-ip>`)
- Email addresses not already public on GitHub (replace with `<redacted-email>`)
- Private repo names or org names if not the plugin repo itself
- Hostnames of internal/private systems
- File paths containing usernames (replace `/Users/username/` with `~/`)
- Environment variable values (keep the key names, redact values)

## Step 3: Check for duplicates

Before drafting, search for existing open bug reports:

```bash
gh issue list --repo metcalfc/claude-plugin --label "gh-recipes,bug" --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'
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
gh label create gh-recipes --repo metcalfc/claude-plugin --description "gh-recipes plugin" --color 0075ca 2>/dev/null
gh label create bug --repo metcalfc/claude-plugin --description "Something isn't working" --color d73a4a 2>/dev/null
```

```bash
gh issue create \
  --repo metcalfc/claude-plugin \
  --title "gh-recipes: <short summary>" \
  --label "gh-recipes,bug" \
  --body "<approved body>"
```

The body format:

```markdown
## What happened

<description of the problem>

## Recipe / command

<the gh api command or recipe that failed>

## Error output

```
<sanitized error output>
```

## Environment

- gh version: <version>
- OS: <os>
```

After filing, display the issue URL.
