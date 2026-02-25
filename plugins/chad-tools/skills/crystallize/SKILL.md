---
name: crystallize
description: Create a new Claude Code skill from a repeated pattern or
  workflow. Use when you notice a recurring task that should be codified,
  or when the user says "make this a skill" or "save this pattern".
argument-hint: <skill-name> <description>
---

To crystallize a new skill:

1. Determine what the skill should do (ask if unclear)
2. Decide scope:
   - **Global** (chad-tools plugin): ~/src/github.com/metcalfc/claude-plugin/skills/
   - **Project-specific**: .claude/skills/ in the current repo
3. Create the directory and SKILL.md:
   ```
   <scope>/skills/<skill-name>/SKILL.md
   ```
4. Write proper YAML frontmatter:
   - name: kebab-case
   - description: 1-2 sentences with trigger phrases
   - argument-hint: if it takes arguments
5. Write clear, numbered instructions in the body
6. If it needs supporting files (templates, scripts), put them in the
   same skill directory
7. For global skills: remind to commit to claude-plugin repo and note
   that other machines will get it on next plugin update
8. For project skills: remind to commit to the project repo
