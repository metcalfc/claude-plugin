# Commit Statuses

The legacy Status API — distinct from the newer Checks API. `gh pr checks` can read results but cannot create statuses. Use `gh api` to post commit statuses from scripts and custom CI.

## Create a Commit Status

States: `pending`, `success`, `failure`, `error`.

```bash
# Basic status
gh api repos/:owner/:repo/statuses/SHA \
  -f state=success \
  -f context="ci/build"

# With target URL and description
gh api repos/:owner/:repo/statuses/SHA \
  -f state=success \
  -f context="ci/build" \
  -f description="Build passed" \
  -f target_url="https://ci.example.com/builds/123"

# Pending status (set before starting work)
gh api repos/:owner/:repo/statuses/SHA \
  -f state=pending \
  -f context="deploy/staging" \
  -f description="Deploying to staging..."
```

The `context` field acts as a namespace — multiple statuses with different contexts can exist on the same commit.

## Get Statuses for a Commit

```bash
# All statuses (includes history — every update, not just latest)
gh api repos/:owner/:repo/statuses/SHA --jq '.[] | [.state, .context, .description, .created_at] | @tsv'

# Combined status (the rolled-up result GitHub shows)
gh api repos/:owner/:repo/commits/SHA/status --jq '{state, total_count, statuses: [.statuses[] | {context, state}]}'
```

## Get Statuses for HEAD of a Branch

```bash
gh api repos/:owner/:repo/commits/main/status --jq '.state'
```

## Common Patterns

```bash
# Gate a deploy on all statuses passing
state=$(gh api repos/:owner/:repo/commits/SHA/status --jq '.state')
if [ "$state" = "success" ]; then
  echo "All checks passed, deploying..."
else
  echo "Status: $state — aborting deploy"
  exit 1
fi
```

## Statuses vs Check Runs

- **Statuses** (this file): Legacy API, simpler, state + context + URL. Created via REST.
- **Check Runs**: Newer API, richer (markdown summaries, file annotations, actions). Created via REST but more complex.

Most external CI systems still use statuses. GitHub Actions uses check runs.
