# Names and Types

**Scope:** matching entries by what they are
called — `-name`, `-iname`, `-path` — and by
what they are — `-type`. And the trap that
catches everyone once: the pattern your shell
rewrote before find saw it.

## -name: the basename, as a glob

`-name` tests the entry's **basename** — its
final component, with no directory part —
against a **glob pattern**: the shell's
wildcard language, where `*` means any run of
characters, `?` means exactly one character,
and `[abc]` means one of a set. It is not a
regular expression; there is no `.*` and no
anchoring to add, because the pattern must
match the **whole** basename.

```
$ find tree -name '*.txt'
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
tree/.hidden.txt
tree/empty.txt
tree/meeting notes.txt
tree/o'brien.txt
```

Fifteen matches, printed in walk order. Note
who is present: the dotfile `.hidden.txt` —
find has no special shyness about dotfiles,
it was only ever the shell's globs that hid
them — and both hostile names, which the
pattern matches quite happily; names with
spaces are a problem for later chapters, not
for this test.

Matching is case-sensitive, and the tree was
built to prove it:

```
$ find tree -name '*.TXT'
tree/Notes.TXT
$ find tree -iname '*.txt'
tree/subdir/nested.txt
...
tree/notes.txt
tree/Notes.TXT
tree/.hidden.txt
...
```

`-iname` is the same test with case folded:
sixteen matches, `Notes.TXT` among them. When
you are searching a disk you didn't name
yourself — a photo archive, a Windows-era
backup — `-iname` is usually the test you
meant.

The whole-basename rule is why `?` needs the
extension accounted for. In the sizes
directory, where the names are regular:

```
$ find tree/sizes -name 's???.bin'
tree/sizes/s511.bin
tree/sizes/s512.bin
tree/sizes/s513.bin
```

`s` + exactly three characters + `.bin`:
`s511`, `s512`, `s513`. The four-digit names
don't fit, `s1m` is too short. A pattern of
`img?` against the photos matches nothing at
all, because the basenames are `img1.jpg` —
eight characters, not four. The pattern is
the whole name or it is nothing.

## -path: the whole string

`-path` tests the same glob against the
entry's **entire path as find prints it**,
directories and all:

```
$ find tree -path '*/photos/*'
tree/photos/raw
tree/photos/raw/img3.CR2
tree/photos/img1.jpg
tree/photos/img2.JPG
```

"Anything with `/photos/` in it" — directory
included. This is the test for location, not
identity. The converse mistake is common
enough to capture: a slash can never appear
in a basename, so this pattern can never
match, and find says nothing about why:

```
$ find tree -name 'raw/*'
[no output, exit 0]
```

Silence plus exit 0 means "no entry matched
your expression," never "your expression was
impossible." Chapter 12 returns to that
distinction; it is the most important one in
find's bedside manner.

## -type: what the entry is

`-name` says what an entry is called; `-type`
says what it **is**, as a single letter:

| Letter | Kind |
|---|---|
| `f` | regular file |
| `d` | directory |
| `l` | symlink |
| `b`, `c` | block / character device |
| `p` | named pipe (FIFO) |
| `s` | socket |

```
$ find tree -type d
tree
tree/archive
tree/cache
tree/photos
tree/photos/raw
tree/sizes
tree/subdir
tree/times
tree/perms
tree/emptydir

$ find tree -type l
tree/link-good
tree/link-broken
```

Note that `-type l` lists both links without
caring where they point — it tests the entry
itself. (Testing what a link points *at* is
recipe work, chapter 10.) Tests sit side by
side to combine them — `find tree -type f
-name '*.txt'` is files **and** text files —
and combination has its own chapter, 6.

## The glob trap

Every pattern above was **quoted**. That is
not tidiness; it is the whole game. A pattern
in quotes reaches find untouched. A pattern
without quotes is expanded **by your shell,
first**, against the files in your current
directory — and find receives whatever the
expansion produced. Watch it happen. Standing
inside the tree:

```
$ cd tree && echo *.txt
empty.txt meeting notes.txt notes.txt o'brien.txt
```

That is what the shell makes of `*.txt`: the
matching names in *this* directory only.
(`Notes.TXT` is absent — the shell's glob is
case-sensitive too. `.hidden.txt` is absent —
shell globs skip dotfiles. Everything in
subdirectories is absent — a glob is one
level.) Now hand that same unquoted pattern
to find:

```
$ cd tree && find . -name *.txt
find: paths must precede expression: `meeting notes.txt'
find: possible unquoted pattern after predicate `-name'?
[exit 1]
```

The shell replaced `*.txt` with four names.
find took the first, `empty.txt`, as the
pattern — and then met `meeting notes.txt`
where only tests may stand, and stopped.
GNU find even names the likely cause. One
mercy: it failed loudly.

The other failure mode doesn't. Build a
directory with exactly **one** match at the
top and another buried below it:

```
$ cd globtrap && find . -name *.txt
./solo.txt
[exit 0]
```

Exit 0, a plausible-looking answer, and
wrong: the shell expanded the pattern to
`solo.txt`, so find spent the whole walk
looking for files named `solo.txt`, and
`./sub/inner.txt` never had a chance. The
quoted form finds both:

```
$ cd globtrap && find . -name '*.txt'
./sub/inner.txt
./solo.txt
```

This is the trap in its full form: unquoted,
a glob pattern is a coin flip between an
error you'll notice and an answer you
shouldn't trust. **Quote every pattern,
every time** — single quotes, so the shell
leaves `*`, `?`, and `[` alone — and the
question of what your current directory
happens to contain stops mattering.
