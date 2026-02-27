# Repository Settings

Operations for repository configuration that don't have dedicated `gh` subcommands.

## Topics

```bash
# List topics
gh api repos/:owner/:repo/topics --jq '.names[]'

# Set topics (replaces all existing topics)
gh api -X PUT repos/:owner/:repo/topics --input - <<< '{"names":["cli","golang","devtools"]}'
```

## Autolinks

Autolinks automatically convert references like `TICKET-123` into links to external systems.

```bash
# List autolinks
gh api repos/:owner/:repo/autolinks --jq '.[] | [.id, .key_prefix, .url_template] | @tsv'

# Create autolink (e.g., JIRA)
gh api repos/:owner/:repo/autolinks \
  -f key_prefix="JIRA-" \
  -f url_template="https://jira.example.com/browse/JIRA-<num>" \
  -F is_alphanumeric=false

# Delete autolink
gh api -X DELETE repos/:owner/:repo/autolinks/1
```

## Deploy Keys

```bash
# List deploy keys
gh api repos/:owner/:repo/keys --jq '.[] | [.id, .title, .read_only] | @tsv'

# Add deploy key
gh api repos/:owner/:repo/keys \
  -f title="CI Server" \
  -f key="ssh-ed25519 AAAA..." \
  -F read_only=true

# Remove deploy key
gh api -X DELETE repos/:owner/:repo/keys/1
```

## Branch Protection Rules

```bash
# Get branch protection for main
gh api repos/:owner/:repo/branches/main/protection

# Set branch protection
gh api -X PUT repos/:owner/:repo/branches/main/protection \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci/build", "ci/test"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null
}
EOF

# Remove branch protection
gh api -X DELETE repos/:owner/:repo/branches/main/protection
```

## Tag Protection (Rulesets)

Tag protection via classic tag protection rules is deprecated. Use repository rulesets instead.

```bash
# List rulesets
gh api repos/:owner/:repo/rulesets --jq '.[] | [.id, .name, .enforcement] | @tsv'

# Get a specific ruleset
gh api repos/:owner/:repo/rulesets/1

# Create a tag protection ruleset
gh api repos/:owner/:repo/rulesets --input - <<'EOF'
{
  "name": "protect-releases",
  "enforcement": "active",
  "target": "tag",
  "conditions": {
    "ref_name": {
      "include": ["refs/tags/v*"],
      "exclude": []
    }
  },
  "rules": [
    { "type": "creation" },
    { "type": "deletion" }
  ]
}
EOF
```

## Repository Visibility & Settings

```bash
# Get repo settings
gh api repos/:owner/:repo --jq '{visibility, default_branch, has_issues, has_wiki, has_projects, allow_merge_commit, allow_squash_merge, allow_rebase_merge, delete_branch_on_merge}'

# Update settings
gh api -X PATCH repos/:owner/:repo \
  -F delete_branch_on_merge=true \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false
```

## Webhooks

```bash
# List webhooks
gh api repos/:owner/:repo/hooks --jq '.[] | [.id, .name, .active, .config.url] | @tsv'

# Create webhook
gh api repos/:owner/:repo/hooks --input - <<'EOF'
{
  "config": {
    "url": "https://example.com/webhook",
    "content_type": "json",
    "secret": "your-secret"
  },
  "events": ["push", "pull_request"],
  "active": true
}
EOF

# Delete webhook
gh api -X DELETE repos/:owner/:repo/hooks/1
```

## Environments

```bash
# List environments
gh api repos/:owner/:repo/environments --jq '.environments[] | [.name, .protection_rules[].type] | @tsv'

# Create/update environment
gh api -X PUT repos/:owner/:repo/environments/production --input - <<'EOF'
{
  "reviewers": [
    {"type": "User", "id": 12345}
  ],
  "deployment_branch_policy": {
    "protected_branches": true,
    "custom_branch_policies": false
  }
}
EOF
```
