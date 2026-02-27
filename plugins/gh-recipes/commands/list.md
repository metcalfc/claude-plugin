---
name: list
description: List all available gh-recipes
allowed-tools:
  - Read
  - Glob
---

Show the user a catalog of all available gh API recipes.

Read the SKILL.md file at the plugin's skill directory to find the references list, then present a formatted summary.

Use Glob to find all `.md` files in the `skills/gh-api-recipes/references/` directory relative to this plugin. For each file found, read the first line (the `# Title`) and the first paragraph to build a one-line description.

Present as a table:

```
## Available gh-recipes

| Recipe | Topics |
|--------|--------|
| milestones | Create, list, update, close, delete; assign to issues |
| collaborators | Add/remove, permissions, invitations, team access |
| ... | ... |

12 recipes available. Use `gh api` patterns from these recipes when
built-in gh subcommands don't exist.

Missing something? Run `/gh-recipes:add <description>` to request it.
```
