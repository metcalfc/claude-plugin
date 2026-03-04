# Claude Plugin Marketplace

A collection of Claude Code plugins. Each plugin lives in `plugins/<name>/`.

**This repo is the canonical home for all plugins, skills, commands, and agents.** If something is useful but not big enough to be its own plugin, it goes in `chad-tools`. Only create a new plugin when the scope warrants its own install.

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
description: (<plugin-name>) Request a new feature
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
4. **Sanitize** — apply the standard sanitization rules (see below) before drafting
5. **File the issue** — create label if needed, then `gh issue create --repo metcalfc/claude-plugin --label "<plugin-name>,enhancement"`

### `/issue` Command Pattern

```yaml
---
name: issue
description: (<plugin-name>) Report a bug
argument-hint: "<what went wrong>"
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---
```

Flow:
1. **Gather context** — version info, OS, the command that failed, error output
2. **Sanitize** — apply the standard sanitization rules (see below)
3. **Check for duplicates** — same as `/add` but with `--label "<plugin-name>,bug"`
4. **Draft and review** — show full issue to user via AskUserQuestion, options: "File it" or "Edit first"
5. **File the issue** — only after explicit user approval

### `/help` Command Pattern

```yaml
---
name: help
description: (<plugin-name>) Plugin help
allowed-tools: []
---
```

Display a formatted help block with sections: plugin tagline, SKILLS/RECIPES (if applicable), COMMANDS list, and USAGE examples.

### Command Description Prefix

**Every command description MUST start with `(<plugin-name>)`** to disambiguate commands with the same name across plugins. Examples:

- `(chad-tools) Multi-agent code review — local diff or PR`
- `(exe-dev) List VMs with status`
- `(gh-recipes) Request a new recipe`

This prefix appears in the slash command picker and tells the user which plugin owns the command.

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

### Version Bumping

**Every commit that changes a plugin MUST bump its version** in both `plugin.json` and `marketplace.json`. The plugin manager uses the version to decide whether to update — if the version doesn't change, users won't get the new code.

Follow semver:
- **Patch** (0.1.0 → 0.1.1): bug fixes, doc corrections, minor tweaks
- **Minor** (0.1.0 → 0.2.0): new commands, skills, agents, or significant feature changes
- **Major** (0.x → 1.0, 1.x → 2.0): breaking changes to command behavior or plugin structure

Both files must match:
1. `plugins/<name>/.claude-plugin/plugin.json` — the `version` field
2. `.claude-plugin/marketplace.json` — the `version` field for that plugin's entry

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

### Sanitization Rules

**Every command that files or comments on a GitHub issue** (`/add`, `/issue`, or any future command) MUST scrub the body before drafting. This applies to issue bodies, comments, and any text posted to GitHub.

Scrub ALL of the following:

- SSH keys, API tokens, passwords, secrets, credentials
- IP addresses (replace with `<redacted-ip>`)
- Email addresses not already public on GitHub (replace with `<redacted-email>`)
- Private repo names or org names if not the plugin repo itself
- Hostnames of internal/private systems
- VM hostnames like `*.exe.xyz` (replace with `<vm>.exe.xyz`)
- File paths containing usernames (replace `/Users/username/` or `/home/username/` with `~/`)
- Environment variable values (keep the key names, redact values)
- Branch names if they contain sensitive project info (ask if unsure)

This list is the canonical source. When adding a new plugin, copy these rules into both `add.md` and `issue.md`. When updating the list, update all existing plugins too.

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
