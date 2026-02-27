# Collaborators & Access Management

`gh` has no built-in collaborator management. Use `gh api` for all collaborator operations.

## List Collaborators

```bash
# All collaborators with permissions
gh api repos/:owner/:repo/collaborators --jq '.[] | [.login, .role_name, .permissions.admin] | @tsv'

# Only outside collaborators (non-org members)
gh api repos/:owner/:repo/collaborators -f affiliation=outside --jq '.[] | [.login, .role_name] | @tsv'

# Only direct collaborators (not via team)
gh api repos/:owner/:repo/collaborators -f affiliation=direct --jq '.[] | [.login, .role_name] | @tsv'
```

## Add a Collaborator

Permission levels: `pull` (read), `triage`, `push` (write), `maintain`, `admin`.

```bash
# Add with write access
gh api -X PUT repos/:owner/:repo/collaborators/USERNAME -f permission=push

# Add with read-only access
gh api -X PUT repos/:owner/:repo/collaborators/USERNAME -f permission=pull

# Add with admin access
gh api -X PUT repos/:owner/:repo/collaborators/USERNAME -f permission=admin
```

Note: this sends an invitation. The user must accept it before they appear as a collaborator.

## Remove a Collaborator

```bash
gh api -X DELETE repos/:owner/:repo/collaborators/USERNAME
```

## Check if Someone is a Collaborator

```bash
# Returns 204 if collaborator, 404 if not
gh api repos/:owner/:repo/collaborators/USERNAME --silent && echo "yes" || echo "no"
```

## Pending Invitations

```bash
# List pending invitations
gh api repos/:owner/:repo/invitations --jq '.[] | [.id, .invitee.login, .permissions, .created_at] | @tsv'

# Cancel an invitation
gh api -X DELETE repos/:owner/:repo/invitations/INVITATION_ID
```

## Team Access (Org Repos)

```bash
# List teams with access to a repo
gh api repos/:owner/:repo/teams --jq '.[] | [.slug, .permission] | @tsv'

# Grant a team access to a repo
gh api -X PUT orgs/ORG/teams/TEAM_SLUG/repos/:owner/:repo -f permission=push

# Remove team access
gh api -X DELETE orgs/ORG/teams/TEAM_SLUG/repos/:owner/:repo
```

## Bulk Operations

Add multiple collaborators in a loop:

```bash
for user in alice bob carol; do
  gh api -X PUT repos/:owner/:repo/collaborators/$user -f permission=push
done
```
