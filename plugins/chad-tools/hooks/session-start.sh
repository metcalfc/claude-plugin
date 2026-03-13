#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook: inject skill index so Claude knows what's available
# before it starts working. Lightweight — names and triggers only.

cat <<'CONTEXT'
{
  "hookSpecificOutput": {
    "additionalContext": "## chad-tools: Available Skills\n\nBefore jumping into implementation, check if one of these skills applies:\n\n| Skill | Trigger |\n|-------|--------|\n| resume-branch | Starting/resuming work on a non-default branch, \"where was I\", \"pick up where I left off\" |\n| resolve-reviews | \"address review feedback\", \"resolve conversations\", after pushing fixes for PR review |\n| protect-branch | \"protect this repo\", \"add branch guardrails\", setting up a production repo |\n| gen-script | Asked to write a quick one-off script (bash, python, JS/TS) |\n| crystallize | \"make this a skill\", \"save this pattern\", recurring task that should be codified |\n\nIf a skill matches the user's intent, invoke it before taking other actions."
  }
}
CONTEXT
