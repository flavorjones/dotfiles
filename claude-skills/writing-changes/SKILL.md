---
name: writing-changes
description: Mike's required conventions for writing git commit messages and pull request descriptions. Use before drafting or revising ANY commit message or PR description, and before committing or opening a PR.
---

# writing-changes

How Mike wants commit messages and pull request descriptions written. Apply this from the first draft, not after he corrects you. He requires explicit approval of the draft before you commit or open the PR.

## Commit messages

Structure the body as two parts, in this order:

1. One paragraph describing the problem that was solved.
2. A separate paragraph describing how it was fixed.

Rules:

- Describe the problem, which is the old behavior, in the past tense. Describe the fix and the new behavior in the future tense.
- Do not describe how you reproduced or verified the problem. The message is about the problem and the fix, not the investigation.
- Do not explain why or how the code produced the problem. The code-level mechanism is not relevant to the message.
- Use precise language. State exactly what happened. Avoid vague verbs like "got it executed".
- Reference an external report with `ref: <url>`, not "Reported at".
- When the change closes a GitHub issue, put `[Fix #issue-number]` in the message.

## Pull request descriptions

Read `@references/guide.md` for the PR template-matching and voice conventions, worked examples, the eval checks, and the failure-modes table. Do that before drafting a PR description.

## Prose

Also follow the general prose guidelines in `~/CLAUDE.md`: complete sentences, no em-dashes, no fake tone, treat the reader as an expert, and hyperlink external artifacts.
