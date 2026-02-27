# Repository Traffic & Analytics

`gh` has no built-in traffic commands. All traffic data is REST-only.

**Important**: GitHub only retains 14 days of traffic data. Export regularly to avoid losing history.

## Views

```bash
# Total and unique views per day (last 14 days)
gh api repos/:owner/:repo/traffic/views --jq '.views[] | [.timestamp[:10], .count, .uniques] | @tsv'

# Summary totals
gh api repos/:owner/:repo/traffic/views --jq '"Total: \(.count) views, \(.uniques) unique"'
```

## Clones

```bash
# Total and unique clones per day (last 14 days)
gh api repos/:owner/:repo/traffic/clones --jq '.clones[] | [.timestamp[:10], .count, .uniques] | @tsv'

# Summary totals
gh api repos/:owner/:repo/traffic/clones --jq '"Total: \(.count) clones, \(.uniques) unique"'
```

## Top Referrers

Where traffic comes from (top 10):

```bash
gh api repos/:owner/:repo/traffic/popular/referrers --jq '.[] | [.referrer, .count, .uniques] | @tsv'
```

## Popular Content

Most visited paths (top 10):

```bash
gh api repos/:owner/:repo/traffic/popular/paths --jq '.[] | [.path, .count, .uniques] | @tsv'
```

## Export All Traffic Data

Dump everything to JSON for archival:

```bash
for endpoint in views clones popular/referrers popular/paths; do
  gh api repos/:owner/:repo/traffic/$endpoint > "traffic-$(echo $endpoint | tr '/' '-')-$(date +%Y-%m-%d).json"
done
```

## Community Metrics

Not part of the traffic API but related:

```bash
# Community profile (code of conduct, contributing guide, etc.)
gh api repos/:owner/:repo/community/profile --jq '{health_percentage, files: [.files | to_entries[] | select(.value != null) | .key]}'
```
