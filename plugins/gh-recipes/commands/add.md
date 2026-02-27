---
name: add
description: Request a new gh recipe be added to the plugin
argument-hint: "<description of what's missing>"
allowed-tools:
  - Bash
---

File a GitHub issue on the gh-recipes plugin repo requesting a new recipe.

Take the user's argument as the description of what they tried to do and what was missing.

Run this command to create the issue:

```bash
gh issue create \
  --repo metcalfc/claude-plugin \
  --title "gh-recipes: <short summary>" \
  --label "gh-recipes,enhancement" \
  --body "<body>"
```

The body should include:
- What the user tried to do (e.g., `gh milestone list`)
- The error or gap encountered
- The `gh api` equivalent if known

If label creation fails because the labels don't exist yet, create them first:

```bash
gh label create gh-recipes --repo metcalfc/claude-plugin --description "gh-recipes plugin" --color 0075ca 2>/dev/null
```

After filing, display the issue URL.
