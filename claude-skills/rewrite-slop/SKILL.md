---
name: rewrite-slop
description: Tighten prose that already exists by looping until it converges, then prove it reads clearly to a cold reader. Use when asked to rewrite, tighten, de-slop, or cut down a document, message, comment, or draft, and before posting any explanation to Mike.
---

# rewrite-slop

Ask one question of what was written, and keep asking until the answer stops changing anything:

> **Is this as simple and concise as possible without sacrificing clarity?**

Converged means a full pass changes nothing.

## What has to survive

Concision is measured against what the reader needs, not against word count. A shorter document
that lost any of this is a worse document.

**Verbatim strings.** Error messages, log lines, stack frames, commands, paths, versions,
identifiers — exactly as they appeared, punctuation and all. Someone hits that error in two years,
searches for the string, and has to land here. A paraphrased error message is unfindable.

**Specificity.** The measurement, the version, the name. "Several" is not a summary of "seventeen" — but prose never announces how many items follow ("there are two things"); a numbered list does the counting.

**Antecedents.** "It" and "this" get vaguer as everything around them goes away.

**Steps as steps.** Two instructions merged into one sentence are easier to skip and harder to
follow.

**Examples.** One is usually worth the explanation it replaces.

**Voice**, when the author is a person. Terse is not flat.

The test: can the reader still do the thing the document is for?

## Cold read

You can't judge your own clarity: you know what every term means. After the loop converges, and
before the text goes to a person, spawn a fresh subagent. Give it only the text, with no card, code,
or context, and ask it:

1. Explain this back in plain words.
2. List every term you had to guess at.

If the explain-back is wrong, reuses a term from the text instead of explaining it, or the list is
not empty, rewrite and run the loop and the cold read again. When you post, report the result in one
line: "Cold read: clean on round N."

## Scope

Prose, including code comments. Not code — leave identifiers, logic, and structure alone.

Edit files in place. For text in the conversation, show only the final version.
