---
name: freshen-rails-agents
description: (chad-tools) Update Rails review agents from upstream compound-engineering
allowed-tools:
  - Bash
  - Read
  - Write
  - WebFetch
  - AskUserQuestion
---

Fetch the latest Rails-related review agents from upstream sources and update our adapted versions.

## Upstream Sources

### From [compound-engineering](https://github.com/EveryInc/compound-engineering-plugin) (main branch)

| Upstream file | Our agent |
|---|---|
| `plugins/compound-engineering/agents/review/dhh-rails-reviewer.md` | `rails-convention-reviewer.md` |
| `plugins/compound-engineering/agents/review/security-sentinel.md` | `rails-security-reviewer.md` |
| `plugins/compound-engineering/agents/review/schema-drift-detector.md` | `schema-drift-detector.md` |
| `plugins/compound-engineering/agents/review/data-integrity-guardian.md` | `rails-data-reviewer.md` |
| `plugins/compound-engineering/agents/review/performance-oracle.md` | `rails-performance-reviewer.md` |

### From [palkan/skills](https://github.com/palkan/skills) (master branch)

| Upstream file | Our agent |
|---|---|
| `layered-rails/agents/layered-rails-reviewer.md` | `rails-layering-advisor.md` (informed by, not a direct adaptation) |
| `layered-rails/skills/layered-rails/references/core/extraction-signals.md` | Reference for one-way gate patterns |
| `layered-rails/skills/layered-rails/references/core/specification-test.md` | Reference for the spec test concept |
| `layered-rails/skills/layered-rails/references/patterns/*.md` | Reference for pattern descriptions |

For palkan/skills, the process is different — our `rails-layering-advisor` is not a direct port but uses their pattern knowledge. When freshening, fetch their reference docs and check if new patterns or extraction signals have been added that we should incorporate into our gate detection.

## Process

### Step 1: Fetch upstream

For each upstream file, fetch the raw content:
```
https://raw.githubusercontent.com/EveryInc/compound-engineering-plugin/main/plugins/compound-engineering/agents/review/<filename>.md
```

### Step 2: Compare

For each agent, read our current version from `${CLAUDE_PLUGIN_ROOT}/agents/` and compare with the upstream content.

Show the user a summary of what changed upstream:
- New sections or checks added
- Removed content
- Significant rewording

If nothing changed upstream, say so and stop.

### Step 3: Propose updates

For each agent with upstream changes, propose how to incorporate them into our adapted version. Our versions differ from upstream in these ways that MUST be preserved:

1. **Frontmatter**: Our `name`, `description`, and `model: inherit` — never overwrite
2. **Attribution comment**: The HTML comment block crediting compound-engineering — keep as-is
3. **Output format**: Our JSON finding format (`file`, `line`, `category`, `severity`, `confidence`, `body`) — upstream may use a different format, always keep ours
4. **False positive awareness**: Our section may be more specific — merge, don't replace
5. **Rules footer**: Our confidence/severity rules at the bottom — keep ours

What CAN be updated from upstream:
- New check categories or patterns to look for
- Improved descriptions of existing checks
- New attack vectors or anti-patterns
- Better examples

### Step 4: Confirm

Show the user a summary of proposed changes per agent. Use AskUserQuestion:
- "Apply all updates"
- "Let me pick which ones"
- "Skip — no changes"

### Step 5: Apply

Write the updated agent files. Preserve our format, incorporate upstream improvements.

### Step 6: Version bump

After applying changes, remind the user to bump the chad-tools version in both:
- `plugins/chad-tools/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
