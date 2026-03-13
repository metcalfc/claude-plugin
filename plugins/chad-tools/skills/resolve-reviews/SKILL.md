---
name: resolve-reviews
description: Reply to GitHub PR review comments explaining how each was
  addressed, then resolve the conversations. Use when the user says
  "address review feedback", "resolve conversations", "reply to review
  comments", or after pushing fixes for PR review findings.
model: haiku
---

Reply to and resolve PR review comments on the current branch's PR.

1. Identify the PR number:
   `gh pr view --json number --jq '.number'`

2. Get all review comments with their IDs, file paths, and bodies:
   `gh api repos/{owner}/{repo}/pulls/{pr}/comments --jq '.[] | {id: .id, path: .path, line: .line, body: .body, author: .user.login}'`

3. Get the repo owner and name:
   `gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'`

4. For each comment, determine its disposition:
   - Read the recent git log to find which commits address the finding
   - Check the actual code to verify the fix is in place
   - **Fixed**: identify the commit that addresses it. Reply: "Fixed in {sha}. {brief explanation}"
   - **Rejected**: the finding doesn't apply. Reply: "Not applicable — {reason}."
   - **Issue filed**: the fix warrants its own PR. Reply: "Tracked in #{issue}. {why separate}"

   There is no "acknowledged" or "will look at later" disposition. Every comment must be
   either fixed, rejected with a reason, or tracked in an issue. If a comment is not yet
   addressed and it's valid, fix it before resolving the thread.

5. Reply to each comment via the API:
   `gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies -f body="..."`
   - Keep replies concise: one line stating the fix commit + what was done
   - Example: "Fixed in abc1234. Added `flock(LOCK_EX|LOCK_NB)` to eliminate the TOCTOU race."

6. Resolve all unresolved review threads:
   - Get thread IDs:
     ```
     gh api graphql -f query='{
       repository(owner: "{owner}", name: "{repo}") {
         pullRequest(number: {pr}) {
           reviewThreads(first: 50) {
             nodes { id isResolved comments(first: 1) { nodes { body } } }
           }
         }
       }
     }' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | .id'
     ```
   - Resolve each thread:
     `gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "{id}"}) { thread { isResolved } } }'`

7. Summarize what was done:
   - How many comments replied to
   - How many threads resolved
   - Any comments that could NOT be addressed (still open issues)
