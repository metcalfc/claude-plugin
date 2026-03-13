# Shelley — Detailed Capabilities

Shelley is exe.dev's web-based coding agent, included on all default exeuntu VMs. It runs on port 9999 at `https://<vmname>.shelley.exe.xyz/`. Open source at github.com/boldsoftware/shelley.

## Key Features

### Multi-Model Support (BYOK)
Uses the LLM Gateway by default (no API key needed). Also supports bring-your-own-key for:
- Anthropic (Claude)
- OpenAI
- Google Gemini
- z.ai

### Conversation Distillation
LLM-powered context window optimization for long sessions. Automatically compresses conversation history to stay within context limits while preserving critical information.

### Browser Tool with Profiling
Built-in browser for web development workflows. Includes performance profiling for identifying bottlenecks in web apps.

### Subagents
Launch sub-tasks with context continuation. Subagents inherit the conversation context and can work on isolated subtasks.

### Skills System
Reusable task patterns that Shelley can invoke. Similar to Claude Code skills but within the Shelley environment.

### Diff Viewer
Integration with diffs.com for reviewing code changes inline.

### HTML iframe Output
Render rich visualizations directly in chat — Vega-Lite charts, HTML previews, interactive content.

### Shell Commands in Chat
Execute commands inline with `!` prefix:
```
!bash         # run bash commands
!git show HEAD  # show latest commit
```

### Multi-Language Support
Works across programming languages and frameworks.

### Self-Upgrade
Update Shelley from within its own UI, in addition to `ssh exe.dev shelley install <vmname>`.

### Notifications
Command palette integration for task completion alerts.

### Markdown Rendering
Chat output renders markdown by default for readable formatting.

## Guidance Files

Shelley reads guidance files in priority order:
1. `~/.config/shelley/AGENTS.md` — personal/global config
2. `AGENTS.md` — project-level (in git root or working directory)
3. `CLAUDE.md` — project-level (in git root or working directory)
4. `DEAR_LLM.md` — project-level (in git root or working directory)

## Upgrading

```bash
# From lobby
ssh exe.dev shelley install <vmname>

# Or from Shelley's own UI
# Use the self-upgrade option in the command palette
```

VMs ship with the Shelley version available at creation time. Upgrade to get new features.
