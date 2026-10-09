#!/bin/bash
# Download one ENA FASTQ and verify it. Deletes the file on checksum
# failure so the next pass refetches cleanly instead of resuming a
# corrupt file. Args: <ftp-path-without-scheme> <md5>
url=$1; md5=$2
f=$(basename "$url")
if [ -f "$f" ] && [ "$(md5sum "$f" | cut -d' ' -f1)" = "$md5" ]; then echo "skip $f"; exit 0; fi
curl -fsS --retry 10 --retry-delay 5 -C - -o "$f" "https://$url" || { echo "FAIL $f"; exit 1; }
if [ "$(md5sum "$f" | cut -d' ' -f1)" = "$md5" ]; then
  echo "OK   $f"
else
  echo "BAD  $f (deleted, will refetch)"; rm -f "$f"
fi
