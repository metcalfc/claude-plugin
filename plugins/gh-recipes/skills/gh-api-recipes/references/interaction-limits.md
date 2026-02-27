# Interaction Limits

Temporarily restrict who can interact with a repository. Useful for spam control on open source repos. No built-in `gh` subcommand.

## Get Current Limits

```bash
# Returns empty object {} if no limits are set
gh api repos/:owner/:repo/interaction-limits
```

## Set Interaction Limits

Limit levels:
- `existing_users` — users with prior contributions or activity
- `contributors_only` — users who have previously committed
- `collaborators_only` — only repo collaborators

Expiry options: `one_day`, `three_days`, `one_week`, `one_month`, `six_months` (omit for permanent).

```bash
# Restrict to collaborators only for one week
gh api -X PUT repos/:owner/:repo/interaction-limits \
  -f limit=collaborators_only \
  -f expiry=one_week

# Restrict to contributors for one month
gh api -X PUT repos/:owner/:repo/interaction-limits \
  -f limit=contributors_only \
  -f expiry=one_month

# Permanent restriction to collaborators
gh api -X PUT repos/:owner/:repo/interaction-limits \
  -f limit=collaborators_only
```

## Remove Limits

```bash
gh api -X DELETE repos/:owner/:repo/interaction-limits
```

## Org-Level Limits

```bash
# Set org-wide interaction limits
gh api -X PUT orgs/ORG/interaction-limits \
  -f limit=existing_users \
  -f expiry=one_week

# Check org limits
gh api orgs/ORG/interaction-limits

# Remove org limits
gh api -X DELETE orgs/ORG/interaction-limits
```

Note: Org-level limits override repo-level limits.
