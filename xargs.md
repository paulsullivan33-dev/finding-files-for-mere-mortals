# xargs

**Scope:** the companion that turns lists into
command lines — why it exists, how it batches,
the two ways a naive pipeline breaks on real
filenames, and the `-print0` / `-0` pair that
doesn't.

## Why xargs exists: the ceiling

A command line is not infinitely long. The
kernel caps the total size of a command's
arguments and environment — on the build
machine:

```
$ getconf ARG_MAX
2097152
```

About two megabytes. That sounds roomy until
a glob, a command substitution, or a find
over a real tree hands a program a list of
every file you own. The failure is abrupt:

```
$ /bin/true $(seq 1 500000)
bash: line 1: /bin/true: Argument list too long
[exit 126]
```

Half a million short arguments — nothing
exotic, a few megabytes of digits — and the
command never ran at all. **xargs** exists
to live under that ceiling: it reads items
from standard input and runs a command
repeatedly, each time with as many items as
fit. Here is the same half-million, fed
through xargs to `echo`, counting echo's
lines to count the runs:

```
$ seq 1 500000 | xargs -n 10000 echo | wc -l
50

$ seq 1 500000 | xargs -n 100000 echo | wc -l
26
```

`-n 10000` caps the **count**: fifty runs of
ten thousand. The second line is the honest
wrinkle — ask for 100,000 at a time and you
get 26 runs, not 5, because xargs enforces a
**size** cap too (on this machine, roughly
128 KiB of arguments per run; `-s` sets it).
Whichever cap is reached first ends the
batch. The small end of the same dial:

```
$ seq 1 6 | xargs -n 2 echo
1 2
3 4
5 6
```

## The naive pipeline, broken twice

The classic pairing is `find … | xargs
command`, and the classic version uses plain
`-print` — newline-separated names. On a tree
with well-behaved names it works for years.
The lab tree is not well-behaved. Watch `ls`
fail, in two distinct ways, in one run:

```
$ find tree -name '*.txt' | xargs ls -l
xargs: unmatched single quote; by default quotes are special to xargs unless you use the -0 option
ls: cannot access 'tree/meeting': No such file or directory
ls: cannot access 'notes.txt': No such file or directory
-rw-rw---- 1 root nogroup 26 Oct 20 22:26 tree/.hidden.txt
...
-rw-rw---- 1 root nogroup 22 Oct 19 21:26 tree/times/yesterday.txt
[exit 123]
```

Dissect it. **Failure one is the space:**
`tree/meeting notes.txt` arrived as *two*
items, `tree/meeting` and `notes.txt`,
because plain xargs splits its input on any
whitespace. Neither bogus path exists; `ls`
says so, twice. **Failure two is the
apostrophe:** xargs *parses quotes* in its
input — a feature intended for hand-typed
lists — so `o'brien.txt` opens a single
quote that never closes, and xargs complains
by name. And yet the middle of the output is
a perfectly good listing of thirteen files.
That is what makes this dangerous rather
than merely broken: the run mostly worked,
exited **123** (xargs' signal that an
invocation of the command failed), and the
two files it mishandled are exactly the two
you'd be slowest to notice missing.

Newlines separate names only if names never
contain newlines. Spaces are separators only
if names never contain spaces. Real
filesystems make no such promises — a name
may contain anything except `/` and NUL.

## The safe pair: -print0 and -0

So use the one separator a filename **cannot
contain**. `find -print0` terminates each
name with a NUL byte instead of a newline,
and `xargs -0` splits on NULs and switches
off its quote parsing entirely:

```
$ find tree -name '*.txt' -print0 | xargs -0 ls -l
-rw-rw---- 1 root nogroup 26 Oct 20 22:26 tree/.hidden.txt
-rw-rw---- 1 root nogroup  0 Oct 20 22:26 tree/empty.txt
-rw-rw---- 1 root nogroup 22 Oct 20 22:26 tree/meeting notes.txt
-rw-rw---- 1 root nogroup 25 Oct 20 22:26 tree/notes.txt
-rw-rw---- 1 root nogroup 24 Oct 20 22:26 tree/o'brien.txt
...
-rw-rw---- 1 root nogroup 22 Oct 19 21:26 tree/times/yesterday.txt
[exit 0]
```

Fifteen files, the spaced name one entry, the
apostrophe name intact, exit 0. **This pair
is the default shape for find output that
feeds a command**: `find … -print0 | xargs -0
cmd`. It costs nothing when names are tame
and is the only shape that is right when
they aren't. (Chapter 8's `-exec … +` solves
the same problem from the other side — no
pipeline at all — and is better still when
one find is the whole story. xargs earns its
place when the list comes from somewhere
else, or the command must run in stages.)

## -I: one at a time, anywhere in the command

`-exec {} +` puts the names at the *end* of
the command. `-I` lets you place a
replacement string anywhere — at the price
of running the command **once per item**:

```
$ printf 'alpha\nbeta\ngamma\n' | xargs echo
alpha beta gamma

$ printf 'alpha\nbeta\ngamma\n' | xargs -I{} echo 'item: {}'
item: alpha
item: beta
item: gamma
```

Plain xargs: one run, all three arguments.
With `-I{}`: three runs, the string replaced
wherever it stands (`-I` implies one input
line per invocation). That per-item process
is the cost, and it buys real things —
commands needing the name twice, or
mid-command, or differently each time. Use
it for tens of files, not hundreds of
thousands, and combine it with `-0` when the
items are filenames: `find … -print0 | xargs
-0 -I{} cmd {}` is the slow, safe, flexible
corner of the design, and some jobs live
there.

Named, carefully, because they are the ones
a mortal reaches for next: **`-P n`** runs
up to *n* invocations **in parallel** — a
real speedup for independent work, paid for
with interleaved output and no promised
order; reach for it when each invocation's
output is its own file or its own business.
**`-r`** (GNU) suppresses the run entirely
when the input is empty — without it, xargs
runs the command **once, with no arguments**,
on an empty list, which has surprised many
pipelines whose `rm` then complained (or,
worse, didn't). And **xargs' exit codes**
are evidence, as 123 was above: 0 is all
runs fine, 123 is a run failed, 1 is xargs
itself failing. In scripts, that number is
often the only place a partially-failed
batch admits it.
