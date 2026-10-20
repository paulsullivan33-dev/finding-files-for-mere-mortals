# Actions

**Scope:** what find can *do* with the entries
that pass — `-print`, `-ls`, `-exec` in its two
forms, `-ok`, and `-delete` — and the rule that
keeps them safe: print first, act second.

## -print: the action you get for free

Every find so far has ended with an implicit
`-print`. The rule, stated once and used
everywhere: **if an expression contains no
action anywhere, find wraps it as
`( expression ) -print`** — chapter 6 showed
what happens when an expression contains an
action somewhere you didn't mean. Written
explicitly, `-print` prints the entry's name
as the walk constructed it, starting points
included:

```
$ find tree/subdir
tree/subdir
tree/subdir/nested.txt
```

`-print`'s output is one name per line. That
sounds like a guarantee and isn't, quite: a
name may itself contain a newline (legal,
rare, and chapter 9's problem). For printouts
destined for other programs there is
`-print0`, which separates names with NUL
characters instead; it gets its chapter next.

## -ls: names with evidence

`-ls` prints the entry the way `ls -l` would,
in one line: inode, blocks, mode, links,
owner, group, bytes, date, name.

```
$ find tree -name '*.log' -ls
  7414573      4 -rw-rw----   1 root     nogroup        16 Oct 20 22:26 tree/archive/recent.log
  7414574      4 -rw-rw----   1 root     nogroup        16 Jun 15  2023 tree/archive/old.log
  7414575      4 -rw-rw----   1 root     nogroup        16 Mar  4  2021 tree/archive/ancient.log
  7414567      0 -rw-rw----   1 root     nogroup   2500000 Oct 20 22:26 tree/big.log
```

Chapter 5's facts, visible without a second
command: the archive logs' years ride along in
their dates, and `big.log` again betrays its
sparseness — 2,500,000 bytes of length, **0
blocks** allocated. `-ls` is the audit action:
when a search's answer will be read by a
human deciding something, `-ls` is usually
the print they actually needed.

## Print first, act second

From here on, actions change things. The
discipline of this chapter is one sentence:
**run every new expression with `-print`
first, read the list as if it were the list
of things about to be acted on — because
with one word changed, it will be.** The
rehearsal for everything that follows:

```
$ find tree -name '*.tmp' -print
tree/cache/junk1.tmp
tree/cache/junk2.tmp
```

Two files, both expected. That list, and
only that list, is what the next three
actions will touch.

## -exec: run a command on each match

`-exec command {} \;` runs *command* once per
matching entry, with `{}` replaced by the
entry's name. The command ends at the `\;` —
escaped so the shell hands the semicolon to
find instead of treating it as a command
separator. With a harmless command:

```
$ find tree -name '*.tmp' -exec echo 'would remove:' {} \;
would remove: tree/cache/junk1.tmp
would remove: tree/cache/junk2.tmp
```

Two matches, two invocations, two lines. The
second form ends with `+` instead, and
batches: find accumulates names and runs the
command as few times as it can, `{}` becoming
a list at the end of one command line:

```
$ find tree -name '*.tmp' -exec echo 'would remove:' {} +
would remove: tree/cache/junk1.tmp tree/cache/junk2.tmp
```

One invocation, both names. `-exec … +` is
therefore **faster** — one process instead of
hundreds on a big tree — and **safer**: names
arrive as separate arguments, never re-read
by a shell, so a name with spaces is one name
still. Prefer `+` whenever the command takes
a list of files at the end (`ls`, `chmod`,
`rm`, `sha256sum`); keep `\;` for commands
that handle one file at a time or need `{}`
mid-command. Real work, batched:

```
$ find tree -iname '*.jpg' -exec ls -l {} +
-rw-rw---- 1 root nogroup 31 Oct 20 22:26 tree/photos/img1.jpg
-rw-rw---- 1 root nogroup 31 Oct 20 22:26 tree/photos/img2.JPG
```

Two facts worth carrying. `-exec` runs the
command **directly, with no shell**: no
pipes, no redirection, no glob expansion
inside it — if you truly need those, the
command is `sh -c '…'`, and you have taken
the shell's quoting problems back onto
yourself knowingly. And `-exec`'s test is the
command's exit code — `\;` form only; a
command that fails makes the action false
for that entry, which scripts can and do
build on.

## -ok: -exec with a supervisor

`-ok` is `-exec \;` that asks first, printing
the command it proposes and waiting for a
`y`. The answers here come from a pipe, so
the capture can show both fates:

```
$ printf 'y\nn\n' | find tree -name '*.tmp' -ok echo 'remove?' {} \;
< echo ... tree/cache/junk1.tmp > ? remove? tree/cache/junk1.tmp
< echo ... tree/cache/junk2.tmp > ? [no output — the n]
```

The prompt is `< command … name > ?`; the
first file got its `y` and its echo ran —
`remove? tree/cache/junk1.tmp` — the second
got `n` and was skipped, silently. `-ok` is
the right shape for a handful of files and a
human at the keyboard; for hundreds it is a
trap of a different kind, because nobody
reads the four-hundredth prompt.

## -delete: the action with no undo

`-delete` removes the entries that pass.
Watch the whole ceremony, in the only order
that is safe: rehearse on the real tree,
perform on a **copy**. (The copy is a second
build of the lab — `sh build-tree.sh
tree-del` — identical specimens, expendable.)

```
$ find tree-del -name '*.tmp' -print
tree-del/cache/junk1.tmp
tree-del/cache/junk2.tmp

$ find tree-del -name '*.tmp' -delete
[no output, exit 0]

$ find tree-del -name '*.tmp' -print
[no output, exit 0]
```

Gone, and the re-run of the rehearsal proves
it — the chapter's habit again: print, act,
print. Directories can be deleted the same
way **when they are empty**:

```
$ find tree-del -name 'emptydir' -delete
[exit 0]

$ find tree-del -name 'photos' -delete
find: cannot delete 'tree-del/photos': Directory not empty
[exit 1]
```

`photos` still holds its files — none of them
matched the expression, so they stay, and the
directory can't go. That refusal is find being
careful on your behalf; *your* care has to
happen earlier. Three facts about `-delete`
that belong in muscle memory:

- **It implies `-depth`** — the walk processes
  contents before the directories containing
  them, so a matching directory *can* be
  emptied and removed in one expression. An
  expression broad enough to match everything
  removes everything, bottom-up, including
  the starting point.
- **There is no trash and no undo.** `-delete`
  unlinks. What a file manager would put in a
  bin, find puts nowhere.
- **The expression is the whole safety
  system.** A dropped `-name` test is not a
  typo here; it is a different, larger
  deletion. This is why the rehearsal is not
  optional ceremony: the `-print` run and the
  `-delete` run must be the *same command*
  but for the action word, read twice.

Check: after this chapter's captures, the
original `tree/` is untouched — every deletion
happened under `tree-del/`, and
`find tree -name '*.tmp' -print` still lists
both junk files. If you follow along in your
own copy, hold yourself to the same proof.
