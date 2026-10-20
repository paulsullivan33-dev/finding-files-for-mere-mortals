# Owners and Permissions

**Scope:** testing entries by whose they are
(`-user`, `-group`, and the numeric forms) and
by their permission bits (`-perm` in its three
shapes) — the tests that turn find from a
search tool into an audit tool.

## Whose: -user

`-user name` tests the entry's owner. It
needs files with more than one owner to be
interesting, and the lab tree — built by one
user — doesn't have any: its specimen
`not-mine.txt` was *meant* to belong to user
`nobody`, but the build machine's home
filesystem refuses ownership changes outright,
even to root:

```
$ chown 65534 tree/perms/not-mine.txt
chown: changing ownership of 'tree/perms/not-mine.txt': Operation not permitted
[exit 1]
```

That refusal is recorded here rather than
smoothed over, because it decides where this
chapter's captures happen: a two-file detour
in `/tmp`, whose filesystem permits the
change. The commands are the point; they
travel to any directory you can name.

```
$ ls -l /tmp/owners
total 8
-rw-rw---- 1 root   root    15 Oct 20 22:27 mine.txt
-rw-rw---- 1 nobody nogroup 17 Oct 20 22:27 theirs.txt

$ find /tmp/owners -user root
/tmp/owners
/tmp/owners/mine.txt

$ find /tmp/owners -user nobody
/tmp/owners/theirs.txt

$ find /tmp/owners -not -user root
/tmp/owners/theirs.txt
```

(`-not` is the spelled-out form of `!`, met
in chapter 6.) The directory itself belongs
to root, so it answers the first search; the
second and third are the same fact read from
opposite ends.

Three relatives, named rather than captured:
`-group` is `-user` for the group; `-uid`
and `-gid` take numbers instead of names,
which is how you search for an owner whose
account has been deleted — or use `-nouser`
and `-nogroup`, which match exactly those
orphans, entries whose owner or group no
longer resolves to a name. Files belonging to
departed accounts are a real audit finding:
nothing maintains them, and nobody may be
watching them.

In practice, mortals meet `-user` less often
as builders of mixed-owner trees than as
auditors of shared ones: everything in this
shared directory that isn't the project's,
everything a departed colleague left behind,
everything a service account has been
quietly writing. The test is the same
whatever the errand.

## The bits: -perm

`-perm` tests the permission bits, and it has
three shapes, which differ in one word: how
much of the pattern must match. The specimens
live in `tree/perms/`:

```
$ ls -l tree/perms
total 20
-rw-r--r-- 1 root nogroup 17 Oct 20 22:26 normal.txt
-rw-rw---- 1 root nogroup 30 Oct 20 22:26 not-mine.txt
-rw------- 1 root nogroup 11 Oct 20 22:26 secret.txt
-rwsr-xr-x 1 root nogroup 37 Oct 20 22:26 setuid.sh
-rw-rw-rw- 1 root nogroup 35 Oct 20 22:26 world-writable.txt
```

Four of the five were set deliberately by the
build script; `not-mine.txt` wears the build
machine's defaults. Now the three shapes.

**Exact** — `-perm 600`: every bit, special
bits included, must equal the pattern:

```
$ find tree -type f -perm 600
tree/perms/secret.txt

$ find tree -type f -perm 644
tree/perms/normal.txt
```

**All of these bits** — `-perm -0002`: every
bit *in the pattern* must be set; other bits
are the entry's own business. This is the
audit shape — "writable by others, whatever
else is true":

```
$ find tree -type f -perm -0002
tree/perms/world-writable.txt
```

**Any of these bits** — `-perm /6000`: at
least one pattern bit set. The two high bits
are setuid (4000) and setgid (2000) — the
*special* bits, which let a program run with
its owner's or group's authority. "Either
special bit, anywhere" is the audit:

```
$ find tree -type f -perm -4000
tree/perms/setuid.sh

$ find tree -type f -perm /6000
tree/perms/setuid.sh
```

The setuid specimen shows its bit in the
listing as the `s` in `-rwsr-xr-x` — the
owner's execute position, replaced. (The
`/`, `-`, and exact forms also accept
symbolic patterns like `-perm -o+w` in GNU
find; the octal forms are the ones that read
the same on every system, so they are the
ones taught here.)

## The two audits, stated as recipes

These are the searches this chapter exists
for, and they are run on real systems by
real administrators:

```
find /srv/shared -type f -perm -0002
find / -xdev -type f -perm /6000 2>/dev/null
```

The first asks what the whole world can
write in a shared tree — usually a shorter
list than feared and a longer one than
hoped. The second inventories every
setuid/setgid program on the root filesystem
(`-xdev` keeps find on one filesystem, out
of `/proc` and mounted oddities) — a list
that should contain only names you can
explain. Two safety notes, plainly: run
audits like these on systems you own or
administer (the series' standing rule), and
expect the second command to be slow and to
need the errors redirected, as shown —
permission-denied noise on a system-wide
walk is normal weather, and chapter 12
explains how to read it.

Check: on the lab tree, `-perm -0002`
returns exactly `world-writable.txt`,
`-perm /6000` exactly `setuid.sh`, and
`-perm 600` exactly `secret.txt`. The tree
was built so those three answers are known
before the searches run; on a real tree,
that is the one luxury you won't have, which
is the entire reason the audits are worth
running.
