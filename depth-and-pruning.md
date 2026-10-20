# Depth and Pruning

**Scope:** controlling how deep the walk goes —
`-maxdepth`, `-mindepth` — and teaching find to
skip a subtree entirely with `-prune`, including
the broken prune that silently prints nothing.

## Depth, counted from the starting point

**Depth** is distance from the starting point:
the starting point itself is depth 0, the
entries directly inside a directory start are
depth 1, and so on. `-maxdepth n` refuses to
test or descend beyond depth *n*:

```
$ find tree -maxdepth 1
tree
tree/archive
tree/cache
tree/photos
tree/sizes
tree/subdir
tree/times
tree/perms
tree/emptydir
tree/notes.txt
tree/Notes.TXT
tree/report.md
tree/data.csv
tree/.hidden.txt
tree/empty.txt
tree/meeting notes.txt
tree/o'brien.txt
tree/big.log
tree/link-good
tree/link-broken
```

The starting point and its immediate contents —
a tree's table of contents. Depth limits are
also how you keep a search cheap: a
`-maxdepth 2` sweep of a home directory is a
question about its top level only.

The limit's bite is easiest to see against a
file at a known depth. `img3.CR2` lives at
depth 3 — `tree`(0) / `photos`(1) / `raw`(2) /
the file(3):

```
$ find tree -maxdepth 2 -name '*.CR2'
[no output, exit 0]

$ find tree -name '*.CR2'
tree/photos/raw/img3.CR2
```

Silent, exit 0, and correct: the walk never
reached the file. A search that "should have
found it" with a depth limit aboard is usually
this, arithmetic and nothing more sinister.

`-mindepth n` is the mirror: entries shallower
than *n* are passed over entirely (the walk
still descends through them). Its everyday
use is skipping the starting point itself —
or, as here, asking about a subtree's
*contents'* contents:

```
$ find tree/photos -mindepth 2
tree/photos/raw/img3.CR2
```

Depth 0 is `photos`, depth 1 is `raw` and the
two jpgs, so depth 2 leaves exactly the raw
file. Both depth tests are **global options**,
not tests: they govern the whole walk
whichever entries they stand beside, and the
convention — write them immediately after the
starting points, before any test — is worth
following even where find tolerates them later
in the expression, because the reader of your
command will read them where they expect to
find them.

## Pruning: don't go in there at all

A depth limit can't express "everything,
except that folder." `-prune` can: when the
walk reaches an entry the tests before it
match, `-prune` returns true and, if the entry
is a directory, **the walk does not descend
into it**. Its canonical shape uses chapter
6's machinery, and both moving parts are
load-bearing:

```
find tree -path 'tree/cache' -prune -o -type f -print
```

Reading left to right: at each entry, either
it is the cache directory — prune it, job done
for that branch — **or** (`-o`) it isn't, and
the right-hand side applies: files get
printed. The cache specimens exist to be
skipped:

```
$ find tree -name '*.tmp'
tree/cache/junk1.tmp
tree/cache/junk2.tmp
```

and under the prune, a full file listing of
the tree has 37 entries and neither of them:

```
$ find tree -path 'tree/cache' -prune -o -type f -print
tree/archive/recent.log
tree/archive/old.log
tree/archive/ancient.log
tree/photos/raw/img3.CR2
...
tree/big.log
[37 lines; no tree/cache entry appears]
```

Why the `-o` version works: when the cache
directory matches the left side, `-prune`
makes that side true, the OR is satisfied,
and the right side — the print — is never
evaluated for it. For everything else the
left side is false, evaluation falls through
to the right, and matching files print.

Now the broken form, which replaces `-o` with
adjacency — AND:

```
$ find tree -path 'tree/cache' -prune -type f -print
[no output, exit 0]
```

Nothing. Not "everything but the cache" —
*nothing at all*, exit 0. The expression is
now one AND chain: `-path` and `-prune` and
`-type f` and `-print`. The only entry
satisfying `-path 'tree/cache'` is the cache
directory itself; it is not a regular file,
so the chain fails for it; every other entry
fails `-path`. No entry reaches `-print`.
The prune ate the output, and exit 0 kept the
secret. This is the second member of the
series' silent-silence family (chapter 6's
half-bound `-print` was the first): when find
prints nothing, the expression — not the
disk — is the first suspect.

One more property worth knowing: `-prune` on
a *file* does nothing special — it evaluates
true and the walk continues; pruning is about
descent. And a pruned directory is still
itself evaluated by the rest of the left side
only — in the canonical shape it is never
printed. If you want the pruned directory
named too, that is a second search, or a
deliberate second branch of the OR — write
it knowingly.
