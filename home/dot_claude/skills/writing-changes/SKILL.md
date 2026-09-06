---
name: writing-changes
description: Mike's conventions for git commit messages and pull request descriptions. Use before drafting or revising ANY commit message or PR description, and before committing or opening a PR.
---

# writing-changes

How Mike writes commit messages and PR descriptions. Apply from the first draft. He approves the
draft before you commit or open the PR.

## Commit messages

Short. Say what was wrong and what you did about it. Stop.

**Subject** — aim for ~50 characters, never past 72. Imperative mood, no trailing period. In OSS
repos with a convention, use the type prefix the history uses (`fix:`, `doc:`, `ci:`, `fix(CRuby):`).

**Body** — one to four sentences. Often none: if the subject says it, stop there. Two things, in
this order, and each is usually a sentence:

1. The problem — the old behaviour and its impact — in the past tense.
2. What the change does, in the imperative. "Raise TypeError before the unwrap." "Add a mark
   function for the document."

Point at things rather than restating them: a doc section the commit adds, a code comment, a test.
Rationale lives there, not here.

**Trailer** — `ref: <url>` for an external report or advisory. `[Fix #N]` when the change closes
an issue on that repo.

Do not include:

- how the bug was reproduced or the fix verified — that is investigation, not the change
- the code-level mechanism of the bug, unless it *is* the impact
- design discussion, alternatives considered, or history — those go in docs, comments, or the PR

### When longer is right

One to four sentences is the default, not a ceiling. Go longer when the change cannot be judged
without it, and put the extra material *after* the problem and fix so a reader can stop early:

- **A performance change carries its benchmark.** Before/after numbers, trimmed to the lines that
  make the comparison — not the whole tool dump. A perf claim without a number is a guess.
- **A non-obvious change carries its justification.** If a competent reader would ask "why not the
  simple thing?", answer it: the simpler approach tried and why it lost, or the mechanism that makes
  the obvious fix wrong. Mike's ReDoS fixes state the backtracking mechanism because without it
  the atomic groups look arbitrary.
- **A behaviour change with a migration cost names it.** What breaks for whom, and what to do.
- **A regression carries its history.** Which commit introduced it, which earlier decision made
  that possible, and who downstream it hit. A three-line fix to a two-year-old regression is
  mostly the story of how it hid; that story is what stops it hiding again.

Length earns its place by answering a question the diff raises. It does not earn its place by
restating the diff, narrating the investigation, or repeating a doc section the commit adds.

### Examples from Mike's history

Short, the common case:

```
fix: `Node#initialize_copy_with_args` rejects non-Node sources

Passing a non-Node (e.g. a `Namespace`) via `send` made the copy helper
unwrap an `xmlNs` as an `xmlNode`, causing a heap out-of-bounds read in
`noko_xml_document_pin_node` that crashes the process.

Raise TypeError before the unwrap. JRuby already does via `asXmlNode`.

ref: https://github.com/sparklemotion/nokogiri/security/advisories/GHSA-g9g8-vgvw-g3vf
```

```
doc: update CHANGELOG

[skip ci]
```

Long, and earning it — nokogiri `3f20dd91`. Nineteen lines, and each one answers a question the
diff raises: the benchmark trimmed to its comparison lines, the alternative that would have won
more and why it was not worth it, and a pointer to the discussion instead of a restatement of it.

```
ext: backport libxml2/gnome@bf5fcf6e for xmlXPathContext perf

See extended discussion at #3378

Benchmark comparing this commit against v1.17.x ("main"):

  Comparison:
           large: main:     3910.6 i/s
        large: patched:     3759.6 i/s - same-ish: difference falls within error

  Comparison:
        small: patched:   242901.7 i/s
           small: main:   127486.0 i/s - 1.91x  slower

I think we could get greater performance gains by re-using
XPathContext objects, but only at the cost of a significant amount of
additional complexity, since in order to properly support recursive
XPath evaluation, Nokogiri would have to push and pop "stack frames"
containing:

- internal state contextSize and proximityPosition
- registered namespaces
- registered variables
- function lookup handler

That feels like a lot of code for a small win. Comparatively, pulling
in this upstream patch is still a 2x speedup for zero additional complexity.
```

A regression carrying its history — nokogiri `dda0be29`. The diff is three lines. The message is
the story of how a skipped test hid the break for two years, with the commits and PRs by SHA and
the downstream project it hurt, and closes with an honest process note it does not commit to.

```
fix(jruby): XML::DocumentFragment.dup to another document

Back in b92660e6 (#1834 fixing #1063) I omitted support in JRuby for
the "new_parent_document" argument to `Node#dup` because there was no
performance reason to implement it. So the test was skipped.

However, in 1e7d38af and other commits in #3117 (fixing #316), I
introduced a call to `initialize_copy_with_args` that passes the new
parent document as an argument on both CRuby and JRuby
implementations. Because the test was skipped, I didn't catch that
this broke on JRuby.

In particular this was a problem for Loofah which relies on
decorators, and even more particularly this broke the
`Loofah::TextBehavior` formatting concern for
`Loofah::*::DocumentFragment` objects.

Maybe we should be running downstream tests with JRuby, too? But that
feels like a big investment right now so I'll avoid scarring on the
first cut, and wait to see if it happens again.
```

Also `fix: ReDoS in CSS tokenizer ident rule` — 14 lines: the backtracking mechanism the fix
depends on, the fix, one sentence on tests.

### Calibration

Measured over Mike's last 60 nokogiri commits: subject median 42 chars; 26 have a body of one line
or none; 5 exceed ten lines, and each of those is a benchmark, a mechanism a fix depends on, or a
squashed PR. If your draft is long, it should be for one of those reasons.

## Pull request descriptions

Read `@references/guide.md`. It covers matching the repository's PR template and Mike's voice, with
the eval checks and the failure modes.

## Prose

Follow the prose guidelines in `~/CLAUDE.md`. Backtick every code identifier. Hyperlink every
external artifact.
