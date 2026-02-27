# Dependabot Alerts

No `gh dependabot` subcommand exists. Use `gh api` to list, view, and manage Dependabot vulnerability alerts.

## List Alerts

```bash
# All open alerts
gh api repos/:owner/:repo/dependabot/alerts --jq '.[] | [.number, .state, .security_advisory.severity, .security_advisory.summary] | @tsv'

# Only critical/high severity
gh api repos/:owner/:repo/dependabot/alerts -f severity=critical,high \
  --jq '.[] | [.number, .security_advisory.severity, .security_advisory.summary, .dependency.package.name] | @tsv'

# Filter by state
gh api repos/:owner/:repo/dependabot/alerts -f state=open --jq '.[] | [.number, .dependency.package.name, .security_advisory.severity] | @tsv'

# Filter by ecosystem
gh api repos/:owner/:repo/dependabot/alerts -f ecosystem=npm --jq '.[] | [.number, .dependency.package.name, .security_advisory.summary] | @tsv'

# Filter by package name
gh api repos/:owner/:repo/dependabot/alerts -f package=lodash --jq '.[] | [.number, .state, .security_advisory.severity] | @tsv'

# Paginate for repos with many alerts
gh api repos/:owner/:repo/dependabot/alerts --paginate -f state=open \
  --jq '.[] | [.number, .dependency.package.name, .security_advisory.severity] | @tsv'
```

## Get Alert Details

```bash
# Full details for a specific alert
gh api repos/:owner/:repo/dependabot/alerts/ALERT_NUMBER \
  --jq '{number, state, severity: .security_advisory.severity, summary: .security_advisory.summary, package: .dependency.package.name, manifest: .dependency.manifest_path, fix: .security_vulnerability.first_patched_version.identifier}'
```

## Dismiss an Alert

Dismiss reasons: `fix_started`, `inaccurate`, `no_bandwidth`, `not_used`, `tolerable_risk`.

```bash
# Dismiss as tolerable risk
gh api -X PATCH repos/:owner/:repo/dependabot/alerts/ALERT_NUMBER \
  -f state=dismissed \
  -f dismissed_reason=tolerable_risk \
  -f dismissed_comment="Mitigated by input validation layer"

# Dismiss as not used
gh api -X PATCH repos/:owner/:repo/dependabot/alerts/ALERT_NUMBER \
  -f state=dismissed \
  -f dismissed_reason=not_used
```

## Reopen an Alert

```bash
gh api -X PATCH repos/:owner/:repo/dependabot/alerts/ALERT_NUMBER \
  -f state=open
```

## Summary / Counts

```bash
# Count by severity
gh api repos/:owner/:repo/dependabot/alerts --paginate -f state=open \
  --jq '[.[] | .security_advisory.severity] | group_by(.) | map({(.[0]): length}) | add'

# Count by ecosystem
gh api repos/:owner/:repo/dependabot/alerts --paginate -f state=open \
  --jq '[.[] | .dependency.package.ecosystem] | group_by(.) | map({(.[0]): length}) | add'
```

## Enable/Disable Dependabot

```bash
# Check if Dependabot alerts are enabled
gh api repos/:owner/:repo/vulnerability-alerts --silent && echo "enabled" || echo "disabled"

# Enable Dependabot alerts
gh api -X PUT repos/:owner/:repo/vulnerability-alerts

# Disable Dependabot alerts
gh api -X DELETE repos/:owner/:repo/vulnerability-alerts
```

## Dependabot Secrets

Separate from repo secrets — used by Dependabot for private registry access.

```bash
# List Dependabot secrets (names only, values are encrypted)
gh api repos/:owner/:repo/dependabot/secrets --jq '.secrets[] | .name'
```

Creating Dependabot secrets requires encrypting with the repo's public key — same process as `gh secret set` but targeting a different API endpoint. Easier to use `gh secret set --app dependabot` if available in your gh version.
