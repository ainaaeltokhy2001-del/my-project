#!/bin/bash
# Find and replace corrupt chunks by consensus.
#
# The link corrupts bytes at random without TCP noticing, so a single fetch
# cannot be trusted. Two independent fetches agreeing on the same bytes can:
# random corruption hitting the same offsets with the same values twice is
# vanishingly unlikely. Each part is fetched again and compared with the copy
# on disk; where they disagree, more fetches are taken until two agree.
#
#   bash repair_parts.sh <url> <outfile> <expected_md5> <expected_size> [chunk]
set -u
URL=$1; OUT=$2; WANT=$3; SIZE=$4; CHUNK=${5:-268435456}
D="${OUT}.parts"
[ -d "$D" ] || { echo "no parts dir $D - run fetch_chunked.sh first"; exit 1; }

N=$(( (SIZE + CHUNK - 1) / CHUNK ))
echo "checking $N parts of $OUT by consensus"
echo

BAD=0
for ((i=0; i<N; i++)); do
  S=$(( i * CHUNK ))
  E=$(( S + CHUNK - 1 )); [ "$E" -ge "$SIZE" ] && E=$(( SIZE - 1 ))
  P="$D/part.$(printf '%04d' $i)"
  T="$P.chk"

  curl -4 -fsS --max-time 1800 -r "${S}-${E}" -o "$T" "$URL" || { echo "part $i: refetch failed"; BAD=1; continue; }

  if cmp -s "$P" "$T"; then
    echo "part $((i+1))/$N  agrees"
    rm -f "$T"
    continue
  fi

  echo "part $((i+1))/$N  DISAGREES - seeking consensus"
  # keep fetching until two copies match each other
  cp "$T" "$P.a"; rm -f "$T"
  got=0
  for try in 1 2 3 4; do
    curl -4 -fsS --max-time 1800 -r "${S}-${E}" -o "$P.b" "$URL" || continue
    if cmp -s "$P.a" "$P.b"; then
      mv -f "$P.a" "$P"; rm -f "$P.b"
      echo "   consensus reached on attempt $try - part replaced"
      got=1; break
    fi
    if cmp -s "$P" "$P.b"; then
      rm -f "$P.a" "$P.b"
      echo "   original agrees with attempt $try - part kept"
      got=1; break
    fi
    mv -f "$P.b" "$P.a"
  done
  rm -f "$P.a" "$P.b"
  [ "$got" -eq 1 ] || { echo "   NO CONSENSUS after 4 tries"; BAD=1; }
done

echo
echo "rejoining..."
cat "$D"/part.* > "$OUT"
echo "size: $(stat -c%s "$OUT")  (expected $SIZE)"
GOT=$(md5sum "$OUT" | cut -d' ' -f1)
echo "md5 : $GOT"
echo "want: $WANT"
if [ "$GOT" = "$WANT" ]; then
  echo ">>> VERIFIED. Removing parts."; rm -rf "$D"; exit 0
fi
echo ">>> still wrong (bad=$BAD). Parts kept."
exit 1
