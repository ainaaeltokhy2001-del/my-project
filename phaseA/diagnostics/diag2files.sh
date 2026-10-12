#!/bin/bash
# Why do SRR37092226_1 and SRR37092228_1 keep failing? One node, one job.
#
# For each file: check what is on disk, fetch a fresh copy, and compare the
# two. Where and how they differ says what is breaking.
PROJ=${PROJ:-$HOME/selenium}
cd "$PROJ/01_raw" || exit 1
BASE=https://ftp.sra.ebi.ac.uk/vol1/fastq

echo "node $(hostname)   $(date)"
echo

check() {
  local F=$1 URL=$2 WANT=$3 SIZE=$4
  echo "=================================================================="
  echo "$F"
  echo "  expected md5  $WANT"
  echo "  expected size $SIZE"
  echo "------------------------------------------------------------------"

  if [ -f "$F" ]; then
    local have_size have_md5 have_md5b
    have_size=$(stat -c%s "$F")
    echo "  on disk size  $have_size   $( [ "$have_size" = "$SIZE" ] && echo '(correct)' || echo "(WRONG, off by $((have_size-SIZE)))" )"
    have_md5=$(md5sum "$F" | cut -d' ' -f1)
    have_md5b=$(md5sum "$F" | cut -d' ' -f1)
    echo "  on disk md5   $have_md5"
    if [ "$have_md5" != "$have_md5b" ]; then
      echo "  *** SAME FILE READ TWICE GAVE DIFFERENT MD5 -> storage/memory fault, not the download"
      echo "      second read: $have_md5b"
    fi
    echo -n "  gzip test     "; gzip -t "$F" 2>&1 && echo "VALID" || true
    echo -n "  last good byte (where the archive breaks): "
    gzip -dc "$F" 2>/dev/null | wc -c
  else
    echo "  not on disk"
  fi

  echo "  --- fetching a fresh copy to ${F}.new ---"
  rm -f "${F}.new"
  local t0 t1 rc
  t0=$(date +%s)
  curl -4 -fsS -o "${F}.new" "$URL"; rc=$?
  t1=$(date +%s)
  local nsize nmd5
  nsize=$(stat -c%s "${F}.new" 2>/dev/null || echo 0)
  nmd5=$(md5sum "${F}.new" 2>/dev/null | cut -d' ' -f1)
  echo "  curl exit $rc   $((t1-t0))s   size $nsize   md5 $nmd5"

  if [ "$nmd5" = "$WANT" ]; then
    echo "  >>> FRESH COPY IS GOOD. Replacing the bad one."
    mv -f "${F}.new" "$F"
    return 0
  fi

  echo "  >>> fresh copy also wrong."
  if [ -f "$F" ]; then
    echo "  --- comparing old copy vs new copy ---"
    if cmp -s "$F" "${F}.new"; then
      echo "  identical to each other -> deterministic: the server or path always"
      echo "  returns this same content. Not random corruption."
    else
      local n first
      n=$(cmp -l "$F" "${F}.new" | wc -l)
      first=$(cmp -l "$F" "${F}.new" | head -1 | awk '{print $1}')
      echo "  differ in $n bytes; first difference at byte $first of $SIZE"
      echo "  (a few scattered bytes -> random corruption;"
      echo "   everything after one point -> truncation/restart mid-stream)"
      cmp -l "$F" "${F}.new" | head -5 | sed 's/^/    byte /'
    fi
  fi
  echo "  (fresh copy kept as ${F}.new for inspection)"
  return 1
}

check SRR37092226_1.fastq.gz \
  "$BASE/SRR370/026/SRR37092226/SRR37092226_1.fastq.gz" \
  f4cee31b35638790600a279dc185d89f 2882251538

check SRR37092228_1.fastq.gz \
  "$BASE/SRR370/028/SRR37092228/SRR37092228_1.fastq.gz" \
  1b79f5ba334d8c56b1ec88b23c5fe19b 3695678224

echo
echo "=== done ==="
