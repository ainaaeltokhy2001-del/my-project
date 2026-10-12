#!/bin/bash
# Fetch a large file in byte-range chunks, then join and verify.
#
# Why: on this cluster a single long connection gets cut (curl exit 18) after
# roughly 40 minutes. At ~1 MB/s anything over ~2.5 GB cannot finish in one
# request. Each chunk here is its own short request, so no single connection
# needs to survive long enough to be killed.
#
#   bash fetch_chunked.sh <url> <outfile> <expected_md5> <expected_size> [chunk_bytes]
set -u
URL=$1; OUT=$2; WANT=$3; SIZE=$4; CHUNK=${5:-268435456}   # 256 MB default
D="${OUT}.parts"
mkdir -p "$D"

echo "file : $OUT"
echo "size : $SIZE bytes"
echo "chunk: $CHUNK bytes"
N=$(( (SIZE + CHUNK - 1) / CHUNK ))
echo "parts: $N"
echo

for ((i=0; i<N; i++)); do
  S=$(( i * CHUNK ))
  E=$(( S + CHUNK - 1 )); [ "$E" -ge "$SIZE" ] && E=$(( SIZE - 1 ))
  WANTLEN=$(( E - S + 1 ))
  P="$D/part.$(printf '%04d' $i)"

  if [ -f "$P" ] && [ "$(stat -c%s "$P")" -eq "$WANTLEN" ]; then
    echo "part $((i+1))/$N  already complete"; continue
  fi

  ok=0
  for try in 1 2 3 4 5; do
    rm -f "$P"
    t0=$(date +%s)
    curl -4 -fsS --max-time 1800 -r "${S}-${E}" -o "$P" "$URL"; rc=$?
    t1=$(date +%s)
    got=$(stat -c%s "$P" 2>/dev/null || echo 0)
    if [ "$rc" -eq 0 ] && [ "$got" -eq "$WANTLEN" ]; then
      echo "part $((i+1))/$N  ok  $((t1-t0))s  ${got}B"
      ok=1; break
    fi
    echo "part $((i+1))/$N  try $try failed (exit $rc, got ${got}B of ${WANTLEN}B)"
    sleep 5
  done
  [ "$ok" -eq 1 ] || { echo "ABORT: part $i failed 5 times"; exit 1; }
done

echo
echo "joining $N parts..."
cat "$D"/part.* > "$OUT"
FINAL=$(stat -c%s "$OUT")
echo "size: $FINAL  (expected $SIZE)"
GOT=$(md5sum "$OUT" | cut -d' ' -f1)
echo "md5 : $GOT"
echo "want: $WANT"
if [ "$GOT" = "$WANT" ]; then
  echo ">>> VERIFIED. Removing parts."
  rm -rf "$D"
  exit 0
fi
echo ">>> STILL WRONG. Parts kept in $D for inspection."
exit 1
