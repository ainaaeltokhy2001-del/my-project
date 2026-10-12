#!/bin/bash
# Fetch one ENA FASTQ and verify it. Up to 3 attempts: a file that fails
# md5 is deleted and refetched from scratch in the SAME run, because
# curl -C - would otherwise resume a corrupt file and never repair it.
# Args: <ftp-path-without-scheme> <md5>
url=$1; md5=$2
f=$(basename "$url")
for attempt in 1 2 3; do
  if [ -f "$f" ] && [ "$(md5sum "$f" 2>/dev/null | cut -d' ' -f1)" = "$md5" ]; then
    if [ "$attempt" -eq 1 ]; then echo "skip $f"; else echo "OK   $f (attempt $attempt)"; fi
    exit 0
  fi
  curl -fsS --retry 10 --retry-delay 5 -C - -o "$f" "https://$url" || true
  if [ "$(md5sum "$f" 2>/dev/null | cut -d' ' -f1)" = "$md5" ]; then echo "OK   $f"; exit 0; fi
  echo "retry $f (attempt $attempt failed)"
  rm -f "$f"
done
echo "FAIL $f after 3 attempts"
exit 1
