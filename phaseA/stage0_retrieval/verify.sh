#!/bin/bash
# Check every expected FASTQ against its ENA md5. Read-only.
PROJ=${PROJ:-$HOME/selenium}
cd "$PROJ/01_raw" || exit 1
awk -F'\t' 'NR>1{n=split($4,u,";"); split($5,m,";"); for(i=1;i<=n;i++) print u[i], m[i]}' \
  "$PROJ/00_meta/ena.tsv" |
while read -r url md5; do
  f=$(basename "$url")
  if [ ! -f "$f" ]; then echo "MISSING $f"
  elif [ "$(md5sum "$f" | cut -d' ' -f1)" = "$md5" ]; then echo "GOOD    $f"
  else echo "CORRUPT $f"; fi
done
