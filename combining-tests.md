# Combining Tests

**Scope:** joining tests into one expression —
side-by-side AND, `-o` for OR, `-not` and `!` —
and the precedence that decides what an
expression actually says, including the trap
where `-print` joins only half of it.

## AND: just stand them together

Two tests side by side both have to pass.
There is no keyword; adjacency *is* AND
(formally `-a`, almost never written):

```
$ find tree -type f -name '*.log'
tree/archive/recent.log
tree/archive/old.log
tree/archive/ancient.log
tree/big.log
```

Files, *and* named `*.log`. Most real find
commands are a chain of these: a type, a
name, an age, all narrowing one walk.

## OR: -o

`-o` joins alternatives — either side may
pass:

```
$ find tree -name '*.jpg' -o -name '*.md'
tree/photos/img1.jpg
tree/report.md
```

One of the tree's quiet jokes is in that
listing: `img2.JPG` is missing, because as
chapter 2 established, `-name '*.jpg'` is
case-sensitive and nobody said `-iname`.
`-o` widens the net; it doesn't mend the
individual tests.

## NOT: -not and !

`-not` (or a bare `!`, escaped from the shell
as `\!` where history expansion is watching)
inverts the test after it:

```
$ find tree/photos -not -type d
tree/photos/raw/img3.CR2
tree/photos/img1.jpg
tree/photos/img2.JPG
```

Everything in photos that isn't a directory.
Note the raw file sails through a `-not`
whose job was only about types — NOT applies
to the one test it precedes, nothing wider,
unless you group, which is next.

## Precedence, and the -print trap

AND binds tighter than OR: `a -o b c` reads
as `a`, or (`b` and `c`). Usually that's what
you meant. But actions are part of the
expression too, evaluated in the same left-to-
right flow — and here is the capture this
chapter exists for. It *looks* like "print
the text files and the markdown file":

```
$ find tree -name '*.txt' -o -name '*.md' -print
tree/report.md
```

Only the markdown. Here is why. The
expression is

```
-name '*.txt'   -o   ( -name '*.md' -a -print )
```

`-print` stands on the right of the `-o`, so
it is part of the right-hand alternative:
entries matching `*.md` are printed, entries
matching `*.txt` merely *pass* — and pass to
nothing. Chapter 1 said find adds a `-print`
of its own when an expression has no action;
this expression **has** an action, so no
automatic one is added, and the fifteen text
files were selected and silently discarded.
How many were lost, for the record:

```
$ find tree -type f -name '*.txt' | wc -l
15
```

The fix is to group with **parentheses**, so
the action stands outside the choice.
Parentheses are shell metacharacters, so
they are escaped with backslashes (or the
whole expression piece quoted):

```
$ find tree \( -name '*.txt' -o -name '*.md' \) -print
tree/subdir/nested.txt
tree/times/fresh.txt
tree/times/halfhour.txt
tree/times/marker.txt
tree/times/yesterday.txt
tree/times/twodays.txt
tree/perms/world-writable.txt
tree/perms/secret.txt
tree/perms/normal.txt
tree/perms/not-mine.txt
tree/notes.txt
tree/report.md
tree/.hidden.txt
tree/empty.txt
tree/meeting notes.txt
tree/o'brien.txt
```

Sixteen lines: fifteen text files *and*
`report.md`, the answer the author of the
unparenthesised version believed they were
getting. Grouping also composes with NOT —
`! \( a -o b \)` is "neither" — and with
longer chains, and the rule for reading any
expression you didn't write this morning is
simple: find where the actions stand, draw
the parentheses the author *didn't*, and
only then decide what the command does.

This trap is placed here, before the actions
chapter, on purpose. Nothing in the broken
command was exotic — two ordinary tests and
the most ordinary action — and its failure
was silent, complete, and plausible-looking.
Remember its shape when chapter 8 gives
actions teeth.
