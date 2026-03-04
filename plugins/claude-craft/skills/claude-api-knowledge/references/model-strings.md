# Claude Model Strings — Cross-Platform Reference

## Current Generation (Claude 4.5/4.6)

| Model | Anthropic 1P | AWS Bedrock | Google Vertex AI | Azure AI Foundry |
|-------|-------------|-------------|------------------|------------------|
| Opus 4.6 | `claude-opus-4-6-20250527` | `us.anthropic.claude-opus-4-6-20250527-v1:0` | `claude-opus-4-6@20250527` | `claude-opus-4-6-20250527` |
| Sonnet 4.6 | `claude-sonnet-4-6-20250514` | `us.anthropic.claude-sonnet-4-6-20250514-v1:0` | `claude-sonnet-4-6@20250514` | `claude-sonnet-4-6-20250514` |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` | `claude-haiku-4-5-20251001` |

## Previous Generation (Claude 4.5)

| Model | Anthropic 1P | AWS Bedrock | Google Vertex AI | Azure AI Foundry |
|-------|-------------|-------------|------------------|------------------|
| Opus 4.5 | `claude-opus-4-5-20250527` | `us.anthropic.claude-opus-4-5-20250527-v1:0` | `claude-opus-4-5@20250527` | `claude-opus-4-5-20250527` |
| Sonnet 4.5 | `claude-sonnet-4-5-20250514` | `us.anthropic.claude-sonnet-4-5-20250514-v1:0` | `claude-sonnet-4-5@20250514` | `claude-sonnet-4-5-20250514` |

## Legacy (Claude 4.0)

| Model | Anthropic 1P | AWS Bedrock | Google Vertex AI | Azure AI Foundry |
|-------|-------------|-------------|------------------|------------------|
| Sonnet 4.0 | `claude-sonnet-4-20250514` | `us.anthropic.claude-sonnet-4-20250514-v1:0` | `claude-sonnet-4@20250514` | `claude-sonnet-4-20250514` |

## Shorthand Aliases

Most SDKs and the Anthropic API accept shortened aliases that resolve to the latest dated version:

| Alias | Resolves to |
|-------|-------------|
| `claude-opus-4-6` | `claude-opus-4-6-20250527` |
| `claude-sonnet-4-6` | `claude-sonnet-4-6-20250514` |
| `claude-haiku-4-5` | `claude-haiku-4-5-20251001` |
| `claude-opus-4-5` | `claude-opus-4-5-20250527` |
| `claude-sonnet-4-5` | `claude-sonnet-4-5-20250514` |
| `claude-sonnet-4-0` | `claude-sonnet-4-20250514` |

## Bedrock Specifics

### ARN Format

Bedrock uses `us.anthropic.` prefix and `-v1:0` suffix:

```
us.anthropic.{model-id}-v1:0
```

### Cross-Region Inference

Bedrock supports cross-region inference with a `us.` prefix (US regions). For single-region, drop the prefix:

```
anthropic.claude-sonnet-4-6-20250514-v1:0   # single region
us.anthropic.claude-sonnet-4-6-20250514-v1:0  # cross-region (recommended)
```

### Bedrock SDK Usage

```python
import boto3
import json

bedrock = boto3.client("bedrock-runtime", region_name="us-east-1")

response = bedrock.invoke_model(
    modelId="us.anthropic.claude-sonnet-4-6-20250514-v1:0",
    body=json.dumps({
        "anthropic_version": "bedrock-2023-10-16",
        "max_tokens": 4096,
        "messages": [{"role": "user", "content": "Hello"}]
    })
)
```

## Vertex AI Specifics

### Model Path Format

Vertex uses `@` to separate model from date:

```
claude-{model}@{date}
```

### Vertex SDK Usage

```python
from anthropic import AnthropicVertex

client = AnthropicVertex(region="us-east5", project_id="my-project")

response = client.messages.create(
    model="claude-sonnet-4-6@20250514",
    max_tokens=4096,
    messages=[{"role": "user", "content": "Hello"}]
)
```

## Azure AI Foundry Specifics

Azure uses the same model IDs as Anthropic 1P:

```python
from anthropic import AnthropicAzure

client = AnthropicAzure(
    azure_endpoint="https://your-resource.services.ai.azure.com/",
    azure_deployment="claude-sonnet-4-6-20250514",
)

response = client.messages.create(
    model="claude-sonnet-4-6-20250514",
    max_tokens=4096,
    messages=[{"role": "user", "content": "Hello"}]
)
```

## Migration Guide

When upgrading model strings in existing code:

### From Claude 3.5 to Claude 4.x

| Old String | New String |
|-----------|-----------|
| `claude-3-5-sonnet-20241022` | `claude-sonnet-4-6-20250514` |
| `claude-3-5-haiku-20241022` | `claude-haiku-4-5-20251001` |
| `claude-3-opus-20240229` | `claude-opus-4-6-20250527` |

### Search Patterns

Find old model strings in a codebase:

```bash
# Find all Claude model references
rg 'claude-[0-9]' --type py --type ts --type js --type go

# Find specifically outdated 3.x strings
rg 'claude-3' --type py --type ts --type js --type go
```
