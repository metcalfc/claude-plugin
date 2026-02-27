# PR Review Threads — Resolve Conversations

No built-in `gh` command to resolve (or unresolve) PR review conversations. Requires the GraphQL API.

## Resolve a Review Thread

```bash
# Get review thread IDs for a PR
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 1) {
              nodes {
                body
                author { login }
              }
            }
          }
        }
      }
    }
  }
' -f owner=':owner' -f repo=':repo' -F pr=PR_NUMBER \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | {id, comment: .comments.nodes[0].body[:80], author: .comments.nodes[0].author.login}'
```

Note: `:owner` and `:repo` placeholders don't work in GraphQL variables. Obtain them first:

```bash
owner=$(gh repo view --json owner --jq '.owner.login')
repo=$(gh repo view --json name --jq '.name')
```

Then use `$owner` and `$repo` in the `-f` flags.

## Resolve a Single Thread

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId=THREAD_NODE_ID
```

## Resolve All Unresolved Threads on a PR

```bash
owner=$(gh repo view --json owner --jq '.owner.login')
repo=$(gh repo view --json name --jq '.name')

# Get all unresolved thread IDs
thread_ids=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
          }
        }
      }
    }
  }
' -f owner="$owner" -f repo="$repo" -F pr=PR_NUMBER \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | .id')

# Resolve each thread
for id in $thread_ids; do
  gh api graphql -f query='
    mutation($threadId: ID!) {
      resolveReviewThread(input: {threadId: $threadId}) {
        thread { isResolved }
      }
    }
  ' -f threadId="$id"
  echo "Resolved: $id"
done
```

## Unresolve a Thread

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    unresolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId=THREAD_NODE_ID
```

## Reply to a Review Thread

Replying to a review thread via the REST API (doesn't require GraphQL):

```bash
# Get review comments on a PR
gh api repos/:owner/:repo/pulls/PR_NUMBER/comments \
  --jq '.[] | [.id, .in_reply_to_id // "top-level", .user.login, .body[:60]] | @tsv'

# Reply to a review comment (creates a reply in the same thread)
gh api -X POST repos/:owner/:repo/pulls/PR_NUMBER/comments \
  -F in_reply_to=COMMENT_ID \
  -f body="Fixed in the latest commit."
```

## List Threads with Context

Show unresolved threads with the file path and line number:

```bash
owner=$(gh repo view --json owner --jq '.owner.login')
repo=$(gh repo view --json name --jq '.name')

gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            path
            line
            comments(first: 1) {
              nodes {
                body
                author { login }
              }
            }
          }
        }
      }
    }
  }
' -f owner="$owner" -f repo="$repo" -F pr=PR_NUMBER \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | "\(.path):\(.line) — @\(.comments.nodes[0].author.login): \(.comments.nodes[0].body[:80])"'
```
