#!/bin/sh
# build-tree.sh — build the specimen tree for
# "Finding Files for Mere Mortals".
#
# Usage:  sh build-tree.sh [directory]
# Default directory: ./tree next to this script.
#
# The tree is deterministic: the same names, the
# same sizes, the same relative ages every time.
# Ages are set relative to the moment you run it
# ("30 minutes ago", "25 hours ago"), so rebuild
# before working through the time chapter if the
# tree has been sitting around.
#
# Running it again deletes and rebuilds the tree
# from scratch. It only ever touches the one
# directory named on its command line.

set -eu

DIR=${1:-tree}
fail() { printf '%s\n' "refusing fixture target: $*" >&2; exit 1; }
# Resolve the existing parent, never follow a target symlink, and require an
# ownership marker before replacing any existing directory.
case $DIR in ''|/|.|..|*/.|*/..) fail "$DIR" ;; esac
DIR=${DIR%/}
[ ! -L "$DIR" ] || fail "symlink $DIR"
parent=$(cd -- "$(dirname -- "$DIR")" && pwd -P) || exit 1
name=$(basename -- "$DIR")
case $name in ''|.|..) fail "$DIR" ;; esac
DIR="$parent/$name"
script_dir=$(cd -- "$(dirname -- "$0")" && pwd -P) || exit 1
cwd=$(pwd -P)
home=$(cd -- "$HOME" && pwd -P) || exit 1
for protected in "$cwd" "$script_dir" "$home"; do
  case "$protected/" in "$DIR/"*) fail "protected directory $DIR" ;; esac
done
marker="$DIR/.mere-mortals-fixture"
if [ -e "$DIR" ]; then
  [ -d "$DIR" ] && [ ! -L "$marker" ] && [ -f "$marker" ] || fail "existing unowned target $DIR"
  [ "$(cat -- "$marker")" = "finding-files-for-mere-mortals:v1" ] || fail "wrong ownership marker in $DIR"
fi
# Refuse overlapping builders. A failed build leaves an unowned directory,
# which must be inspected manually rather than removed on the next run.
lock="$DIR.build-lock"
mkdir -- "$lock" 2>/dev/null || fail "build already active (or stale lock): $lock"
trap 'rmdir -- "$lock"' EXIT
trap 'exit 1' HUP INT TERM
[ ! -e "$DIR" ] || rm -rf -- "$DIR"
mkdir -p "$DIR"/archive "$DIR"/cache "$DIR"/photos/raw \
         "$DIR"/sizes "$DIR"/subdir "$DIR"/times "$DIR"/perms \
         "$DIR"/emptydir

# --- plain files, assorted names and cases -------------------------
printf 'shopping list\neggs\nflour\n'        > "$DIR/notes.txt"
printf 'case matters in extensions\n'       > "$DIR/Notes.TXT"
printf '# quarterly report\nnumbers here\n' > "$DIR/report.md"
printf 'name,score\nada,10\ngrace,9\n'      > "$DIR/data.csv"
printf 'jpeg bytes, honestly just text\n'  > "$DIR/photos/img1.jpg"
printf 'jpeg bytes, honestly just text\n'  > "$DIR/photos/img2.JPG"
printf 'raw sensor bytes, also text\n'     > "$DIR/photos/raw/img3.CR2"
printf 'nested one level down\n'           > "$DIR/subdir/nested.txt"
printf 'you found the hidden file\n'       > "$DIR/.hidden.txt"
printf 'cache junk, safe to delete\n'      > "$DIR/cache/junk1.tmp"
printf 'cache junk, safe to delete\n'      > "$DIR/cache/junk2.tmp"
: > "$DIR/empty.txt"

# --- the hostile names ----------------------------------------------
printf 'an agenda with spaces\n'  > "$DIR/meeting notes.txt"
printf 'an apostrophe in a name\n' > "$DIR/o'brien.txt"

# --- sizes: exact byte counts, including the boundaries -------------
for spec in 's0 0' 's1 1' 's511 511' 's512 512' 's513 513' \
            's1023 1023' 's1024 1024' 's1025 1025' 's1536 1536' \
            's1m 1048576' 's1mplus 1048577'; do
  set -- $spec
  truncate -s "$2" "$DIR/sizes/$1.bin"
done

# a big file for the largest-files recipe; sparse on purpose
truncate -s 2500000 "$DIR/big.log"

# --- times: ages relative to right now -------------------------------
printf 'written just now\n'       > "$DIR/times/fresh.txt"
printf 'written half an hour ago\n' > "$DIR/times/halfhour.txt"
printf 'the reference file\n'     > "$DIR/times/marker.txt"
printf 'written yesterday-ish\n'  > "$DIR/times/yesterday.txt"
printf 'written two days ago\n'   > "$DIR/times/twodays.txt"
touch -d '30 minutes ago' "$DIR/times/halfhour.txt"
touch -d '2 hours ago'    "$DIR/times/marker.txt"
touch -d '25 hours ago'   "$DIR/times/yesterday.txt"
touch -d '49 hours ago'   "$DIR/times/twodays.txt"

printf 'an old log line\n' > "$DIR/archive/recent.log"
printf 'an old log line\n' > "$DIR/archive/old.log"
printf 'an old log line\n' > "$DIR/archive/ancient.log"
touch -d '2023-06-15 12:00' "$DIR/archive/old.log"
touch -d '2021-03-04 12:00' "$DIR/archive/ancient.log"

# --- permissions and owners -------------------------------------------
printf 'readable by everyone, writable too\n' > "$DIR/perms/world-writable.txt"
printf 'owner only\n'                         > "$DIR/perms/secret.txt"
printf '#!/bin/sh\necho a specimen, never run\n' > "$DIR/perms/setuid.sh"
printf 'the ordinary one\n' > "$DIR/perms/normal.txt"
chmod 644 "$DIR/perms/normal.txt"
chmod 666 "$DIR/perms/world-writable.txt"
chmod 600 "$DIR/perms/secret.txt"
chmod 4755 "$DIR/perms/setuid.sh"
# one file owned by somebody else, for the -user chapter
# (works when the builder may chown; the file is otherwise ordinary)
printf 'owned by nobody in particular\n' > "$DIR/perms/not-mine.txt"
chown 65534:65534 "$DIR/perms/not-mine.txt" 2>/dev/null || true

# --- symlinks: one honest, one broken ----------------------------------
ln -s notes.txt         "$DIR/link-good"
ln -s no-such-file.txt  "$DIR/link-broken"

echo "built $DIR"

# Mark only a completed fixture tree as safe for this builder to replace.
printf '%s\n' 'finding-files-for-mere-mortals:v1' > "$marker"
