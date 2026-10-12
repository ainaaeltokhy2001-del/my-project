#!/bin/bash
# Download a file safely over a link that silently corrupts data.
#
#   bash safe_get.sh <url> [expected_md5]
#
# Three layers of protection, strongest first:
#   1. expected md5, if you pass one or if the server publishes one
#      (tries <url>.md5, and a checksums/md5sum file in the same directory)
#   2. gzip's own CRC, for any .gz / .tgz / .bz2 / .zip - free, no checksum
#      needed, and it is what caught the corrupt FASTQ files here
#   3. download twice and compare - two independent fetches agreeing is
#      strong evidence, since random corruption will not repeat identically
#
# Always fetches in byte-range chunks, because a single long connection on
# this cluster gets cut (curl exit 18) after roughly 40 minutes.
set -u
URL=$1; WANT=${2:-}
OUT=$(basename "${URL%%\?*}")
CHUNK=${CHUNK:-268435456}

say(){ printf '%s\n' "$*"; }

SIZE=$(curl -4 -fsSI --max-time 60 "$URL" | awk 'tolower($1)=="content-length:"{print $2+0}' | tail -1)
[ -n "${SIZE:-}" ] && [ "$SIZE" -gt 0 ] 2>/dev/null || { say "cannot determine size of $URL"; exit 1; }
say "url  : $URL"
say "file : $OUT"
say "size : $SIZE bytes"

# --- layer 1: look for a published checksum -------------------------------
if [ -z "$WANT" ]; then
  for c in "${URL}.md5" "$(dirname "$URL")/md5sum.txt" "$(dirname "$URL")/checksums.txt" "$(dirname "$URL")/MD5SUM"; do
    v=$(curl -4 -fsS --max-time 60 "$c" 2>/dev/null | awk -v f="$OUT" '$0 ~ f {print $1; exit}')
    if [ -n "$v" ]; then WANT=$v; say "found published md5 at $c"; break; fi
  done
fi
[ -n "$WANT" ] && say "md5  : $WANT (will verify)" || say "md5  : none published - will use gzip CRC and/or a second copy"

fetch(){  # fetch <dest>
  local DEST=$1 D="$1.parts" i S E L P rc got
  mkdir -p "$D"
  local N=$(( (SIZE + CHUNK - 1) / CHUNK ))
  for ((i=0;i<N;i++)); do
    S=$(( i*CHUNK )); E=$(( S+CHUNK-1 )); [ "$E" -ge "$SIZE" ] && E=$(( SIZE-1 ))
    L=$(( E-S+1 )); P="$D/p.$(printf '%04d' $i)"
    [ -f "$P" ] && [ "$(stat -c%s "$P")" -eq "$L" ] && continue
    for try in 1 2 3 4 5; do
      rm -f "$P"
      curl -4 -fsS --max-time 1800 -r "${S}-${E}" -o "$P" "$URL"; rc=$?
      got=$(stat -c%s "$P" 2>/dev/null || echo 0)
      [ "$rc" -eq 0 ] && [ "$got" -eq "$L" ] && break
      [ "$try" -eq 5 ] && { say "part $i failed 5x"; return 1; }
      sleep 5
    done
    printf '\r  parts %d/%d' "$((i+1))" "$N"
  done
  printf '\n'
  cat "$D"/p.* > "$DEST"; rm -rf "$D"
}

say "--- downloading ---"
fetch "$OUT" || exit 1

# --- layer 1 check --------------------------------------------------------
if [ -n "$WANT" ]; then
  GOT=$(md5sum "$OUT" | cut -d' ' -f1)
  if [ "$GOT" = "$WANT" ]; then say "PASS: md5 matches"; exit 0; fi
  say "FAIL: md5 $GOT != $WANT"; exit 1
fi

# --- layer 2: the file's own integrity check ------------------------------
case "$OUT" in
  *.gz|*.tgz)  if gzip -t "$OUT" 2>/dev/null; then
                 say "PASS: gzip CRC valid (no published md5, but the archive checks out)"
                 md5sum "$OUT"; exit 0
               else say "FAIL: gzip CRC error - file is corrupt"; exit 1; fi ;;
  *.bz2)       if bzip2 -t "$OUT" 2>/dev/null; then say "PASS: bzip2 CRC valid"; exit 0
               else say "FAIL: bzip2 CRC error"; exit 1; fi ;;
  *.zip)       if unzip -tq "$OUT" >/dev/null 2>&1; then say "PASS: zip CRC valid"; exit 0
               else say "FAIL: zip CRC error"; exit 1; fi ;;
esac

# --- layer 3: second opinion ---------------------------------------------
say "--- uncompressed and no checksum: fetching a second copy to compare ---"
fetch "$OUT.second" || exit 1
if cmp -s "$OUT" "$OUT.second"; then
  rm -f "$OUT.second"; say "PASS: two independent downloads agree"
  md5sum "$OUT"; exit 0
fi
say "FAIL: the two copies differ - the link corrupted at least one"
exit 1
