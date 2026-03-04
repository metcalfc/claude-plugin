# Effort Parameter & Extended Thinking

## Effort Parameter

The effort parameter controls how much processing Claude applies to a request. It's a beta feature that trades speed for quality.

### Beta Header

The effort parameter requires the beta header:

```
anthropic-beta: effort-2025-11-24
```

### Configuration

Set via `output_config.effort` in the API request body:

```json
{
  "model": "claude-sonnet-4-6-20250514",
  "max_tokens": 4096,
  "output_config": {
    "effort": "high"
  },
  "messages": [...]
}
```

Values: `low`, `medium`, `high`

### Python SDK

```python
import anthropic

client = anthropic.Anthropic()

# With effort parameter
response = client.messages.create(
    model="claude-sonnet-4-6-20250514",
    max_tokens=4096,
    betas=["effort-2025-11-24"],
    output_config={"effort": "high"},
    messages=[
        {"role": "user", "content": "Analyze this algorithm's time complexity..."}
    ]
)
```

### TypeScript SDK

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const response = await client.messages.create({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 4096,
  betas: ["effort-2025-11-24"],
  output_config: { effort: "high" },
  messages: [
    { role: "user", content: "Analyze this algorithm's time complexity..." }
  ]
});
```

### Raw API (curl)

```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "anthropic-beta: effort-2025-11-24" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4-6-20250514",
    "max_tokens": 4096,
    "output_config": {"effort": "high"},
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

## Extended Thinking

Extended thinking gives Claude a dedicated reasoning space before responding. Available on all current models.

### Enabling Thinking

```python
response = client.messages.create(
    model="claude-sonnet-4-6-20250514",
    max_tokens=16000,
    thinking={
        "type": "enabled",
        "budget_tokens": 10000  # tokens allocated for thinking
    },
    messages=[{"role": "user", "content": "Solve this math problem..."}]
)

# Access thinking content
for block in response.content:
    if block.type == "thinking":
        print(f"Thinking: {block.thinking}")
    elif block.type == "text":
        print(f"Response: {block.text}")
```

### TypeScript

```typescript
const response = await client.messages.create({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 16000,
  thinking: {
    type: "enabled",
    budget_tokens: 10000
  },
  messages: [
    { role: "user", content: "Solve this math problem..." }
  ]
});

for (const block of response.content) {
  if (block.type === "thinking") {
    console.log("Thinking:", block.thinking);
  } else if (block.type === "text") {
    console.log("Response:", block.text);
  }
}
```

### Budget Guidelines

| Task type | Recommended budget | Why |
|-----------|-------------------|-----|
| Simple Q&A | Don't enable thinking | Overhead not worth it |
| Code generation | 5,000–10,000 | Enough for planning approach |
| Complex analysis | 10,000–20,000 | Needs space to reason through details |
| Math/logic puzzles | 15,000–30,000 | May need multiple reasoning attempts |
| Research synthesis | 20,000–50,000 | Large context requires extensive reasoning |

### Thinking + Effort Interaction

The effort parameter and thinking budget work together:

| Effort | Thinking | Behavior |
|--------|----------|----------|
| `low` | disabled | Fast, minimal processing |
| `low` | enabled | May reduce or skip thinking despite budget |
| `medium` | disabled | Standard processing (default) |
| `medium` | enabled | Uses thinking budget normally |
| `high` | disabled | More thorough without explicit thinking |
| `high` | enabled | Maximum reasoning depth — uses full budget |

**Recommendation:** For tasks that need deep reasoning, use `high` effort + thinking enabled with a generous budget. For routine tasks, use `low` effort without thinking.

### Streaming with Thinking

When streaming, thinking blocks arrive before text blocks:

```python
with client.messages.stream(
    model="claude-sonnet-4-6-20250514",
    max_tokens=16000,
    thinking={"type": "enabled", "budget_tokens": 10000},
    messages=[{"role": "user", "content": "..."}]
) as stream:
    for event in stream:
        if event.type == "content_block_start":
            if event.content_block.type == "thinking":
                print("Thinking started...")
            elif event.content_block.type == "text":
                print("Response started...")
        elif event.type == "content_block_delta":
            if event.delta.type == "thinking_delta":
                print(event.delta.thinking, end="")
            elif event.delta.type == "text_delta":
                print(event.delta.text, end="")
```

### Important Constraints

- `budget_tokens` must be less than `max_tokens`
- Thinking tokens count toward usage/billing but don't appear in `max_tokens` output limit
- When thinking is enabled, `temperature` must be 1 (default) — custom temperatures aren't supported
- Thinking content should not be shown to end users in production (it's for debugging/development)
