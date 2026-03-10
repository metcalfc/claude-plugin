---
name: setup
description: (lefthook) Configure shared lefthook config repo for this project
argument-hint: "<git-url> [ref] [config-files...]"
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

Configure a shared lefthook config repo for this project by creating `.claude/lefthook.local.md`.

## Step 1: Gather config

If `$ARGUMENTS` is provided, parse it:
- First arg: git URL (e.g., `https://github.com/org/lefthook-config`)
- Second arg (optional): ref/branch (default: `main`)
- Remaining args (optional): config file names (default: ask)

If no arguments, use AskUserQuestion to ask:
1. **Git URL** — the shared lefthook config repo URL
2. **Branch/tag** — which ref to track (default: `main`)

## Step 2: Discover config files

If config files weren't specified in args, try to list what's available in the remote repo:

```bash
gh api repos/<owner>/<repo>/contents --jq '.[].name' 2>/dev/null | grep -E '\.(yml|yaml)$'
```

If that works (public repo or user has access), present the files and let the user pick via AskUserQuestion.

If it fails (private repo, no access), ask the user to type the config file names.

## Step 3: Write settings file

Ensure `.claude/` directory exists:

```bash
mkdir -p .claude
```

Write `.claude/lefthook.local.md`:

```markdown
---
remote_repo: "<git-url>"
remote_ref: "<ref>"
remote_configs: ["<file1.yml>", "<file2.yml>"]
refetch_frequency: "24h"
---

# Shared Lefthook Config

Remote: <git-url> (ref: <ref>)
Configs: <file list>

Run `/lefthook:punch` to generate lefthook.yml with this shared config as a base.
```

## Step 4: Check gitignore

Check if `.claude/*.local.md` is in `.gitignore`:

```bash
grep -q '\.claude/\*\.local\.md' .gitignore 2>/dev/null
```

If not, offer to add it.

## Step 5: Confirm

Tell the user:
- Settings saved to `.claude/lefthook.local.md`
- Run `/lefthook:punch` to generate hooks with the shared config as a base
- The shared config provides baseline hooks; `/punch` will layer project-specific hooks on top
