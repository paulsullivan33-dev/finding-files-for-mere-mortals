# The Neighbours

**Scope:** the two tools that live next door
to find — `locate`, which answers from a
database instead of walking, and `fd`, the
modern re-imagining of find's everyday half.
What each trades, what each gives, and why
this guide taught find anyway.

## locate: yesterday's filesystem, instantly

`find` walks. On a small tree that's nothing;
on a whole disk, repeated all day, it's a
real cost. **locate** (the `mlocate` or
`plocate` package; neither is installed on
the build machine, which is why this section
is described rather than captured — the
ledger in `criteria.md` says so) skips the
walk by searching a **database** of every
filename on the system. A companion program,
`updatedb`, builds that database, usually
run nightly by a system timer. `locate
notes.txt` is then a lookup, not a search:
instant, on any size of disk.

The trade is written into the design: the
database is a snapshot, so locate answers
questions about the filesystem **as of the
last update**. A file created an hour ago is
invisible to it; a file deleted yesterday
still answers. Its grammar is correspondingly
smaller — mostly name patterns, some options
for case and for only-existing-files checks
(`plocate` verifies existence as it prints,
which closes the deleted-file half of the
gap). Reach for locate when the question is
"where does this system keep a thing called
X" about files that have been there a while —
a config, a library, a manual page. Reach
for find when the question has *when*,
*how big*, *whose*, or *do something with
them* in it, or when the files are newer
than last night.

On the build machine the honest capture is
the absence:

```
$ locate notes.txt
bash: line 1: locate: command not found
[exit 127]
```

## fd: find's everyday half, with manners

**fd** is the modern neighbour: a ground-up
reimplementation of the common case — search
by name, quickly, in colour, with defaults
chosen for a human at a terminal instead of
a script in 1979. On Debian and Ubuntu it is
installed under the name **`fdfind`**, to
avoid a clash with an older package:

```
$ fdfind --version
fdfind 9.0.0

$ fdfind img tree
tree/photos/img1.jpg
tree/photos/img2.JPG
tree/photos/raw/img3.CR2
```

Three results where chapter 2 needed two
commands' worth of thought: the pattern is a
regular expression rather than a glob, the
bare word matched case-**in**sensitively
(fd's "smart case": a lowercase pattern
doesn't care about case, an uppercase letter
in it makes case matter), and there's no
`-name` — the pattern is the whole point of
the tool. The defaults diverge further, and
a side-by-side over the same tree shows the
characteristic one. fd's search for `txt`:

```
$ fdfind txt tree
tree/Notes.TXT
tree/empty.txt
tree/meeting notes.txt
tree/notes.txt
tree/o'brien.txt
tree/perms/normal.txt
...
tree/times/yesterday.txt
[15 lines]
```

and find's nearest equivalent:

```
$ find tree -iname '*txt*'
tree/subdir/nested.txt
...
tree/.hidden.txt
...
tree/o'brien.txt
[16 lines]
```

Sixteen to fifteen, and the missing one is
`.hidden.txt`: **fd skips hidden files by
default** (and honours `.gitignore`), where
find shows everything it walks past. fd's
other manners: it strips the leading `./`
from results, prints in colour at a terminal,
and walks in parallel — fast, and its result
order is its own, not something to build
scripts on. Its switches for the skips are
one letter each (`-H` includes hidden), and
it has grown `-e` for extensions, `--changed-
within` for ages, `-x` for executing on
results — an honest, converging subset of
find's grammar with better defaults.

It is not taught here for the same reason
locate isn't: **find is the one that is
everywhere** — every server, every rescue
shell, every container, forty years of
scripts — and its grammar is the superset
both neighbours borrow from. Learn find's
tests and actions once and fd reads as a
dialect you can pick up in an afternoon;
the reverse is not true. Knowing the
neighbours exist, and what they traded, is
the mortal-sized portion of them.

Check: run one question both ways on your
own machine — `fdfind` a name you know is
buried, then the `find` equivalent. The
answers should agree about everything except
the hidden files, the ordering, and the
time it took. If they disagree about more
than that, one of them was asked a different
question than you think — which is, by now,
a familiar shape of surprise.
