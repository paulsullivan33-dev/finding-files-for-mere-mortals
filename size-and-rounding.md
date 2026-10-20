# Size and Rounding

**Scope:** `-size` — what its numbers actually
mean (they are rounded, and the rounding is the
whole story), the suffixes, and the difference
between a file's length and its footprint.

## The specimen shelf

Chapter 3 works in `tree/sizes/`, eleven files
whose byte counts are exact and known:

```
$ ls -l tree/sizes
total 0
-rw-rw---- 1 root nogroup       0 Oct 20 22:26 s0.bin
-rw-rw---- 1 root nogroup       1 Oct 20 22:26 s1.bin
-rw-rw---- 1 root nogroup    1023 Oct 20 22:26 s1023.bin
-rw-rw---- 1 root nogroup    1024 Oct 20 22:26 s1024.bin
-rw-rw---- 1 root nogroup    1025 Oct 20 22:26 s1025.bin
-rw-rw---- 1 root nogroup    1536 Oct 20 22:26 s1536.bin
-rw-rw---- 1 root nogroup 1048576 Oct 20 22:26 s1m.bin
-rw-rw---- 1 root nogroup 1048577 Oct 20 22:26 s1mplus.bin
-rw-rw---- 1 root nogroup     511 Oct 20 22:26 s511.bin
-rw-rw---- 1 root nogroup     512 Oct 20 22:26 s512.bin
-rw-rw---- 1 root nogroup     513 Oct 20 22:26 s513.bin
```

One empty file, a run of small ones straddling
the 512 and 1024 boundaries, one file of
exactly 1 MiB (1048576 bytes), and one a
single byte over. Everything this chapter
claims is proven against these and nothing
else.

## The round-up rule

`-size` does not compare bytes. It converts
the entry's size into **whole units of the
size you asked about — rounding up** — and
compares that whole number. Ask about
megabytes and every file reports its size as
"how many megabytes does it *touch*": a
1-byte file touches one megabyte's worth of
the count, so it *is* size `1M`. Proof:

```
$ find tree/sizes -size 1M
tree/sizes
tree/sizes/s1.bin
tree/sizes/s511.bin
tree/sizes/s512.bin
tree/sizes/s513.bin
tree/sizes/s1023.bin
tree/sizes/s1024.bin
tree/sizes/s1025.bin
tree/sizes/s1536.bin
tree/sizes/s1m.bin
```

Nine files, from 1 byte to exactly 1 MiB, all
of them "1M". Two more lessons ride along in
that listing. The first line is `tree/sizes`
itself — the **directory**, whose own size
also rounds up to one unit. Directories are
entries and this test applies to them; add
`-type f` when you mean files. And the two
files missing are as instructive as the nine
present: `s0.bin`, which rounds to **zero**
units, and `s1mplus.bin`, which rounds to
**two**.

The signs behave exactly as the rounding
predicts, which is to say not as a beginner
expects:

```
$ find tree/sizes -size -1M
tree/sizes/s0.bin

$ find tree/sizes -size +1M
tree/sizes/s1mplus.bin
```

`-size -1M` — "fewer than one unit" — matches
only the empty file: nothing else rounds to
zero. And `-size +1M` — "more than one unit" —
matches **only the file one byte over** a
megabyte. The file of exactly 1 MiB is not
`+1M`; its rounded size is exactly 1, and
*more than 1* it is not. This is the single
most-misread test in find: `-size +1M` does
mean "bigger than a megabyte" in effect, but
only by passing through the rounding — at
every boundary the byte that matters is the
first byte of the *next* unit.

## Honest bytes: the c suffix

When you mean bytes, say bytes. The suffix
`c` makes the unit one byte, and rounding to
whole bytes is no rounding at all:

```
$ find tree/sizes -size 1048576c
tree/sizes/s1m.bin

$ find tree/sizes -size +1048576c
tree/sizes/s1mplus.bin
```

Exact, both ways. The suffixes are:

| Suffix | Unit |
|---|---|
| *(none)* | 512-byte blocks |
| `c` | bytes |
| `w` | 2-byte words (a historical survival) |
| `k` | kibibytes (1024 bytes) |
| `M` | mebibytes (1048576 bytes) |
| `G` | gibibytes |

Note that `M` and `k` are the binary units —
1024-based — not the decimal ones your disk's
box advertises. The default, no suffix, is
512-byte blocks, a unit nobody thinks in any
more but which still obeys the same rule:

```
$ find tree/sizes -size 1
tree/sizes
tree/sizes/s1.bin
tree/sizes/s511.bin
tree/sizes/s512.bin

$ find tree/sizes -size 1k
tree/sizes
tree/sizes/s1.bin
tree/sizes/s511.bin
tree/sizes/s512.bin
tree/sizes/s513.bin
tree/sizes/s1023.bin
tree/sizes/s1024.bin
```

One block covers 1–512 bytes; one kibibyte
covers 1–1024; the 1025-byte file needs two
of either. Same rounding, smaller units.

Across the whole tree, the rounded test is
the right tool for its usual job — "what is
actually big here":

```
$ find tree -size +1M
tree/sizes/s1mplus.bin
tree/big.log
```

## Length is not footprint

One specimen is a liar, on purpose.
`tree/big.log` reports a length of two and a
half million bytes, and find agrees:

```
$ ls -l tree/big.log
-rw-rw---- 1 root nogroup 2500000 Oct 20 22:26 tree/big.log

$ find tree -name 'big.log' -printf '%s bytes\n'
2500000 bytes
```

(`-printf` is an action that prints in your
own format — `%s` is the size in bytes. It is
a GNU extension; BSD find doesn't have it,
and chapter 10's recipes note the fallback.)
But ask the disk what the file costs:

```
$ du -h tree/big.log
0	tree/big.log
```

Zero. `big.log` is **sparse**: its length is
mostly holes — regions no one ever wrote,
which the filesystem records as "nothing
here" instead of storing zeros. `ls` and
find report the *apparent* size, the length;
`du` reports the *allocated* size, the disk
actually spent. Neither is lying; they are
answering different questions, and the sizes
directory itself (its `total 0` in the first
listing) is sparse through and through,
which is how an 11-file shelf of megabyte
specimens costs no disk at all.

So: use `-size` and `-printf` to find long
files, use `du` (chapter 10 of *Watching
Your System for Mere Mortals* is its home)
to find what is eating the disk — and when
the two disagree wildly about the same file,
you have found a sparse one, which is a
discovery, not an error.

Check: the boundary, in one line each.
`-size -1M` on `tree/sizes` returns exactly
`s0.bin`; `-size 1048576c` returns exactly
`s1m.bin`; `-size +1048576c` returns exactly
`s1mplus.bin`. If your find returns anything
else, it isn't rounding the way this chapter
describes — and now you know how to check.
