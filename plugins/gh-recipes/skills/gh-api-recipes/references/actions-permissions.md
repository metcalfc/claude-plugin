# Actions Permissions & Configuration

`gh secret` and `gh variable` exist, but there's no built-in subcommand for configuring Actions permissions, allowed actions, or default token permissions.

## Check Actions Status

```bash
# Get current Actions permissions for a repo
gh api repos/:owner/:repo/actions/permissions --jq '{enabled, allowed_actions}'

# Get default workflow permissions (GITHUB_TOKEN scope)
gh api repos/:owner/:repo/actions/permissions/workflow --jq '{default_workflow_permissions, can_approve_pull_request_reviews}'
```

## Enable/Disable Actions

```bash
# Enable Actions
gh api -X PUT repos/:owner/:repo/actions/permissions -F enabled=true -f allowed_actions=all

# Disable Actions entirely
gh api -X PUT repos/:owner/:repo/actions/permissions -F enabled=false
```

## Restrict Allowed Actions

```bash
# Allow only local actions (defined in the repo)
gh api -X PUT repos/:owner/:repo/actions/permissions -F enabled=true -f allowed_actions=local_only

# Allow selected actions only
gh api -X PUT repos/:owner/:repo/actions/permissions -F enabled=true -f allowed_actions=selected

# Then specify which actions are allowed
gh api -X PUT repos/:owner/:repo/actions/permissions/selected-actions --input - <<'EOF'
{
  "github_owned_allowed": true,
  "verified_allowed": true,
  "patterns_allowed": ["owner/action-name@*", "another-owner/*"]
}
EOF

# Check current selected actions
gh api repos/:owner/:repo/actions/permissions/selected-actions
```

## Default GITHUB_TOKEN Permissions

```bash
# Set to read-only (more secure, recommended)
gh api -X PUT repos/:owner/:repo/actions/permissions/workflow \
  -f default_workflow_permissions=read \
  -F can_approve_pull_request_reviews=false

# Set to read-write
gh api -X PUT repos/:owner/:repo/actions/permissions/workflow \
  -f default_workflow_permissions=write \
  -F can_approve_pull_request_reviews=true
```

## Org-Level Actions Permissions

```bash
# Get org-level Actions permissions
gh api orgs/ORG/actions/permissions --jq '{enabled_repositories, allowed_actions}'

# Set org-level permissions
gh api -X PUT orgs/ORG/actions/permissions \
  -f enabled_repositories=all \
  -f allowed_actions=selected

# Set org default workflow permissions
gh api -X PUT orgs/ORG/actions/permissions/workflow \
  -f default_workflow_permissions=read \
  -F can_approve_pull_request_reviews=false
```

## Actions Runner Groups (Org)

```bash
# List runner groups
gh api orgs/ORG/actions/runner-groups --jq '.runner_groups[] | [.id, .name, .default] | @tsv'

# List self-hosted runners
gh api repos/:owner/:repo/actions/runners --jq '.runners[] | [.id, .name, .status, .os] | @tsv'
```

## Actions Cache Usage

`gh cache list` and `gh cache delete` exist, but cache usage stats require the API:

```bash
# Repo cache usage
gh api repos/:owner/:repo/actions/cache/usage --jq '"Cache count: \(.active_caches_count), Size: \(.active_caches_size_in_bytes / 1048576 | floor)MB"'

# Org cache usage
gh api orgs/ORG/actions/cache/usage --jq '"Total: \(.total_active_caches_size_in_bytes / 1073741824 | floor)GB"'
```
