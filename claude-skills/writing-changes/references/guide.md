# writing-changes guide

The conventions for commit messages live in `../SKILL.md`. This guide covers pull request descriptions, worked examples, eval checks, and failure modes.

## Commit message shape (recap)

Problem paragraph (past tense), then a separate fix paragraph (future tense). No reproduction or verification detail. No code-level cause. Precise language. `ref: <url>` for external reports.

## Pull request descriptions

Before drafting a PR description, read the repository's PR template and a few of Mike's own merged PRs to match structure and voice, for example:

    gh search prs --repo OWNER/REPO --author flavorjones --state merged

Follow the template's section headers exactly. For Rails these are `### Motivation / Background`, `### Detail`, `### Additional information`, and `### Checklist`, and you fill in the checklist.

Style Mike uses, learned from his Rails PRs (in addition to the general prose guidelines in `~/CLAUDE.md`):

- **Motivation / Background** traces the concrete code path and names the actual method and file where the problem lives. Point out inconsistencies with existing behavior. Show the offending line as an indented code block when it clarifies.
- **Detail** states what the change does, then gives a concrete before/after example with the actual rendered output ("previously produced X. Now it produces Y.").
- **Additional information** notes related context, defense-in-depth reasoning, and references to prior work by commit SHA.
- When the PR fixes an issue, put `[Fix #issue-number]` in the commit message.

When a commit message should double as the PR description, write the PR description first, then use the subject line plus the prose sections, dropping the checklist, as the commit message body.

## Exemplar

A commit message that graduated after several rounds of Mike's feedback. Note the problem-first structure, the past-tense problem paragraph, the future-tense fix paragraph, the absence of any reproduction detail, and the `ref:` line.

    Fix binary-planting in the Windows installer legacy cleanup

    The Windows installer could be tricked into executing an attacker-supplied
    binary in place of a trusted system tool. During legacy-install cleanup, an
    attacker who planted a taskkill.exe next to the installer (for example in
    Downloads via a drive-by download) caused the installer to launch it instead
    of C:\Windows\System32\taskkill.exe, executing the attacker's code with the
    privileges of whoever ran the installer.

    Qualifying both taskkill calls in build/installer.nsh to "$SYSDIR\taskkill.exe"
    will make the installer launch the real system tool by absolute path, ignoring
    any planted executable.

    ref: https://hackerone.com/reports/3856459

## Eval checks

Write the draft to a file and run these before showing it to Mike.

| # | Check | Command | Pass | If fail |
|---|-------|---------|------|---------|
| 1 | No "Reported at" | `grep -qi "reported at" MSG` | no match | Change to `ref: <url>` |
| 2 | No reproduction or verification narrative | `grep -niE "reproduc|verif|i (tested\|ran)\|exit=[0-9]" MSG` | no match | Delete the investigation detail |
| 3 | Subject then blank line | `sed -n '2p' MSG` | empty line | Add a blank line after the subject |
| 4 | Body is more than one paragraph | `grep -c '^$' MSG` | at least 2 | Split into a problem paragraph and a fix paragraph |

## Failure modes

Each row is a real correction Mike gave.

| Symptom | Cause | Fix |
|---------|-------|-----|
| Message opens by explaining the offending code | Described the mechanism before the problem | Lead with the problem and its impact, in the past tense |
| Message includes how the bug was reproduced | Confused the fix with its verification | Cut every reproduction and verification detail |
| Vague verb such as "got it executed" | Imprecise language | State exactly what happened |
| "Reported at <url>" | Wrong reference keyword | Use `ref: <url>` |
| Problem and fix written in the same tense | Skipped the tense rule | Problem in past tense, fix and new behavior in future tense |
| Problem and fix run together in one paragraph | Skipped the structure rule | One paragraph for the problem, a separate paragraph for the fix |
