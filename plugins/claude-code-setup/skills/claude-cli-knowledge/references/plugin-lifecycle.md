# Plugin Lifecycle

How plugins are installed, cached, updated, and resolved.

## Marketplace → Install → Cache Flow

```
1. Add marketplace:      claude plugin marketplace add owner/repo
2. Marketplace cloned:   ~/.claude/plugins/marketplaces/<name>/
3. Install plugin:       claude plugin install <name>
4. Plugin cached:        ~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/
5. Session loads from:   cache directory (not marketplace directory)
```

## The Version Cache Problem

The plugin manager uses `version` from `plugin.json` to determine cache keys. When a plugin is installed or updated:

1. Manager reads `plugin.json` from the marketplace source
2. Checks if `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` exists
3. If the version directory exists → **uses cached copy, skips download**
4. If the version directory doesn't exist → downloads and caches

This means: **if you change plugin files without bumping the version, users who already have that version cached will never see the changes.**

### Symptoms of a Missing Version Bump

- "I updated my plugin but nothing changed"
- Plugin behavior differs between fresh install and existing users
- Changes work in `--plugin-dir` local testing but not after `marketplace update`
- Users see old skill content, old commands, old hooks

### The Fix

Every commit that changes any file inside `plugins/<name>/` must:

1. Bump `version` in `plugins/<name>/.claude-plugin/plugin.json`
2. Bump `version` in the marketplace registry (e.g., `marketplace.json`)
3. Both versions must match

## Plugin Resolution Order

When Claude Code loads, it resolves plugins in this order:

1. **`--plugin-dir` flags** — highest priority, for local testing
2. **Project plugins** — `.claude-plugin/` in the current directory
3. **Installed plugins** — from marketplace cache

If two plugins have the same name, the higher-priority source wins.

## Marketplace Types

| Source | Format | Example |
|--------|--------|---------|
| GitHub repo | `owner/repo` | `metcalfc/claude-plugin` |
| Local path | `/absolute/path` | `/home/user/my-marketplace` |

**For GitHub repos:** Use `owner/repo` format only. No `github:` prefix. The CLI resolves this automatically.

### Sparse Checkout for Monorepos

If the marketplace is inside a larger repo:

```bash
claude plugin marketplace add owner/repo --sparse .claude-plugin plugins
```

This limits the checkout to only the specified directories.

## Update Flow

```bash
# Update marketplace catalog (fetches latest commit)
claude plugin marketplace update

# Update specific plugin (re-resolves from marketplace)
claude plugin update <name>
```

After updating, **restart Claude Code** for changes to take effect. Plugins are loaded at session start.

## Plugin Validation

Validate a plugin before publishing:

```bash
claude plugin validate /path/to/plugin
```

Checks:
- `plugin.json` manifest is valid JSON with required fields
- Directory structure follows conventions
- Component files are parseable

## Debugging Plugin Issues

```bash
# See what's installed and from where
claude plugin list --json | jq .

# See all marketplaces
claude plugin marketplace list --json | jq .

# Check cache contents
ls ~/.claude/plugins/cache/

# Debug plugin loading
claude --debug
```

### Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Plugin not updating | Version not bumped | Bump version in both files |
| Skill not triggering | Description doesn't match query | Improve trigger phrases |
| Hook not firing | Wrong event name or matcher | Check `hooks.json` schema |
| Command not appearing | File not in `commands/` dir | Check directory structure |
| "Plugin not found" on install | Marketplace not added | `claude plugin marketplace add owner/repo` |
