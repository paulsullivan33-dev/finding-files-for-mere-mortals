# Time and Ages

**Scope:** testing entries by when they last
changed — `-mmin` for minutes, `-mtime` for
whole days and its discarded fractions, and
`-newer` for anchoring one file's age to
another's.

## Which time?

Every entry carries several timestamps. The
one this chapter tests is the **modification
time** — *mtime* — when the file's contents
last changed. Its siblings get a sentence
each and no more: the **access time** (atime,
`-atime`/`-amin`, when the contents were last
read — often not maintained precisely) and
the **change time** (ctime, `-ctime`/`-cmin`,
when the metadata — permissions, name, owner
— last changed; despite the letter, it is not
the creation time). Nine searches in ten want
mtime, and the `-m` tests are the ones
captured here.

The specimens live in `tree/times/`, aged by
the build script relative to the moment it
ran. Listed newest first:

```
$ ls -lt tree/times
total 20
-rw-rw---- 1 root nogroup 17 Oct 20 22:26 fresh.txt
-rw-rw---- 1 root nogroup 25 Oct 20 21:56 halfhour.txt
-rw-rw---- 1 root nogroup 19 Oct 20 20:26 marker.txt
-rw-rw---- 1 root nogroup 22 Oct 19 21:26 yesterday.txt
-rw-rw---- 1 root nogroup 21 Oct 18 21:26 twodays.txt
```

`fresh.txt` just written, `halfhour.txt`
thirty minutes old, `marker.txt` two hours,
`yesterday.txt` twenty-five hours,
`twodays.txt` forty-nine. (If you rebuilt the
tree a while ago, the cast has aged together
— rebuild it and the ages reset.)

## Minutes: -mmin

`-mmin n` tests the age in whole minutes,
with the same `-`, exact, `+` grammar as
`-size`, but no rounding trap: minutes are
small enough that the count is nearly exact.

```
$ find tree/times -mmin -60
tree/times
tree/times/fresh.txt
tree/times/halfhour.txt

$ find tree/times -mmin +60
tree/times/marker.txt
tree/times/yesterday.txt
tree/times/twodays.txt
```

Under an hour: the two youngest. Over an
hour: the other three. The directory itself
appears in the first list — its mtime is the
moment its contents last changed, which was
the build — another reminder that directories
are entries whose facts are tested like any
other's.

## Days: -mtime, and the discarded fraction

`-mtime n` tests the age in **whole 24-hour
periods, with any fraction thrown away**. A
file's `-mtime` value is its age in hours,
divided by 24, rounded **down**. That one
rounding rule generates every result in this
chapter:

```
$ find tree/times -mtime 0
tree/times
tree/times/fresh.txt
tree/times/halfhour.txt
tree/times/marker.txt

$ find tree/times -mtime 1
tree/times/yesterday.txt

$ find tree/times -mtime 2
tree/times/twodays.txt

$ find tree/times -mtime +1
tree/times/twodays.txt
```

Read them off the rule. *Zero* means "less
than 24 hours old," so it collects everything
up to and including the two-hour-old marker.
The 25-hour file has completed one whole day
— value 1, alone. The 49-hour file has
completed two — value 2. And `+1`, "more than
one completed day," skips the 25-hour file
entirely (its value is 1, which is not more
than 1) and takes only the 49-hour one.

The consequences to carry away:

- "Modified today" and `-mtime 0` are **not
  the same thing**. `-mtime 0` is a rolling
  24-hour window ending now — it crosses
  midnight without noticing. Calendar days
  are a different tool's question (GNU find's
  `-daystart` adjusts the reckoning; it is
  named here, not taught).
- A file 23 hours old and a file 23 *minutes*
  old are both `-mtime 0`. When the
  difference matters, drop to `-mmin`, whose
  window is small enough to see it.
- `-mtime +365` — the classic "untouched for
  over a year" — really means "at least 366
  completed days." On the archive specimens,
  aged in years rather than hours:

```
$ find tree/archive -mtime +365
tree/archive/old.log
tree/archive/ancient.log
```

Both the 2023 and the 2021 log qualify; the
recent one doesn't. Chapter 10 turns exactly
this search into a cleanup.

## Anchoring: -newer

Relative ages drift; comparisons don't.
`-newer file` tests whether an entry's mtime
is later than another file's — the reference
file is called the **marker**, and the lab's
is named for the job:

```
$ find tree/times -newer tree/times/marker.txt
tree/times
tree/times/fresh.txt
tree/times/halfhour.txt
```

Newer than the two-hour-old marker: the two
files written after it. The marker itself is
not newer than itself, so it is absent. This
is the shape of a real question — "what
changed since the release tarball was built,"
"what has this directory gained since the
backup stamp" — where a file whose age you
*know* exists and an hour count would only
be a guess. When a search by age surprises
you, re-ask it with `-newer` against a file
whose timestamp you can look at, and the
surprise usually explains itself.

A closing caution that applies to the whole
chapter: every age test is reckoned from the
moment find runs, against clock time on the
machine doing the searching. Files copied
from elsewhere carry the timestamps they were
given; a file can be newer than the program
reading it and older than the event you care
about. find reports the filesystem's opinion
of time, faithfully — whether that opinion
matches history is, as ever, your problem to
notice.
