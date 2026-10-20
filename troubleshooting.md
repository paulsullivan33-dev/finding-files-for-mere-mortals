# Troubleshooting

**Scope:** the failures of find itself, by
symptom — silence and what it means, errors
and what they change, and the four "it found
the wrong things" that aren't malfunctions.

## Symptom: nothing printed, no error

```
$ find tree -name '*.zzz'
[no output, exit 0]
```

**Cause:** the walk completed; no entry
matched. Exit 0 is find vouching for exactly
that. Silence is an *answer*, and the first
diagnostic skill is believing it: check the
answer before the tool — is the pattern
quoted (chapter 2), is the case right or
`-iname` wanted (chapter 2), is a `-maxdepth`
hiding the depth your file lives at (chapter
7), is the starting point the tree you think
it is?

**Fix:** loosen one clause at a time and
watch the answer grow; the clause that
changes it was the one mis-set. `echo $?`
after a suspicious silence separates "no
match" (0) from every failure below.

## Symptom: it stopped before starting

```
$ find tree/nope
find: 'tree/nope': No such file or directory
[exit 1]
```

**Cause:** a starting point that doesn't
exist — a typo, or a relative path from the
wrong directory. find reports it, sets a
nonzero exit, and (with several starting
points) still walks the ones that exist.

**Fix:** correct the path; and in scripts,
treat a nonzero exit as "the answer is
incomplete," never as a long way of saying
"no matches."

## Symptom: Permission denied

```
$ su -s /bin/sh nobody -c 'find /tmp/locked'
/tmp/locked
find: '/tmp/locked': Permission denied
[exit 1]
```

**Cause:** the walk reached a directory the
searcher can't read. find prints the starting
point it *could* evaluate, reports the
directory it couldn't enter, and continues
with everything else — results are partial
from that point, and the exit code (1) is the
evidence. The capture was made as user
`nobody` against a root-only directory, but
you will meet the same line as yourself in
`/etc`, `/var`, and other people's home
directories.

**Fix:** decide whether the missing
directories matter. For audits where they
don't, `2>/dev/null` silences the noise —
knowing it also silences genuine errors like
the previous symptom. For audits where they
do, the answer is running as an identity that
may read them, and *that* decision is a
security decision, not a convenience.

## Symptom: it matched directories when I wanted files

**Cause:** directories are entries and most
tests apply to them — chapter 3's `-size 1M`
listing began with `tree/sizes` itself;
chapter 4's time searches matched their
directory. Nothing malfunctioned; the
expression simply never said "files."

**Fix:** `-type f` (or whichever kind you
mean) early in the expression. Treat it as
part of the question, not a refinement:
"files, bigger than…, older than…" is a
different question from "entries…."

## Symptom: adding -print made it print less

**Cause:** chapter 6's trap: with an `-o` in
the expression, an action placed at the end
belongs to the last alternative only, and
find adds no automatic `-print` when any
action is present. `find tree -name '*.txt'
-o -name '*.md' -print` prints the markdown
and silently discards fifteen matches.

**Fix:** group the alternatives —
`\( … -o … \) -print` — and, as a habit, count
with `| wc -l` before and after "improving"
an expression that will grow an action.

## Symptom: -delete says "Directory not empty"

```
$ find tree-del -name 'photos' -delete
find: cannot delete 'tree-del/photos': Directory not empty
[exit 1]
```

**Cause:** `-delete` removes directories only
when empty (chapter 8); `photos` still held
files the expression didn't select.

**Fix:** that's the safeguard working. If the
whole subtree really is the target, say so —
a broader expression, rehearsed with
`-print`, relying on the `-depth` that
`-delete` implies — or clear the contents
with their own expression first. Never widen
the expression *in place* on the original;
go back to a copy and re-rehearse.

## Symptom: xargs exited 123, or ate a filename

**Cause:** chapter 9's pair of failures — a
command invocation failed (123), and plain
`-print` output split or quote-mangled a
hostile name (the spaced and apostrophised
specimens).

**Fix:** `-print0 | xargs -0`, or
`-exec … +` and no pipeline at all. When the
damage is already done, the listing the
naive pipeline *did* print is the
undercount: diff it against the `-print`
rehearsal to name what was skipped.
