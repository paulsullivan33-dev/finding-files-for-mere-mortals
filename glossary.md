# Glossary

**Action** — an expression element that does
something with an entry that reaches it:
`-print`, `-ls`, `-exec`, `-ok`, `-delete`,
`-prune`. If an expression has no action,
find adds `-print` to the whole of it.
Chapters 1, 6, 8.

**ARG_MAX** — the kernel's cap on the total
size of a command's arguments plus its
environment; the ceiling xargs exists to
work under. Chapter 9.

**Basename** — the final component of a path:
`notes.txt` in `tree/notes.txt`. `-name`
tests the basename; `-path` tests the whole
string. Chapter 2.

**Broken symlink** — a link whose target does
not exist. Found by asking for links whose
target is a link: `-xtype l`. Chapter 10.

**Depth** — distance from the starting
point: the start itself is 0, its immediate
contents 1. `-maxdepth` and `-mindepth`
govern the walk by it. Chapter 7.

**Entry** — anything the walk visits: a file,
directory, symlink, device, pipe, or socket.
Tests apply to entries of every kind unless
`-type` narrows them. Chapter 1.

**Exit code** — the number left in `$?`.
find's are 0 (the walk completed, matches or
not) and nonzero (something failed).
xargs adds 123: a command it ran failed.
Chapters 9, 12.

**Expression** — the tests and actions after
the starting points, evaluated left to
right, AND binding tighter than `-o`.
Chapters 1, 6.

**Glob** — the shell's pattern language:
`*` any run of characters, `?` exactly one,
`[...]` one of a set. find's `-name` speaks
glob, not regular expression — and the
pattern must match the whole name.
Chapter 2.

**Marker** — the reference file in a `-newer`
test: entries are judged against its
timestamp. Chapter 4.

**mtime** — the modification time: when an
entry's contents last changed. `-mmin` tests
it in minutes, `-mtime` in whole days, the
fraction discarded. Its siblings are atime
(last read) and ctime (last metadata
change — not creation). Chapter 4.

**NUL** — the zero byte, the one character a
filename can never contain, and therefore
the only separator that cannot lie:
`-print0` output, read by `xargs -0`.
Chapter 9.

**Prune** — `-prune`: when the left side of
an expression matches a directory, the walk
does not descend into it. Only correct in
its `-o` shape. Chapter 7.

**Round up** — `-size`'s conversion: a size
is reported as the count of whole units it
touches, so 1 byte is size `1M` and exactly
1 MiB is not `+1M`. Chapter 3.

**Setuid / setgid** — the special permission
bits (4000 / 2000) that let a program run
with its owner's or group's authority;
shown as `s` in a listing, audited with
`-perm /6000`. Chapter 5.

**Sparse file** — a file whose length is
mostly unwritten holes: apparent size large,
allocated size (what `du` reports) small.
Chapter 3.

**Starting point** — a path find is told to
walk. It is itself the first entry tested,
and it may be a file. Absent, it is `.`.
Chapters 1, 12.

**Symlink** — an entry that contains a path
to another entry. `-type l` tests the link
itself; `-xtype` tests what it points at.
Chapters 2, 10.

**Test** — an expression element that is true
or false of an entry: `-name`, `-type`,
`-size`, `-mtime`, `-user`, `-perm`, and
their kin. Chapters 1–7.

**Walk** — find's traversal: each starting
point, then its contents, recursively, a
directory always before what it holds, in
the filesystem's order rather than sorted
order. Chapter 1.

**World-writable** — the `o+w` permission:
anyone may write. Audited with
`-perm -0002`. Chapter 5.
