---
name: add
description: Request a new exe-dev feature be added to the plugin
argument-hint: "<description of what's missing>"
allowed-tools:
  - Bash
---

File a GitHub issue on the plugin repo requesting a new exe-dev feature.

Take the user's argument as the description of what they tried to do and what was missing.

Run this command to create the issue:

```bash
gh issue create \
  --repo metcalfc/claude-plugin \
  --title "exe-dev: <short summary>" \
  --label "exe-dev,enhancement" \
  --body "<body>"
```

The body should include:
- What the user tried to do
- The error or gap encountered
- Any workaround they used

If label creation fails because the labels don't exist yet, create them first:

```bash
gh label create exe-dev --repo metcalfc/claude-plugin --description "exe-dev plugin" --color 0075ca 2>/dev/null
```

After filing, display the issue URL.
