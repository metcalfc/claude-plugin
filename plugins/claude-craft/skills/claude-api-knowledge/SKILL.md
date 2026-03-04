---
name: claude-api-knowledge
description: >-
  This skill should be used when the user asks about Claude model strings,
  model IDs, model names, "which model", API calls to the Claude API,
  Anthropic SDK usage, Bedrock integration, Vertex AI integration,
  Azure AI Foundry, effort parameter, extended thinking, thinking budget,
  "migrate to opus", model migration, prompt adjustment for different models,
  tool overtriggering, prompt engineering for Claude, or when writing code
  that imports `anthropic` or `@anthropic-ai/sdk`.
---

# Claude API & Model Knowledge

Reference for Claude model strings, API configuration, and prompt patterns across all platforms. Use this when writing code that calls the Claude API, selecting models, or adjusting prompts for model behavioral differences.

## Current Model Family

The current generation is **Claude 4.5/4.6**. When users ask for "the latest model" or "best model", use these:

| Model | Model ID | Notes |
|-------|----------|-------|
| **Opus 4.6** | `claude-opus-4-6-20250527` | Most capable, highest quality |
| **Sonnet 4.6** | `claude-sonnet-4-6-20250514` | Best balance of speed and quality |
| **Haiku 4.5** | `claude-haiku-4-5-20251001` | Fastest, lowest cost |

Shorthand aliases accepted by most SDKs: `claude-opus-4-6`, `claude-sonnet-4-6`, `claude-haiku-4-5`.

### Cross-Platform Model Strings

Model IDs differ by platform. The Anthropic 1P strings above work with the Anthropic SDK directly. For cloud providers:

- **AWS Bedrock**: Uses ARN-style model IDs (e.g., `us.anthropic.claude-opus-4-6-20250527-v1:0`)
- **Google Vertex AI**: Uses publisher path (e.g., `claude-opus-4-6@20250527`)
- **Azure AI Foundry**: Uses the Anthropic 1P strings directly

See [references/model-strings.md](references/model-strings.md) for the complete cross-platform table including previous-generation models.

## Effort Parameter

Control response quality vs speed with the effort parameter (beta feature):

```python
# Python SDK
client.messages.create(
    model="claude-sonnet-4-6-20250514",
    max_tokens=16000,
    thinking={"type": "enabled", "budget_tokens": 10000},
    betas=["effort-2025-11-24"],
    output_config={"effort": "high"},  # low, medium, high
    messages=[...]
)
```

| Effort | When to use |
|--------|-------------|
| `low` | Simple lookups, classification, formatting |
| `medium` | General-purpose tasks (default behavior) |
| `high` | Complex reasoning, math, code generation, analysis |

Effort interacts with thinking: `high` effort + thinking enabled = maximum reasoning depth. `low` effort may reduce or skip thinking even when enabled.

See [references/effort-and-thinking.md](references/effort-and-thinking.md) for SDK examples in Python, TypeScript, and raw API, plus budget tuning guidance.

## Model Behavioral Notes

Different Claude models have different sensitivities. When migrating between models or tuning prompts:

### Tool Overtriggering

Opus-class models are more eager to use tools. If tools are being called when they shouldn't be:
- Soften aggressive language in tool descriptions — replace CRITICAL/MUST/ALWAYS/NEVER with measured guidance
- Add "only use this tool when..." constraints rather than "ALWAYS use this tool for..."
- Use `tool_choice: "auto"` (not `"any"`) and describe when NOT to use tools

### Thinking Sensitivity

Claude interprets "think" literally when extended thinking is enabled. The word "think" in prompts can trigger extended thinking unexpectedly:
- Replace "think about" with "consider" or "evaluate"
- Replace "I think" with "I believe" or "I expect"
- Replace "think step by step" with "reason through this carefully"

### Over-Engineering Prevention

Opus-class models tend toward comprehensive solutions. When you want focused, minimal changes:

```
Focus on the specific task. Do not refactor surrounding code, add features
beyond what was requested, or introduce abstractions for hypothetical future needs.
The right amount of complexity is the minimum needed for the current task.
```

### Prompt Integration Guidelines

- Use XML tags (`<instructions>`, `<context>`, `<examples>`) for structure — Claude responds well to them
- Place critical instructions at the beginning AND end of long prompts (primacy + recency)
- Match the style of the output you want — formal prompts get formal responses

See [references/prompt-patterns.md](references/prompt-patterns.md) for copy-paste snippets and detailed guidance.

## Reference Files

- [references/model-strings.md](references/model-strings.md) — Complete model string table for all platforms and generations
- [references/effort-and-thinking.md](references/effort-and-thinking.md) — Effort parameter, thinking budgets, SDK examples
- [references/prompt-patterns.md](references/prompt-patterns.md) — Prompt adjustment patterns for model behavioral differences
