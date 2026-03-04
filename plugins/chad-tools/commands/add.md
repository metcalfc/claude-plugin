---
name: add
description: (chad-tools) Request a new feature
argument-hint: "<description of what's missing>"
allowed-tools:
  - Bash
  - AskUserQuestion
---

File a GitHub issue on the plugin repo requesting a new chad-tools feature.

Take the user's argument as the description of what they tried to do and what was missing.

## Step 1: Check for duplicates

Before filing, search for existing open issues:

```bash
gh issue list --repo metcalfc/claude-plugin --label "chad-tools" --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'
```

If any existing issue looks related, show the user the matches and ask:

- **File anyway** — the request is different enough to warrant a new issue
- **Add a comment** — add a "+1" or extra context to the existing issue
- **Skip** — an existing issue already covers it

If the user picks **Add a comment**, post a comment on the matching issue:

```bash
gh issue comment ISSUE_NUMBER --repo metcalfc/claude-plugin --body "<comment>"
```

The comment format:

```markdown
This might be related — I also ran into this:

<brief description of what the user tried and what was missing>

Adding context in case it helps.
```

Show the user the draft comment for approval before posting.

## Step 2: Sanitize

Before drafting, scrub the request body of anything sensitive:

- SSH keys, API tokens, passwords, secrets, credentials
- IP addresses (replace with `<redacted-ip>`)
- Email addresses not already public on GitHub (replace with `<redacted-email>`)
- Private repo names or org names if not the plugin repo itself
- Hostnames of internal/private systems
- VM hostnames like `*.exe.xyz` (replace with `<vm>.exe.xyz`)
- File paths containing usernames (replace `/Users/username/` or `/home/username/` with `~/`)
- Environment variable values (keep the key names, redact values)
- Branch names if they contain sensitive project info (ask if unsure)

## Step 3: File the issue

```bash
gh label create chad-tools --repo metcalfc/claude-plugin --description "chad-tools plugin" --color 0075ca 2>/dev/null
```

```bash
gh issue create \
  --repo metcalfc/claude-plugin \
  --title "chad-tools: <short summary>" \
  --label "chad-tools,enhancement" \
  --body "<body>"
```

The body should include:
- What the user tried to do
- The error or gap encountered
- Any workaround they used

After filing, display the issue URL.
