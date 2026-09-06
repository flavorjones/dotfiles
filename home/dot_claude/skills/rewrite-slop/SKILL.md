---
name: rewrite-slop
description: Tighten prose that already exists by looping until it converges. Use when asked to rewrite, tighten, de-slop, or cut down a document, message, comment, or draft.
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

**Specificity.** The number, the version, the name. "Several" is not a summary of "seventeen."

**Antecedents.** "It" and "this" get vaguer as everything around them goes away.

**Steps as steps.** Two instructions merged into one sentence are easier to skip and harder to
follow.

**Examples.** One is usually worth the explanation it replaces.

**Voice**, when the author is a person. Terse is not flat.

The test: can the reader still do the thing the document is for?

## Scope

Prose, including code comments. Not code — leave identifiers, logic, and structure alone.

Edit files in place. For text in the conversation, show only the final version.
