# Repository Dispatch

Trigger custom events for cross-repo automation. Different from `gh workflow run` which triggers `workflow_dispatch` — this triggers `repository_dispatch`, a custom event type.

## Trigger a Dispatch Event

```bash
# Basic event
gh api -X POST repos/:owner/:repo/dispatches \
  -f event_type=deploy

# With payload data
gh api -X POST repos/:owner/:repo/dispatches \
  -f event_type=deploy \
  -f 'client_payload={"environment":"production","ref":"v1.2.3"}'

# Complex payload via --input
gh api -X POST repos/:owner/:repo/dispatches --input - <<'EOF'
{
  "event_type": "build-and-deploy",
  "client_payload": {
    "environment": "staging",
    "ref": "main",
    "triggered_by": "api",
    "services": ["web", "worker", "scheduler"]
  }
}
EOF
```

Returns 204 No Content on success.

## Receiving Dispatch Events

In a GitHub Actions workflow, listen for the event:

```yaml
on:
  repository_dispatch:
    types: [deploy, build-and-deploy]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Show payload
        run: |
          echo "Event: ${{ github.event.action }}"
          echo "Environment: ${{ github.event.client_payload.environment }}"
```

## Cross-Repo Automation

Trigger another repo's workflow from the current repo:

```bash
# Repo A triggers Repo B
gh api -X POST repos/org/repo-b/dispatches \
  -f event_type=upstream-updated \
  -f 'client_payload={"source_repo":"org/repo-a","commit":"abc123"}'
```

## Dispatch vs Workflow Dispatch

| Feature | `repository_dispatch` | `workflow_dispatch` |
|---------|----------------------|---------------------|
| Trigger | `gh api repos/:owner/:repo/dispatches` | `gh workflow run` |
| Event type | Custom string | Fixed |
| Payload | Arbitrary JSON | Defined inputs |
| Target | Any workflow listening | Specific workflow file |
| Use case | Cross-repo automation | Manual/API workflow trigger |
