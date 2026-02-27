# Claude Plugin Marketplace

A collection of Claude Code plugins. Each plugin lives in `plugins/<name>/`.

## Plugin Conventions

### Directory Structure

Every plugin follows this layout:

```
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json          # Manifest (name, version, description)
├── commands/                 # Slash commands (.md files)
├── skills/                   # Auto-activating skills
│   └── <skill-name>/
│       ├── SKILL.md
│       └── references/       # Detailed docs loaded on demand
└── hooks/                    # Event hooks (optional)
    └── hooks.json
```

### Standard Commands

Every plugin MUST have these three commands:

| Command | File | Description | `allowed-tools` |
|---------|------|-------------|-----------------|
| `/add` | `commands/add.md` | Request a new feature (files an issue) | `Bash`, `AskUserQuestion` |
| `/issue` | `commands/issue.md` | Report a bug (gathers context, sanitizes, user reviews before filing) | `Bash`, `Read`, `AskUserQuestion` |
| `/help` | `commands/help.md` | Display plugin help text | `[]` (empty) |

### `/add` Command Pattern

```yaml
---
name: add
description: Request a new <plugin-name> feature be added to the plugin
argument-hint: "<description of what's missing>"
allowed-tools:
  - Bash
  - AskUserQuestion
---
```

Flow:
1. **Check for duplicates** — `gh issue list --repo metcalfc/claude-plugin --label "<plugin-name>" --state open`
2. If duplicates found, offer three options via AskUserQuestion:
   - **File anyway** — different enough for a new issue
   - **Add a comment** — post a "might be related" comment on existing issue
   - **Skip** — already covered
3. If adding a comment, draft it as "This might be related — I also ran into this: ..." and show for approval before posting
4. **File the issue** — create label if needed, then `gh issue create --repo metcalfc/claude-plugin --label "<plugin-name>,enhancement"`

### `/issue` Command Pattern

```yaml
---
name: issue
description: Report a bug with <plugin-name>
argument-hint: "<what went wrong>"
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---
```

Flow:
1. **Gather context** — version info, OS, the command that failed, error output
2. **Sanitize** — scrub tokens, IPs, emails, private repo names, file paths with usernames (replace `/Users/username/` with `~/`), env var values
3. **Check for duplicates** — same as `/add` but with `--label "<plugin-name>,bug"`
4. **Draft and review** — show full issue to user via AskUserQuestion, options: "File it" or "Edit first"
5. **File the issue** — only after explicit user approval

### `/help` Command Pattern

```yaml
---
name: help
description: Show <plugin-name> plugin help
allowed-tools: []
---
```

Display a formatted help block with sections: plugin tagline, SKILLS/RECIPES (if applicable), COMMANDS list, and USAGE examples.

### Skill Writing Style

- **SKILL.md frontmatter description**: Third person with trigger phrases — "This skill should be used when the user asks to ..."
- **SKILL.md body**: Imperative/infinitive form (verb-first), not second person. "Configure the server" not "You should configure the server"
- **Keep SKILL.md lean**: ~1,500–2,000 words. Move detailed content to `references/`
- **Reference files**: Always mention them in SKILL.md so Claude knows they exist

### Plugin Manifest

```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<one-line description>",
  "repository": "https://github.com/metcalfc/claude-plugin"
}
```

### Marketplace Registry

When adding a new plugin, add an entry to `.claude-plugin/marketplace.json`:

```json
{
  "name": "<plugin-name>",
  "source": "./plugins/<plugin-name>",
  "description": "<description>",
  "version": "0.1.0",
  "author": {
    "name": "Chad Metcalf"
  }
}
```

### Naming Conventions

- Plugin names: kebab-case (`fzf-power`, `gh-recipes`)
- Command files: kebab-case `.md` (`add.md`, `audit-plugins.md`)
- Skill directories: kebab-case (`fzf-mastery`, `gh-api-recipes`)
- Reference files: kebab-case `.md` (`bind-actions.md`, `repo-settings.md`)
- Labels for issues: match plugin name (`fzf-power`, `gh-recipes`, `chad-tools`, `exe-dev`)

### Issue Filing

All issues go to `metcalfc/claude-plugin`. Labels:
- Plugin label (e.g., `gh-recipes`) — created with `gh label create` if missing
- Type label: `enhancement` for `/add`, `bug` for `/issue`
- Issue title prefix: `<plugin-name>: <short summary>`

### Audit

`/chad-tools:audit-plugins` runs a review/test cycle across all plugins. When adding a new plugin, update `plugins/chad-tools/commands/audit-plugins.md` to include it.

### README

When adding a plugin, update `README.md`:
1. Add install line in both terminal and slash command sections
2. Add a plugin section with capabilities table and commands list
3. Add an example to the Contributing section
