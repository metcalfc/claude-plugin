# GitHub Pages Configuration

`gh` has no built-in Pages management. Use `gh api` with the Pages endpoint.

## Check Pages Status

```bash
# Get current Pages config
gh api repos/:owner/:repo/pages --jq '{status, url, cname, https_enforced, source: .source}'

# Check if Pages is enabled (returns 404 if not)
gh api repos/:owner/:repo/pages --silent && echo "enabled" || echo "not enabled"
```

## Enable Pages

```bash
# From a branch and folder
gh api -X POST repos/:owner/:repo/pages --input - <<'EOF'
{
  "source": {
    "branch": "main",
    "path": "/"
  }
}
EOF

# From docs/ folder
gh api -X POST repos/:owner/:repo/pages --input - <<'EOF'
{
  "source": {
    "branch": "main",
    "path": "/docs"
  }
}
EOF

# Using GitHub Actions as source (no branch needed)
gh api -X POST repos/:owner/:repo/pages --input - <<'EOF'
{
  "build_type": "workflow"
}
EOF
```

## Update Pages Source

```bash
# Switch to a different branch
gh api -X PUT repos/:owner/:repo/pages --input - <<'EOF'
{
  "source": {
    "branch": "gh-pages",
    "path": "/"
  }
}
EOF
```

## Custom Domain

```bash
# Set custom domain
gh api -X PUT repos/:owner/:repo/pages -f cname="docs.example.com"

# Remove custom domain
gh api -X PUT repos/:owner/:repo/pages -f cname=""

# Enforce HTTPS
gh api -X PUT repos/:owner/:repo/pages -F https_enforced=true
```

## Disable Pages

```bash
gh api -X DELETE repos/:owner/:repo/pages
```

## Pages Build Status

```bash
# List recent builds
gh api repos/:owner/:repo/pages/builds --jq '.[] | [.status, .created_at, .error.message // "none"] | @tsv'

# Get latest build
gh api repos/:owner/:repo/pages/builds/latest --jq '{status, created_at, error: .error.message}'

# Trigger a build (only for branch-based, not Actions)
gh api -X POST repos/:owner/:repo/pages/builds
```

## Pages Deployment Status (Actions-based)

For repos using GitHub Actions for Pages deployment:

```bash
# List Pages deployments
gh api repos/:owner/:repo/pages/deployments --jq '.[] | [.id, .status, .environment] | @tsv'
```
