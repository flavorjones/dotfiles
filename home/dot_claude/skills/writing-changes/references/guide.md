# writing-changes guide

Commit message conventions live in `../SKILL.md`. This guide covers pull request descriptions,
the eval checks, and the failure modes.

## Pull request descriptions

Before drafting, read the repository's PR template and a few of Mike's own merged PRs to match
structure and voice:

    gh search prs --repo OWNER/REPO --author flavorjones --state merged

Follow the template's section headers exactly. For Rails these are `### Motivation / Background`,
`### Detail`, `### Additional information`, and `### Checklist`, and you fill in the checklist.

Style Mike uses, learned from his Rails PRs (on top of the prose guidelines in `~/CLAUDE.md`):

- **Motivation / Background** traces the concrete code path and names the actual method and file
  where the problem lives. Point out inconsistencies with existing behavior. Show the offending
  line as an indented code block when it clarifies.
- **Detail** states what the change does, then gives a concrete before/after with the actual
  rendered output ("previously produced X. Now it produces Y.").
- **Additional information** notes related context, defense-in-depth reasoning, and references to
  prior work by commit SHA.
- When the PR fixes an issue, put `[Fix #issue-number]` in the commit message.

A PR description can be long where a commit message cannot: this is where the mechanism, the
alternatives, and the before/after live. When a squash-merge will make the PR body the commit
body, that is fine — the length rule in `SKILL.md` is for hand-written commits.

## Eval checks

Write the draft to a file and run these before showing it to Mike.

| # | Check | Command | Pass | If fail |
|---|-------|---------|------|---------|
| 1 | Subject length | `sed -n '1p' MSG \| wc -c` | ≤ 72 | Cut the subject; detail goes in the body |
| 2 | Subject then blank line | `sed -n '2p' MSG` | empty, or no line 2 | Add a blank line after the subject |
| 3 | Body length | `sed '1,2d' MSG \| grep -c .` | ≤ 8, or the body carries a benchmark, a mechanism the fix depends on, or a migration note | Cut, unless it earns its length — see "When longer is right" in SKILL.md |
| 4 | No reproduction or verification narrative | `grep -niE "reproduc\|verif\|i (tested\|ran)\|exit=[0-9]" MSG` | no match | Delete the investigation detail |
| 5 | No "Reported at" | `grep -qi "reported at" MSG` | no match | Change to `ref: <url>` |
| 6 | Fix is not in future tense | `grep -nE "^(The|This|It|.*) will " MSG` | no match | Imperative: "Raise", "Add", "Restrict" |

## Failure modes

Each row is a real correction Mike gave.

| Symptom | Cause | Fix |
|---------|-------|-----|
| Body runs 20–30 lines, restating design rationale | Put the "why" in the commit instead of the doc or comment the commit adds | One to four sentences. The message points at where the rationale lives |
| Long body that answers no question the diff raises | Mistook length for thoroughness | Length is for a benchmark, a non-obvious mechanism, or a migration cost — nothing else |
| Perf commit with no numbers | Skipped the benchmark | Before/after, the command, the environment |
| Two paragraphs written because "the structure says two" | Treated a shape for long messages as a floor | Problem and fix are often one sentence each; a one-line body is fine |
| Message opens by explaining the offending code | Described the mechanism before the problem | Lead with the problem and its impact |
| Message includes how the bug was reproduced | Confused the fix with its verification | Cut every reproduction and verification detail |
| Fix written in the future tense ("will make the installer…") | Followed an old rule | Imperative, as Mike's own commits do |
| Vague verb such as "got it executed" | Imprecise language | State exactly what happened |
| "Reported at <url>" | Wrong reference keyword | Use `ref: <url>` |
