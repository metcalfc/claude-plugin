---
name: add
description: (zsh-craft) Request a new pattern
argument-hint: "<description of what's missing>"
allowed-tools:
  - Bash
  - AskUserQuestion
---

File a GitHub issue on the zsh-craft plugin repo requesting a new pattern, recipe, or zsh feature coverage.

Take the user's argument as the description of what they want added.

## Step 1: Check for duplicates

Before filing, search for existing open issues:

```bash
gh issue list --repo metcalfc/claude-plugin --label "zsh-craft" --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'
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
gh label create zsh-craft --repo metcalfc/claude-plugin --description "zsh-craft plugin" --color 1d76db 2>/dev/null
```

```bash
gh issue create \
  --repo metcalfc/claude-plugin \
  --title "zsh-craft: <short summary>" \
  --label "zsh-craft,enhancement" \
  --body "<body>"
```

The body should include:
- What zsh feature or pattern the user needs
- The context (what kind of script or workflow)
- Whether it's a new reference topic, an anti-pattern to document, or a missing module

After filing, display the issue URL.
