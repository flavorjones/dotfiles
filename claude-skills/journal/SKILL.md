---
name: journal
description: Add an entry about finished work to Mike's Basecamp "My Notes" scratchpad, filed under its topic. Use when Mike says "journal this work", "make a journal entry", "add this to my notes", or similar.
---

# journal

Add one entry about a piece of work to Mike's Basecamp "My Notes". The note is a private scratchpad
that accumulates entries until he posts them to his team, so it has no dates: only topics.

## The note

- It is the personal notebook note: `basecamp notes show` and `basecamp notes set`. There is one per
  person and no id to pass. Web URL: <https://app.basecamp.com/2914079/my/navigation/notes>.
- Read and write it as Mike, with the default profile: `unset BASECAMP_PROFILE`. This is the one
  exception to the rule that agents write to Basecamp as `fetchbot`, which gets `not_found` here.
- A Basecamp document Mike links is a style reference. Never write to it.

## Layout

- One `###` heading per topic, such as "HotCell", "On Call", "Security" or "Odds and ends".
- No date headings.
- A new entry goes at the **bottom** of its topic's list, so each topic reads oldest to newest.
- If the topic has no heading yet, add one at the end of the note.

## Entry style

- Start with the linked title of the card, PR or issue, followed by a period.
- Follow with one to three short, factual sentences: what shipped (PR links as `repo#N`), numbers
  when they exist, and what is still open.
- Plain voice, past tense. Don't narrate process.

```markdown
### HotCell

- [hotcell#39: ship the two health probes instead of leaving them as examples](https://github.com/basecamp/hotcell/pull/39). Took over Donal's PR: rebased it, made `hot_cell/health_operations` loadable on its own, and pointed the README and CHANGELOG at the shipped probes. Merged. HEY can delete its copy once a release ships them. Opened [hotcell#66](https://github.com/basecamp/hotcell/issues/66) for a devcell check that flakes on ruby head.
```

## Steps

1. Save the current note: `basecamp notes show --json --jq '.data.content' > ./tmp/notes-before.html`.
   Don't use `--md`; it flattens the content onto one line.
2. Write the whole note as markdown to `./tmp/notes.md`: every existing heading, bullet, link and
   code span, plus the new entry. `notes set` replaces the note; anything left out is gone.
3. `basecamp notes set --file ./tmp/notes.md --json`. The CLI converts markdown to HTML.
4. Read it back with `basecamp notes show --json --jq '.data.content'` and run the checks below.
5. Tell Mike which topic got the entry. On a card, say it in the card reply.

## Checks

| # | Check | Pass | If fail |
|---|-------|------|---------|
| 1 | Entry count: `grep -o '<li' <file> \| wc -l`, before and after | After is before + 1 | Restore the lost entries from `./tmp/notes-before.html` and set again |
| 2 | Headings, before and after: `grep -o '<h3[^>]*>[^<]*' <file>` | Same list, plus the new topic if one was added | Restore from `./tmp/notes-before.html` |
| 3 | The new entry | Last item under its topic's heading | Move it and set again |

## Failure modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| `not_found` on the note or a linked document | `BASECAMP_PROFILE=fetchbot` still exported | `unset BASECAMP_PROFILE` |
| Earlier entries disappeared | `notes set` replaces the whole note | Rebuild from `./tmp/notes-before.html` |
| Wrote to the linked document | Took the style reference for the target | The target is always `basecamp notes` |
