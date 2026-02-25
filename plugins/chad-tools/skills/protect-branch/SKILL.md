---
name: protect-branch
description: Add branch protection hooks to the current repo. Blocks
  pushes to main/master and force pushes via Claude Code. Use when
  setting up a production repo or when the user says "protect this
  repo" or "add branch guardrails".
---

Add branch protection to the current repo's Claude Code config:

1. Check if `.claude/settings.json` exists in the repo root
2. If it exists, read it and merge the hooks into the existing config
   (preserve any existing settings)
3. If not, create `.claude/settings.json` with this content:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'CMD=$(cat | jq -r \".tool_input.command // empty\"); if echo \"$CMD\" | grep -qE \"git push.*(main|master)\"; then echo \"BLOCKED: Use a feature branch and PR.\" >&2; exit 2; fi; if echo \"$CMD\" | grep -qE \"git push (-f|--force)\"; then echo \"BLOCKED: Force push requires explicit approval.\" >&2; exit 2; fi'"
          }
        ]
      }
    ]
  }
}
```

4. Show what was written and confirm
5. Ask: "Want me to commit this now?"
