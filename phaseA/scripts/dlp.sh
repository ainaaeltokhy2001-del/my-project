#!/bin/bash
# Fetch all PRJNA1417577 FASTQs, 6 at a time.
# Single-stream ran at 39 MB/min; 6 streams give ~243 MB/min (~12 h for 173 GB).
# Run exactly one instance: two writing the same file corrupt each other.
#   pgrep -c dl_one.sh   -> must be 0 before starting
PROJ=${PROJ:-$HOME/selenium}
cd "$PROJ/01_raw" || exit 1
awk -F'\t' 'NR>1{n=split($4,u,";"); split($5,m,";"); for(i=1;i<=n;i++) print u[i], m[i]}' \
  "$PROJ/00_meta/ena.tsv" | xargs -P 6 -n 2 bash "$PROJ/scripts/dl_one.sh"
echo finished
