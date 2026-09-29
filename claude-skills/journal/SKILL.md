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

- One `<h3>` heading per topic, such as "HotCell", "On Call", "Security" or "Odds and ends".
- No date headings.
- A new entry goes at the **bottom** of its topic's list, so each topic reads oldest to newest.
- If the topic has no heading yet, add one at the end of the note.

## Entry style

- Start with the linked title of the card, PR or issue, followed by a period.
- Follow with one to three short, factual sentences: what shipped (PR links as `repo#N`), numbers
  when they exist, and what is still open.
- Plain voice, past tense. Don't narrate process.

The note stores HTML. An entry is one `<li>` in its topic's `<ul>`:

```html
<h3 dir="auto">HotCell</h3>
<p dir="auto"><br></p>
<ul dir="auto">
<li>
<a href="https://github.com/basecamp/hotcell/pull/39" target="_blank" rel="noreferrer">hotcell#39: ship the two health probes instead of leaving them as examples</a>. Took over Donal's PR: rebased it, made <code>hot_cell/health_operations</code> loadable on its own, and pointed the README and CHANGELOG at the shipped probes. Merged. HEY can delete its copy once a release ships them. Opened <a href="https://github.com/basecamp/hotcell/issues/66" target="_blank" rel="noreferrer">hotcell#66</a> for a devcell check that flakes on ruby head.</li>
</ul>
```

## Steps

1. Save the current note: `basecamp notes show --json --jq '.data.content' > ./tmp/notes-before.html`.
   Don't use `--md`; it flattens the content onto one line.
2. Copy `./tmp/notes-before.html` to `./tmp/notes.html` and insert the new entry as a `<li>` at the
   end of its topic's `<ul>`. For a new topic, append an `<h3>`, a `<p dir="auto"><br></p>` spacer
   and a `<ul>` holding the entry at the end of the note. Change nothing else: `notes set` replaces
   the note, so the file must carry every existing byte.
3. `basecamp notes set --file ./tmp/notes.html --json`. The CLI stores HTML as is. Never write the
   note as markdown: the note's `<p><br></p>` spacers make the CLI treat the file as HTML, so the
   markdown is stored unconverted.
4. Read it back with `basecamp notes show --json --jq '.data.content' > ./tmp/notes-after.html` and
   run the checks below.
5. Tell Mike which topic got the entry. On a card, say it in the card reply.

## Checks

| # | Check | Pass | If fail |
|---|-------|------|---------|
| 1 | `diff ./tmp/notes-before.html ./tmp/notes-after.html` | Only the new entry's lines (and the new topic's heading, spacer and list, if one was added) | Set `./tmp/notes-before.html` again to restore the note, then redo step 2 |
| 2 | The new entry | Last item under its topic's heading | Move it and set again |

## Failure modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| `not_found` on the note or a linked document | `BASECAMP_PROFILE=fetchbot` still exported | `unset BASECAMP_PROFILE` |
| Earlier entries disappeared | `notes set` replaces the whole note | Set `./tmp/notes-before.html` again |
| The note shows literal `###` and `- [` text | The note was written as markdown | Set `./tmp/notes-before.html` again, then follow step 2 |
| Wrote to the linked document | Took the style reference for the target | The target is always `basecamp notes` |
