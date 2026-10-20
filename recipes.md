# Recipes

**Scope:** the searches mortals actually run —
largest files, recent changes, empty entries,
broken links, and old-log cleanup — each
assembled from the earlier chapters and each
run on the lab tree first.

## The largest files

Sort chapter 3's sizes numerically, biggest
first, and take the head of the list. The
sorting is done by `sort`, the arithmetic by
nobody: `-printf` (chapter 3) emits size and
name, one per line, already a table:

```
$ find tree -type f -printf '%s %p\n' | sort -rn | head -5
2500000 tree/big.log
1048577 tree/sizes/s1mplus.bin
1048576 tree/sizes/s1m.bin
1536 tree/sizes/s1536.bin
1025 tree/sizes/s1025.bin
```

On a real disk this is the "what got big"
answer in one line. Two qualifications,
both earned earlier: these are **apparent**
sizes — chapter 3's `du` warning applies,
and a disk-full hunt should cross-check with
`du`, which counts allocated blocks — and
`-printf` is a GNU spelling; on BSD find the
same table comes from
`find … -exec stat -f '%z %N' {} +` or a
`-ls`-and-`awk` detour. The recipe's shape —
find selects, a printer formats, `sort`
ranks — survives either way.

## What changed in the last hour

Chapter 4's test, doing its everyday job:

```
$ find tree/times -mmin -60
tree/times
tree/times/fresh.txt
tree/times/halfhour.txt
```

Run unscoped on a real tree this answers
"what did that last command / install /
deploy actually touch" — and it is the first
search to run when a machine's behaviour
changed and nobody admits to changing it.
On the lab tree the whole specimen shelf is
young, which is why the capture is scoped to
`times/`; on your disk the scope is whatever
directory the mystery lives in.

## Empty entries

`-empty` is a test of its own — true of
zero-byte files **and** of directories with
nothing in them:

```
$ find tree -empty
tree/sizes/s0.bin
tree/emptydir
tree/empty.txt
```

All three specimens answer. The everyday use
is housekeeping with a safety story: empty
files are often the residue of a failed
write or an abandoned lock; empty
directories are what a cleanup leaves behind
and the next cleanup trips over. Paired with
chapter 8, `find … -empty -delete` is the
tidy ending — rehearsed with `-print` first,
as always.

## Broken symlinks

Chapter 2's `-type l` lists links; **what
they point at** is a different question, and
`-xtype` asks it. `-xtype` tests the type of
the link's *target* — except when the target
doesn't exist, where it falls back to the
link itself. That fallback is the recipe:
a link whose target's type is "link" is a
link pointing at nothing.

```
$ find tree -type l
tree/link-good
tree/link-broken

$ find tree -xtype l
tree/link-broken
```

One link is honest, one dangles, and
`-xtype l` names only the dangler. Software
upgrades and tidied directories leave these
behind in real trees; a dangling link is
usually harmless and always informative —
something used to live where it points.

## Cleaning old logs

The set piece, assembled from chapters 4 and
8, in the world of the sibling guide *cron
for Mere Mortals* — where old logs come
from, and where the schedule that rotates
them lives. Work on a fresh expendable copy,
as chapter 8 taught (`sh build-tree.sh
tree-del`), and say the whole expression
with `-print` first:

```
$ find tree-del/archive -name '*.log' -mtime +365 -print
tree-del/archive/old.log
tree-del/archive/ancient.log
```

Two files: the 2023 and the 2021 logs.
`recent.log`, built today, is correctly not
among them. The expression is right, the
list is the list intended — so the **same
command, with the action swapped**:

```
$ find tree-del/archive -name '*.log' -mtime +365 -delete
[no output, exit 0]

$ ls tree-del/archive
recent.log
```

That is the whole pattern, and it
generalises to nearly every destructive
find you will ever write: the selection and
the action are separate clauses, the
selection is proven first, and the proof is
re-run afterward to show the intended state
and nothing else changed. Rotate the nouns
— `-mtime +30` on a download folder,
`-size +500M` on a media tree, `-empty` on a
build directory — the ceremony is the same.

**Your turn, with the safety on:** on a copy
of a real directory (a backup, a scratch
clone), write the three recipes you would
actually run on the original: largest files,
older than your retention, empties. Rehearse
each with `-print`, and only then decide
which, if any, earn an action. The tree you
keep is the one you rehearsed on.
