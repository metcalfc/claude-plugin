# Milestones

`gh` has no built-in milestone subcommand. Use `gh api` with the milestones endpoint.

## List Milestones

```bash
# All open milestones
gh api repos/:owner/:repo/milestones --jq '.[] | [.number, .title, .state, .open_issues, .closed_issues, .due_on] | @tsv'

# All milestones (including closed)
gh api repos/:owner/:repo/milestones -f state=all --jq '.[] | [.number, .title, .state] | @tsv'

# Sorted by due date
gh api repos/:owner/:repo/milestones -f sort=due_on -f direction=asc --jq '.[] | [.title, .due_on] | @tsv'
```

## Create a Milestone

```bash
# Basic
gh api repos/:owner/:repo/milestones -f title="v1.0"

# With due date and description
gh api repos/:owner/:repo/milestones \
  -f title="v1.0" \
  -f description="First stable release" \
  -f due_on="2026-03-01T00:00:00Z" \
  -f state=open
```

## Update a Milestone

```bash
# Close a milestone (by milestone number)
gh api -X PATCH repos/:owner/:repo/milestones/1 -f state=closed

# Change title
gh api -X PATCH repos/:owner/:repo/milestones/1 -f title="v1.0-rc1"

# Update due date
gh api -X PATCH repos/:owner/:repo/milestones/1 -f due_on="2026-04-01T00:00:00Z"
```

## Delete a Milestone

```bash
gh api -X DELETE repos/:owner/:repo/milestones/1
```

## Assign an Issue to a Milestone

```bash
# Set milestone on issue #42 to milestone number 1
gh api -X PATCH repos/:owner/:repo/issues/42 -F milestone=1

# Remove milestone from an issue
gh api -X PATCH repos/:owner/:repo/issues/42 -F milestone=null
```

## Get Milestone Progress

```bash
# Show completion percentage
gh api repos/:owner/:repo/milestones --jq '.[] | "\(.title): \(.closed_issues)/\(.open_issues + .closed_issues) issues closed"'
```

## List Issues in a Milestone

```bash
# All issues in milestone number 1
gh issue list --milestone "Milestone Title" --state all
```

Note: `gh issue list --milestone` does work with the milestone _title_ (not number). This is one of the few milestone operations that has built-in support.
