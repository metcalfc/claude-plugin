# Notifications

`gh` has no built-in notification management. Use `gh api` with the notifications endpoint.

## List Notifications

```bash
# All unread notifications
gh api notifications --jq '.[] | [.id, .reason, .subject.type, .subject.title, .repository.full_name] | @tsv'

# Filter by participating (mentioned, assigned, review requested)
gh api notifications -f participating=true --jq '.[] | [.id, .reason, .subject.title] | @tsv'

# Filter by repo
gh api notifications -f repository=:owner/:repo --jq '.[] | [.id, .subject.title] | @tsv'

# Include read notifications
gh api notifications -f all=true --jq '.[] | [.id, .unread, .subject.title] | @tsv'

# Since a specific date
gh api notifications -f since="2026-02-01T00:00:00Z" --jq '.[] | [.subject.title] | @tsv'
```

## Mark as Read

```bash
# Mark all notifications as read
gh api -X PUT notifications -f last_read_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)" -F read=true

# Mark a single thread as read
gh api -X PATCH notifications/threads/THREAD_ID

# Mark all notifications in a repo as read
gh api -X PUT repos/:owner/:repo/notifications -f last_read_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

## Mark Thread as Done

```bash
gh api -X DELETE notifications/threads/THREAD_ID
```

## Subscribe/Unsubscribe

```bash
# Subscribe to a thread
gh api -X PUT notifications/threads/THREAD_ID/subscription -F subscribed=true

# Unsubscribe (stop watching but keep existing notifications)
gh api -X PUT notifications/threads/THREAD_ID/subscription -F subscribed=false -F ignored=false

# Mute/ignore a thread entirely
gh api -X PUT notifications/threads/THREAD_ID/subscription -F subscribed=false -F ignored=true

# Check subscription status
gh api notifications/threads/THREAD_ID/subscription
```

## Watch/Unwatch a Repository

```bash
# Watch a repo (all activity)
gh api -X PUT repos/:owner/:repo/subscription -F subscribed=true

# Watch custom (issues and pulls only — not available via API, only web UI)
# The API only supports subscribed=true (all) or ignored=true (none)

# Unwatch a repo
gh api -X DELETE repos/:owner/:repo/subscription

# Check watch status
gh api repos/:owner/:repo/subscription
```

## Get Notification Details

Notification subjects don't include the direct URL. Extract it from the API URL:

```bash
# Get the linked issue/PR/release for a notification
gh api notifications --jq '.[] | {title: .subject.title, type: .subject.type, api_url: .subject.url}'

# Then fetch the actual item
gh api <api_url> --jq '.html_url'
```
