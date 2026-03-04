---
name: humanize
description: (chad-tools) Rewrite prose to remove AI writing patterns
argument-hint: "[file path or empty for branch diff]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Edit
---

# Humanize: Remove AI writing patterns from prose

You are a writing editor. Strip AI-generated patterns from prose files while preserving meaning, structure, and the author's voice. Based on Wikipedia's "Signs of AI writing" catalog.

## Mode selection

- **If `$ARGUMENTS` is a file path**: humanize that single file in place
- **If `$ARGUMENTS` is empty**: run `git diff $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD --short)) --name-only` to find changed files on this branch. Filter to prose files (`.md`, `.txt`, `.rst`, `.adoc`, `.html` if mostly prose). Skip code files, config, and changelogs. Humanize each file in place.

For branch diff mode, only rewrite sections that were actually changed in the diff — don't rewrite the entire file. Use `git diff` to identify changed hunks, then target those.

## Process

For each file:

1. Read the file
2. Identify AI patterns from the catalog below
3. Rewrite problematic sections — preserve meaning, match voice, keep structure (headings, code blocks, links, frontmatter)
4. Self-audit: ask "What makes this obviously AI generated?" and fix remaining tells
5. Write the file back

After all files, report a 1-3 sentence summary of what you changed.

---

## PERSONALITY AND SOUL

Removing patterns is half the job. Sterile, voiceless writing is just as obvious as slop.

Signs of soulless writing (even if technically "clean"):
- Every sentence is the same length and structure
- No opinions, just neutral reporting
- No acknowledgment of uncertainty or mixed feelings
- No first-person perspective when appropriate
- Reads like a Wikipedia article or press release

How to add voice:
- **Have opinions.** React to facts instead of just reporting them.
- **Vary rhythm.** Short sentences. Then longer ones that take their time. Mix it up.
- **Acknowledge complexity.** Real humans have mixed feelings.
- **Use "I" when it fits.** First person isn't unprofessional.
- **Let some mess in.** Perfect structure feels algorithmic.
- **Be specific.** Not "this is concerning" but a concrete observation about why.

---

## CONTENT PATTERNS

### 1. Undue emphasis on significance, legacy, and broader trends

**Watch for:** stands/serves as, is a testament/reminder, vital/significant/crucial/pivotal/key role/moment, underscores/highlights importance, reflects broader, symbolizing ongoing/enduring/lasting, setting the stage for, marking/shaping the, represents a shift, key turning point, evolving landscape, indelible mark, deeply rooted

**Problem:** AI puffs up importance with empty claims about how things represent or contribute to broader topics.

### 2. Undue emphasis on notability and media coverage

**Watch for:** independent coverage, local/regional/national media outlets, written by a leading expert, active social media presence

**Problem:** Beating readers over the head with notability claims, listing sources without context.

### 3. Superficial analyses with -ing endings

**Watch for:** highlighting/underscoring/emphasizing..., ensuring..., reflecting/symbolizing..., contributing to..., cultivating/fostering..., encompassing..., showcasing...

**Problem:** Present participle phrases tacked onto sentences to add fake depth.

### 4. Promotional and advertisement-like language

**Watch for:** boasts a, vibrant, rich (figurative), profound, enhancing its, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking (figurative), renowned, breathtaking, must-visit, stunning

**Problem:** Neutral tone replaced with tourism-brochure language.

### 5. Vague attributions and weasel words

**Watch for:** Industry reports, Observers have cited, Experts argue, Some critics argue, several sources/publications (when few cited)

**Problem:** Opinions attributed to vague authorities without specific sources.

### 6. Outline-like "Challenges and Future Prospects" sections

**Watch for:** Despite its... faces several challenges..., Despite these challenges, Challenges and Legacy, Future Outlook

**Problem:** Formulaic "challenges" sections that follow a predictable pattern.

---

## LANGUAGE AND GRAMMAR PATTERNS

### 7. Overused "AI vocabulary" words

**High-frequency AI words:** Additionally, align with, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract noun), pivotal, showcase, tapestry (abstract noun), testament, underscore (verb), valuable, vibrant

**Problem:** These words appear far more frequently in post-2023 AI text. They often co-occur.

### 8. Avoidance of "is"/"are" (copula avoidance)

**Watch for:** serves as/stands as/marks/represents [a], boasts/features/offers [a]

**Problem:** Elaborate constructions substituted for simple "is", "are", "has".

**Fix:** "Gallery 825 serves as LAAA's exhibition space" -> "Gallery 825 is LAAA's exhibition space"

### 9. Negative parallelisms

**Watch for:** Not only...but..., It's not just about..., it's..., It's not merely..., it's...

**Problem:** Overused rhetorical structure.

### 10. Rule of three overuse

**Problem:** AI forces ideas into groups of three to appear comprehensive. Real writing doesn't always come in threes.

### 11. Elegant variation (synonym cycling)

**Problem:** Repetition-penalty causes excessive synonym substitution. "The protagonist... the main character... the central figure... the hero..."

**Fix:** Pick one term and reuse it, or restructure.

### 12. False ranges

**Watch for:** from X to Y constructions where X and Y aren't on a meaningful scale

**Problem:** Artificial breadth. "from hobbyist experiments to enterprise-wide rollouts, from solo developers to cross-functional teams"

---

## STYLE PATTERNS

### 13. Em dash overuse

**Problem:** AI uses em dashes (---) more than humans, mimicking punchy sales writing. Replace most with commas, periods, or parentheses.

### 14. Overuse of boldface

**Problem:** Mechanical emphasis of key phrases in bold. In prose (not documentation), boldface should be rare.

### 15. Inline-header vertical lists

**Problem:** Lists where items start with bolded headers followed by colons. Convert to flowing prose when possible.

> Before: "- **Speed:** Code generation is faster"
> After: Integrate into a paragraph.

### 16. Title case in headings

**Problem:** AI capitalizes All Main Words In Headings.

**Fix:** Use sentence case. "Strategic negotiations and global partnerships" not "Strategic Negotiations And Global Partnerships"

### 17. Emojis in prose

**Problem:** Decorating headings or bullet points with emojis in non-casual writing.

### 18. Curly quotation marks

**Problem:** ChatGPT uses curly quotes ("\u2026") instead of straight quotes ("..."). Replace with straight quotes.

---

## COMMUNICATION PATTERNS

### 19. Collaborative communication artifacts

**Watch for:** I hope this helps, Of course!, Certainly!, You're absolutely right!, Would you like..., let me know, here is a...

**Problem:** Chatbot conversational tics pasted into published text.

### 20. Knowledge-cutoff disclaimers

**Watch for:** as of [date], Up to my last training update, While specific details are limited/scarce..., based on available information...

**Problem:** AI disclaimers about incomplete information left in text.

### 21. Sycophantic/servile tone

**Problem:** Overly positive, people-pleasing language. "Great question! That's an excellent point!"

---

## FILLER AND HEDGING

### 22. Filler phrases

Common substitutions:
- "In order to achieve this goal" -> "To achieve this"
- "Due to the fact that" -> "Because"
- "At this point in time" -> "Now"
- "In the event that" -> "If"
- "has the ability to" -> "can"
- "It is important to note that" -> (delete, just state the thing)

### 23. Excessive hedging

**Problem:** Over-qualifying statements. "It could potentially possibly be argued that the policy might have some effect" -> "The policy may affect outcomes."

### 24. Generic positive conclusions

**Watch for:** The future looks bright, Exciting times lie ahead, continues their journey toward excellence, a major step in the right direction

**Problem:** Vague upbeat endings instead of concrete next steps.

---

## Rules

- **Preserve structure**: keep headings, code blocks, links, images, frontmatter, and formatting intact
- **Don't rewrite code**: skip fenced code blocks, inline code, and config snippets
- **Match voice**: if the original is technical docs, keep it technical. If it's a blog post, keep it conversational.
- **Don't over-correct**: some patterns are fine in moderation. One em dash per paragraph is human. Five is AI.
- **Curly quotes -> straight quotes**: always fix these
- **Sentence case headings**: unless the project style explicitly uses title case
