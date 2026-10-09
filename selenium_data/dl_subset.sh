#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")"
OUT=fastq
fail=0
while IFS=$'\t' read -r run arm gb ftps md5s; do
  mkdir -p "$OUT/$arm"
  IFS=';' read -ra urls <<< "$ftps"
  IFS=';' read -ra sums <<< "$md5s"
  for i in "${!urls[@]}"; do
    [ -n "${urls[$i]}" ] || continue
    f="$OUT/$arm/$(basename "${urls[$i]}")"
    if [ -f "$f" ] && [ "$(md5sum "$f" | cut -d' ' -f1)" = "${sums[$i]}" ]; then
      echo "ok (cached) $f"; continue
    fi
    echo "GET $f"
    curl -fsS --retry 5 --retry-delay 3 -C - -o "$f" "https://${urls[$i]}" || { echo "FAIL $f"; fail=1; continue; }
    got=$(md5sum "$f" | cut -d' ' -f1)
    if [ "$got" = "${sums[$i]}" ]; then echo "ok md5 $f"
    else echo "BAD md5 $f (want ${sums[$i]} got $got)"; fail=1; fi
  done
done < subset4.tsv
echo "DONE fail=$fail"
du -sh "$OUT" 2>/dev/null
