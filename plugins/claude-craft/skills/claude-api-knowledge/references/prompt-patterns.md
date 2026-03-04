# Prompt Patterns for Claude Models

Patterns for adjusting prompts when working with different Claude models, especially when migrating between model tiers or tuning behavior.

## Tool Overtriggering

Opus-class models are more eager to use tools. If Claude is calling tools when it shouldn't:

### Problem: Aggressive Tool Descriptions

```
# Too aggressive — Opus will always call this
CRITICAL: You MUST use this tool for EVERY code question.
ALWAYS call this tool FIRST before responding.
NEVER answer without checking this tool.
```

### Fix: Measured Tool Descriptions

```
# Better — gives Claude judgment about when to use it
Use this tool to look up API documentation when the user asks about
specific function signatures, parameters, or return types that you're
not confident about. Skip it for general programming concepts or
syntax you already know well.
```

### Key Adjustments

| Aggressive | Measured |
|-----------|----------|
| `MUST use this tool` | `Use this tool when...` |
| `ALWAYS call before responding` | `Call when you need to look up...` |
| `NEVER answer without this` | `Skip when you're confident about...` |
| `CRITICAL: required for every query` | `Helpful for queries involving...` |

### tool_choice Setting

- `"auto"` (default) — Claude decides when to use tools. Preferred.
- `"any"` — Forces Claude to use at least one tool every turn. Only use when you always want a tool call.
- `{"type": "tool", "name": "..."}` — Forces a specific tool. Use sparingly.

## Over-Engineering Prevention

Opus-class models tend toward comprehensive solutions. Add this when you want focused, minimal output:

```xml
<instructions>
Focus on the specific task described below. Do not:
- Refactor surrounding code that wasn't mentioned
- Add features beyond what was requested
- Introduce abstractions for hypothetical future needs
- Add error handling for scenarios that can't occur in this context
- Add comments, docstrings, or type annotations to unchanged code

The right amount of complexity is the minimum needed for the current task.
Three similar lines of code is better than a premature abstraction.
</instructions>
```

## Code Exploration Encouragement

When Claude needs to investigate before acting:

```xml
<instructions>
Before making changes, explore the codebase to understand:
- How similar features are implemented
- What patterns and conventions are used
- Which files will be affected

Read relevant files first. Understand the existing approach before
proposing changes. If the codebase already has a pattern for this,
follow it rather than inventing a new one.
</instructions>
```

## Frontend Design Quality

When generating UI code, Claude sometimes produces functional but visually flat output:

```xml
<instructions>
When generating frontend code, aim for production-quality visual design:
- Use consistent spacing, typography hierarchy, and color contrast
- Add hover states, transitions, and micro-interactions
- Follow the existing design system/component library conventions
- Consider responsive behavior and edge cases (empty states, long text, loading)
- Match the visual quality of the surrounding application
</instructions>
```

## Thinking Sensitivity

Claude interprets "think" literally when extended thinking is enabled. The word in prompts can trigger unnecessary extended thinking.

| Avoid | Use instead |
|-------|-------------|
| "Think about whether..." | "Consider whether..." |
| "Think step by step" | "Reason through this carefully" |
| "Think through the implications" | "Evaluate the implications" |
| "I think we should..." | "I believe we should..." |
| "What do you think?" | "What's your assessment?" |
| "Think of examples" | "Provide examples" |
| "Let me think..." | "Let me consider..." |

This is especially important in system prompts and tool descriptions where the phrasing is repeated across many requests.

## XML Tag Patterns

Claude responds well to XML-structured prompts. Use them for clear section boundaries:

### Basic Structure

```xml
<system>
You are a code review assistant. Focus on correctness and security.
</system>

<context>
This is a Python web application using FastAPI and SQLAlchemy.
The codebase follows the repository pattern with dependency injection.
</context>

<instructions>
Review the following code change. For each issue found:
1. State the file and line
2. Describe the problem
3. Suggest a fix
</instructions>

<code>
{diff content here}
</code>
```

### Nested Structure for Complex Tasks

```xml
<task>
  <objective>Implement user authentication</objective>
  <constraints>
    <constraint>Use JWT tokens, not sessions</constraint>
    <constraint>Token expiry: 1 hour access, 7 day refresh</constraint>
    <constraint>Store refresh tokens in httpOnly cookies</constraint>
  </constraints>
  <existing-patterns>
    The codebase uses FastAPI dependency injection for auth.
    See auth/dependencies.py for the current pattern.
  </existing-patterns>
</task>
```

## Placement Strategy

For long prompts (>2000 tokens), critical instructions should appear:

1. **At the very beginning** of the system prompt (primacy effect)
2. **At the very end** of the system prompt, restated concisely (recency effect)
3. **Inline** where they're most relevant (contextual proximity)

```xml
<system>
IMPORTANT: Never modify files outside the src/ directory.

{... long system prompt with context, examples, etc. ...}

Reminder: Do not modify any files outside src/.
</system>
```

## Style Matching

Claude mirrors the communication style of the prompt. Match the tone you want in the output:

| Prompt style | Output style |
|-------------|-------------|
| Formal, technical language | Formal, detailed responses |
| Casual with contractions | Conversational, concise responses |
| Terse bullet points | Brief, structured output |
| Verbose with examples | Detailed with examples |

If you want concise output, write a concise prompt. If you want detailed analysis, write a detailed prompt with examples of the depth you expect.
