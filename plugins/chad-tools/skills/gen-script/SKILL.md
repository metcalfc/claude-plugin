---
name: gen-script
description: Generate a standalone utility script (bash, python, or JS/TS).
  Use when asked to write a quick script for a one-off task. Saves to a
  sensible location and makes it executable.
argument-hint: <language> <what it does>
---

When generating a script:

1. Determine language from the request (default to bash)
2. Write a complete, runnable script — not a fragment
3. Language-specific requirements:
   - **bash**: `#!/usr/bin/env bash` + `set -euo pipefail`
   - **python**: `#!/usr/bin/env python3`, argparse if it takes args, type hints
   - **js/ts**: Modern ESM syntax, shebang for node if standalone
4. Save to the current directory unless specified otherwise
5. Make it executable: `chmod +x <file>`
6. If this seems like a recurring pattern or you've seen a similar request
   in this session, suggest: "This looks like something worth keeping.
   Want me to /crystallize it as a skill?"
