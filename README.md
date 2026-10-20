# Finding Files for Mere Mortals

The sibling guide *Text Processing for Mere
Mortals* searches what is **inside** files:
grep reads lines and keeps the ones that
match. This guide searches the other half of
the filesystem — names, places, and facts
about files: how big, how old, whose, how
permitted, and where in the tree they sit.
The tool is **find**, the oldest filesystem
search program there is. It walks a tree
from top to bottom, tests every entry it
meets against an expression you give it, and
does something — usually just printing the
name — with the entries that pass. A
companion, **xargs**, turns find's output
into work for other commands.

find has a reputation for being cryptic,
and it is earned: its expression language is
small but exact, it rounds sizes in a way
that surprises every beginner once, and its
most dangerous failures are the silent ones —
the pattern your shell rewrote before find
ever saw it, the action that quietly bound
itself to only half of your expression.
This guide takes those traps one at a time,
each on a specimen tree built to spring it
safely.

The lab is one tree, built by a script in
`examples/` (`build-tree.sh`): 51 entries —
specimen files of exact sizes and ages, a
file with a space in its name, one with an
apostrophe, links good and broken, an empty
file, an empty directory, and a cache folder
you will learn to prune and, eventually, to
empty. Every name in it is invented and
every size is deliberate.

A note on how this guide was verified. GNU
findutils 4.9.0 (find and xargs) was on the
build machine, and every command quoted was
run against the lab tree and captured: the
match lists, the counts, the exit codes, and
the failures. Where another system's find
behaves differently — the BSD and macOS
dialect mostly — the chapters say so in
place and `criteria.md` keeps the ledger of
what is documented-only.

## What this guide covers

- [**What finding files is**](what-finding-files-is.md) —
  the walk, entries, tests and actions; how
  find differs from grep; your versions; the
  lab
- [**Names and types**](names-and-types.md) —
  `-name`, `-iname`, `-path`; glob patterns;
  `-type`; and the unquoted-glob trap,
  sprung twice
- [**Size and rounding**](size-and-rounding.md) —
  `-size`, its round-up rule proven at exact
  byte boundaries, the `c` suffix for honest
  bytes, and sparse files fooling `du`
- [**Time and ages**](time-and-ages.md) —
  `-mmin`, `-mtime` and its whole-day
  rounding, `-newer`, and anchoring ages to
  a file you know
- [**Owners and permissions**](owners-and-permissions.md) —
  `-user`, `-perm` in its three shapes, and
  the world-writable and setuid audits
- [**Combining tests**](combining-tests.md) —
  AND, `-o`, `-not`, precedence — and the
  `-print` that bound itself to half an
  expression
- [**Depth and pruning**](depth-and-pruning.md) —
  `-maxdepth`, `-mindepth`, and `-prune`,
  including the prune that ate its own
  output
- [**Actions**](actions.md) — `-print`,
  `-ls`, `-exec` with `\;` and with `+`,
  `-ok`, `-delete` — and the rule: print
  first, act second
- [**xargs**](xargs.md) — why it exists (the
  argument-list ceiling), batching, and the
  `-print0` / `-0` pair that hostile
  filenames cannot break
- [**Recipes**](recipes.md) — largest files,
  the last hour's changes, empty entries,
  broken links, and cleaning old logs
- [**The neighbours**](the-neighbours.md) —
  `locate` and its day-old database, and
  `fd`, the friendlier modern tool: what
  they trade away and what they give back
- [**Troubleshooting**](troubleshooting.md) —
  silence that means "no match," errors
  that mean it, directories matching your
  file tests, and exit codes as evidence
- [**Glossary**](glossary.md) — the terms,
  collected in one place

## What it doesn't cover

Searching inside files — the sibling *Text
Processing for Mere Mortals* owns grep, sed,
and awk. Full `fd` and `locate` tutorials:
chapter 11 places them honestly and teaches
find, whose grammar is the one every system
has. Filesystem internals below find —
inodes get a paragraph, not a chapter — and
forensic recovery of deleted files, which
is a different trade entirely. Disk usage
as a subject belongs to *Watching Your
System for Mere Mortals*; this guide borrows
`du` once, to show where its answer and
find's part company.

## How to use this guide

Read chapter 1, build the lab tree as it
directs, and keep a terminal open from
chapter 2 on. Work in a copy of the tree
you can rebuild — chapter 8 deletes files
on purpose, in the copy only, and the
specimens should survive your experiments
so you can start a chapter over. Keep the
tree afterward: a filesystem with known
answers is a standing rehearsal for the
day a real one asks the same questions.
