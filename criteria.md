# Writing Criteria

Every guide in this repo is written to the same
standard. If you're adding or editing a guide —
human or AI — hold it to these.

1. **Plain words, real ideas.** Simple language,
   never dumbed-down concepts. Explain jargon on
   first use; collect terms in the glossary.
2. **No hype.** No marketing adjectives, no
   "revolutionary," no promises about what
   something will do for the reader.
3. **Honest about limits.** Say what the thing
   *can't* do. State uncertainty instead of
   smoothing it over. Validation notes include
   what remains unverified.
4. **No invented numbers.** Benchmarks, defaults,
   and specs are either measured or qualified with
   "depends on your setup." If it wasn't tested,
   say so.
5. **Checkable.** Commands are meant to be run,
   with "Check:" blocks showing what success looks
   like. Sources are linked, not asserted.
6. **Respect the reader's setup.** Call out
   Windows/Mac/Linux differences. Don't assume a
   GPU, a budget, or prior experience.
7. **Safety isn't skipped.** Real risks get
   stated plainly, not buried.
8. **Scoped.** Each guide says what it covers and
   points elsewhere for the rest. No guide
   pretends to be the whole subject.
9. **Structure over prose.** Tables, before/after
   examples, symptom → fix. Scannable beats essay.

## Verification notes for this guide

Standard 3 and 4 applied to this guide,
specifically. The build machine ran Ubuntu
with **GNU findutils 4.9.0** — both `find`
and `xargs`, the only tools this guide
teaches — plus GNU coreutils `ls`/`sort`
9.4. Every quoted output in the chapters is
a capture from those tools, run against the
specimen tree. Working transcripts are kept
with the build
(`finding-files-lab/transcripts/`).

**The lab.** One tree, built by
`examples/build-tree.sh`, identical on every
rebuild: 51 entries (39 files, 10
directories, 2 symlinks). The specimens are
named in `examples/lab-notes.txt`: eleven
files of exact byte counts (0 through one
byte over 1 MiB), five files of exact
relative ages (0 minutes to 49 hours), two
archive logs backdated to 2023 and 2021,
mixed-case extensions, a space-bearing name
(`meeting notes.txt`), an apostrophe-bearing
one (`o'brien.txt`), a good symlink and a
broken one, an empty file, an empty
directory, and four files whose permission
bits the script sets explicitly (644, 600,
666, 4755). Two fixtures are made by the
chapters themselves: `globtrap/` (chapter 2)
and `tree-del/`, a second build of the tree
that chapters 8 and 10 delete from. A
two-file ownership fixture lives in
`/tmp/owners` for reasons stated below.

**Verified by running, per chapter:**

- *Ch. 1:* both `--version` outputs;
  the unfiltered walk of the tree (all 51
  entries); counts by `-type` (39 f, 10 d,
  2 l); a file as starting point; find with
  no path, walking `.`.
- *Ch. 2:* `-name '*.txt'` (15 matches),
  `-name '*.TXT'` (1), `-iname '*.txt'`
  (16); `-name '*.jpg'` (1) vs `-iname`
  (2); the `?` demo `s???.bin` (exactly the
  three 3-digit sizes); `-path '*/photos/*'`
  (4 entries); `-name 'raw/*'` (no output,
  exit 0); `-name '.*'` (the dotfile only);
  `-type d` and `-type l` in full; the glob
  trap both ways — `echo *.txt`'s expansion
  in the tree's top level, the unquoted
  find erroring with GNU's own hint (exit
  1), and the one-match `globtrap` form
  silently returning only `./solo.txt`
  where the quoted form returns both files.
- *Ch. 3:* the `ls -l` shelf; `-size 1M`
  (9 files plus the directory itself),
  `-size -1M` (the empty file only),
  `-size +1M` (the one-byte-over file only,
  the exact-MiB file excluded), `-size
  1048576c` and `+1048576c` (the same two
  files separated exactly), `-size 1`
  (1–512 bytes, 3 files plus the directory),
  `-size 1k` (1–1024, 6 files plus the
  directory); `-size +1M` across the tree
  (2 entries); the sparse trio — `ls -l`
  2500000, `du -h` 0, `-printf` 2500000 —
  on `big.log`.
- *Ch. 4:* the `ls -lt` cast listing;
  `-mmin -60` (2 files plus the directory)
  and `-mmin +60` (3); `-mtime 0` (3 files
  plus the directory, the 2-hour marker
  included), `-mtime 1` (the 25-hour file),
  `-mtime 2` and `-mtime +1` (the 49-hour
  file only, proving the discarded
  fraction); `-newer` against the marker
  (the two younger files); `-mtime +365`
  over the archive (both backdated logs).
- *Ch. 5:* the `/tmp/owners` listing and
  `-user root` / `-user nobody` /
  `-not -user root` over it; the
  `tree/perms` listing; `-perm -0002`,
  `-perm -4000`, `-perm /6000`, `-perm 600`,
  `-perm 644`, each returning exactly the
  one specimen built for it; and the
  `chown` refusal on the build machine's
  home filesystem, captured verbatim with
  its exit 1 (see Documented-only for why
  the ownership captures live in /tmp).
- *Ch. 6:* the AND chain `-type f -name
  '*.log'` (4); the OR of name tests (2,
  the uppercase JPG absent as the text
  says); `-not -type d` over photos (3);
  the trap in full — `-name '*.txt' -o
  -name '*.md' -print` printing exactly
  one line against the 15-file count by
  `wc -l` — and the parenthesised fix
  printing 16.
- *Ch. 7:* `-maxdepth 1` in full (21
  entries); `-maxdepth 2 -name '*.CR2'`
  (silence, exit 0) against the unlimited
  search (the file, at depth 3);
  `-mindepth 2` over photos (1);
  `-name '*.tmp'` (the 2 cache files);
  the canonical prune printing 37 files
  with no cache entry; and the `-o`-less
  prune printing nothing at all, exit 0.
- *Ch. 8:* `-ls` over the four logs
  (inode, blocks — `big.log` at 0 — and
  dates all as printed); the `-print`
  rehearsal; `-exec echo … \;` (two
  invocations, two lines) against
  `-exec echo … +` (one line, both names);
  `-exec ls -l {} +` over both jpgs; the
  `-ok` run fed `y` then `n` (first
  executed, second skipped, prompts as
  printed); and on the expendable copy
  only: `-delete` of the `.tmp` pair,
  proven by re-running the rehearsal, the
  `emptydir` deletion, and the refusal on
  the non-empty `photos` (real message,
  exit 1). The original tree was
  re-checked intact afterwards.
- *Ch. 9:* `getconf ARG_MAX` (2097152);
  `/bin/true $(seq 1 500000)` refused
  ("Argument list too long", exit 126);
  `seq 1 500000 | xargs -n 10000 echo |
  wc -l` (exactly 50 — the count cap
  binding), and with `-n 100000` exactly
  26 — the size cap binding first, as the
  chapter says; `-n 2` pairing; the naive
  pipeline in full (the quote-parsing
  error, the two split-path errors, 13
  files listed, exit 123); the
  `-print0 | xargs -0` run listing all 15
  with both hostile names intact, exit 0;
  `-I{}` against plain xargs (three
  invocations against one).
- *Ch. 10:* the largest-files pipeline
  (top 5 as printed); the last-hour
  search scoped to `times/`; `-empty`
  (all three specimens); `-type l` (2)
  against `-xtype l` (the broken one
  only); the old-log cleanup on a fresh
  copy — rehearsal naming both backdated
  logs, `-delete`, and `ls` proving
  `recent.log` survived.
- *Ch. 11:* `locate` invoked and absent
  (exit 127); `fdfind --version` (9.0.0);
  `fdfind img` (3 results, case-insensitive
  by smart case); `fdfind txt` (15) set
  against `find -iname '*txt*'` (16), the
  difference being exactly the dotfile, as
  the chapter claims.
- *Ch. 12:* the missing starting point
  (message, exit 1); the no-match silence
  (`-name '*.zzz'`, exit 0); and the
  permission-denied walk run as `nobody`
  against a mode-700 directory — the
  starting point printed, the denial
  reported, exit 1.

**Capture hygiene (declared trims):** some
long listings are shown shortened in the
chapters, always with the count stated in
the text or a bracketed note where the cut
falls: the `find tree` walk in chapter 1
(51 entries), the `-iname` listing in
chapter 2, the prune listing in chapter 7
(37 lines), the two `ls -l` listings in
chapter 9 (13 and 15 files), and the two
`fdfind`/`find` listings in chapter 11 (15
and 16). Nothing was cut silently; the full
captures are in the transcripts. Two quoted
error lines carry the build shell's own
prefix (`bash: line 1: …`, for the ARG_MAX
refusal and the missing `locate`) because
the shells that produced them reported
themselves; the chapters quote them as
captured. Transcript `[exit N]` annotations
are quoted in the chapters only where the
exit code is itself the lesson. The one
mid-task correction: an early xargs capture
mixed a corrected display string with the
uncorrected command; it was retaken in
full, and both `-n` runs above are the
retaken ones.

**Build-machine weather, stated once:** the
lab's home filesystem is an overlay that
assigns new files group `nogroup` and, with
the workspace's umask of 007, mode 660, on
setgid directories of mode 2770. Listing
modes and groups in the chapters are that
machine's weather, except where the build
script sets bits explicitly (the whole of
`tree/perms/`, which is why the `-perm`
captures are exact). Ages in `ls` output
are the capture day's; the script ages
specimens relative to whenever it runs.

**Documented-only (not run), and why:**

- *locate, mlocate/plocate, and updatedb:*
  not installed on the build machine —
  the absence is captured (exit 127) and
  the database behaviour in chapter 11 is
  described from the tools' documentation.
  Nothing about locate's output is quoted.
- *fd's wider language:* `fdfind` 9.0.0 was
  present and two searches were captured to
  show its shape and defaults. Its
  `.gitignore` handling is described, not
  demonstrated (the lab tree is not a git
  checkout), and its full option set is a
  scope decision, recorded here: named,
  placed, not taught.
- *xargs `-P` (parallel runs):* named in
  chapter 9, not run — parallel output is
  interleaved and unordered by design, so
  there is no stable capture to quote, and
  nothing in the guide depends on it.
- *The other timestamp tests:* `-atime`,
  `-ctime`, `-amin`, `-cmin`, `-newermt`,
  and `-daystart` are named with their
  meanings; the mtime family is the one
  exercised. atime on the build machine is
  relatime-governed, so a capture would
  teach the filesystem's laziness, not the
  test.
- *Symbolic `-perm` spellings* (`-perm
  -o+w` and kin): noted in chapter 5 as a
  GNU provision; the octal forms are the
  ones captured, being the spellings that
  read identically across finds.
- *BSD and macOS differences:* GNU-only
  provisions used in this guide are
  `-printf`, `-print0`, `-xtype`, and the
  `/` form of `-perm` (BSD `find` spells
  the any-of test differently and older
  BSDs lack `-printf`). These contrasts
  are stated from the BSD tools'
  documentation; no BSD system was
  available to the build. Everything else
  taught is the common core, run under
  GNU find.
- *Changing ownership:* the build
  machine's home overlay refuses `chown`
  outright, even to root (captured in
  chapter 5). The build script still
  attempts it under `|| true`, so on a
  filesystem that permits it the
  `not-mine.txt` specimen belongs to
  `nobody` as `lab-notes.txt` describes;
  on the build machine it remained the
  builder's, and the `-user` captures
  were made on the `/tmp` fixture, whose
  filesystem permits the change.
- *Installation* on a reader's machine is
  described, not performed; findutils was
  already present.

Specimen discipline, for the record: every
name in the tree is invented, every address
is nobody's, the setuid specimen is a
three-line shell script that is never
executed by any chapter, and the only
deletions in the guide happen inside
purpose-built copies of the lab tree. No
command in the guide was aimed at a real
system directory except the read-only
examples stated as audits, which are shown
as commands to adapt, not transcripts.
