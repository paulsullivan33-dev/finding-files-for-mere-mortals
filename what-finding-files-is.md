# What Finding Files Is

**Scope:** the mental model — a walk, a set of
entries, an expression of tests and actions — plus
the difference from grep, your versions, and the
lab.

## Two kinds of searching

There are two questions you can ask a filesystem.
One is about **contents**: which lines, inside
which files, say ERROR? That is grep's question,
and the sibling guide *Text Processing for Mere
Mortals* is built on it. The other is about the
files **themselves**: which are bigger than a
megabyte, which changed in the last hour, which
are links, which have been sitting untouched
since 2021, and where in this tree are they
hiding? grep cannot answer those — it would have
to open every file to learn nothing about its
name. **find** is the tool that answers them. It
never needs to open a file at all: everything it
tests — name, type, size, age, owner, permissions
— lives in the file's directory entry and its
metadata, not in its contents.

## The walk

Give find one or more starting points and it
**walks**: it visits the starting points, then
everything inside them, then everything inside
those, top to bottom, one entry at a time. An
**entry** is anything the walk meets — a regular
file, a directory, a symlink, and rarer kinds.
For each entry, find evaluates an **expression**
you supply, built from:

- **Tests**, which are true or false of the
  entry: its name matches a pattern, it is a
  directory, it is older than a day.
- **Actions**, which do something with the
  entry: print its name, list its details, run a
  command on it.

The expression is read strictly left to right,
and tests and actions can be mixed — that one
fact explains nearly all of find's power and
nearly all of its surprises, and several chapters
of this guide are spent on it. If your expression
contains no action at all, find supplies one:
print the name of every entry the tests pass.
That is why the simplest find command is just a
place and a test.

Check: the tools, on the build machine. Both
come from the same package and travel together
through this guide:

```
$ find --version
find (GNU findutils) 4.9.0
...
$ xargs --version | head -1
xargs (GNU findutils) 4.9.0
```

This guide's find is the **GNU** one, the Linux
standard. The BSD find on macOS speaks a close
dialect — same walk, mostly the same tests, a
few spellings different — and the chapters flag
the differences that bite.

Here is the unguided walk, no tests at all,
over the lab tree this guide is built on. With
nothing to filter it, find prints everything:

```
$ find tree
tree
tree/archive
tree/archive/recent.log
tree/archive/old.log
tree/archive/ancient.log
tree/cache
tree/cache/junk1.tmp
tree/cache/junk2.tmp
tree/photos
tree/photos/raw
tree/photos/raw/img3.CR2
tree/photos/img1.jpg
tree/photos/img2.JPG
tree/sizes
tree/sizes/s0.bin
tree/sizes/s1.bin
...
tree/big.log
tree/link-good
tree/link-broken
```

Fifty-one entries in all. Three things to
notice now, because everything later stands on
them. The starting point itself is the first
entry — directories are entries too, and a
directory is always visited before its contents.
The order is the walk's order — directory order,
roughly the order the filesystem hands entries
back — **not** sorted order; if you want sorted
output, pipe through `sort`, find will not do it
for you. And nothing here required opening a
single file.

Counting by kind is the first useful test,
`-type`, met properly in the next chapter:

```
$ find tree -type f | wc -l
39
$ find tree -type d | wc -l
10
$ find tree -type l | wc -l
2
```

Thirty-nine files, ten directories, two
symlinks. A starting point doesn't have to be a
directory, either — a file is a walk of one:

```
$ find tree/notes.txt
tree/notes.txt
```

And with no starting point at all, find walks
from where you stand, `.` — which is why
running a bare `find` in a big home directory
is a fine way to fill a terminal.

## The lab

Everything in this guide happens in one
specimen tree, built by a script so your copy
is identical to the one in the captures:

```
$ sh build-tree.sh tree
built tree
```

The script is in `examples/`, beside a
`lab-notes.txt` that describes every specimen
and why it exists. The tree is built to be
searched: files of exact sizes (0 bytes up to
one byte over a megabyte), files of exact ages
(half an hour to five years), mixed-case
extensions, an empty file and an empty
directory, a good symlink and a broken one —
and two hostile names, `meeting notes.txt`
with its space and `o'brien.txt` with its
apostrophe, waiting in chapters 2 and 9.

Rebuild the tree whenever you like; the script
deletes and recreates only its own directory.
Rebuild it before chapter 4 if it has been
sitting around, because the time specimens are
aged relative to the moment the script runs.

One last habit to form now: **the tree is the
specimen, not your disk.** Every command in
this guide is shown against `tree/` or against
a throwaway copy of it. Aim the same commands
at `/` or your home directory only when you
have read chapter 8 — find is polite about
reading and utterly literal about acting, and
the difference between a search and an
accident is usually one action word.
