#!/bin/bash
#==============================================================================
# Reproducer: silent data corruption on outbound HTTPS downloads
#
# Reported by : alainaa26
# Cluster     : hzauhpc (hpc.ncpgr.cn)
# Affected    : gpu02, via "bsub -q interactive"
#
# SYMPTOM
#   Downloaded files arrive COMPLETE and the correct SIZE, curl exits 0 with
#   no error, but the file contents are WRONG. Only a checksum reveals it.
#   Roughly 1 file in 3 was affected across 60 files / 173 GB.
#
# WHY THIS MATTERS
#   Nothing in the transfer reports a problem. Any user downloading reference
#   data without checksums (most genomics databases ship without per-file
#   md5s) would silently get corrupted data and wrong scientific results.
#
# HOW TO RUN
#   bsub -q interactive -n 1 -o bugreport.out "bash BUGREPORT_download_corruption.sh"
#   ...then compare with a login node:
#   bash BUGREPORT_download_corruption.sh
#
# Takes ~15 min. Downloads ~750 MB. Writes only to $TMPDIR or /tmp.
#==============================================================================
set -u

URL="https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR370/020/SRR37092220/SRR37092220_1.fastq.gz"
RANGE="0-268435455"          # first 256 MB
REPEATS=3
W=$(mktemp -d "${TMPDIR:-/tmp}/dlbug.XXXXXX") || exit 1
trap 'rm -rf "$W"' EXIT

echo "=============================================================="
echo " host      : $(hostname)"
echo " date      : $(date)"
echo " curl      : $(curl --version | head -1)"
echo " workdir   : $W"
echo "=============================================================="
echo
echo "TEST: request the SAME 256 MB byte range $REPEATS times from the same"
echo "      server, and compare. Identical requests must return identical"
echo "      bytes. If the checksums differ, data is being altered in transit."
echo

declare -a SUMS
for i in $(seq 1 $REPEATS); do
  t0=$(date +%s)
  curl -4 -sS --fail --retry 0 -r "$RANGE" -o "$W/copy$i" "$URL"
  rc=$?
  t1=$(date +%s)
  sz=$(stat -c%s "$W/copy$i" 2>/dev/null || echo 0)
  sum=$(md5sum "$W/copy$i" 2>/dev/null | cut -d' ' -f1)
  SUMS[$i]="$sum"
  printf "  attempt %d : curl_exit=%d  %4ds  %10s bytes  md5=%s\n" \
         "$i" "$rc" "$((t1-t0))" "$sz" "${sum:-NONE}"
done

echo
UNIQ=$(printf '%s\n' "${SUMS[@]}" | sort -u | grep -c .)
if [ "$UNIQ" -eq 1 ]; then
  echo "  RESULT: all $REPEATS checksums IDENTICAL on this host."
  echo "          Transfers are reliable here."
else
  echo "  *** RESULT: $UNIQ DIFFERENT checksums from $REPEATS identical requests."
  echo "  *** Data is being corrupted in transit on this host."
  echo
  echo "  Byte-level difference between attempt 1 and attempt 2:"
  ndiff=$(cmp -l "$W/copy1" "$W/copy2" 2>/dev/null | wc -l)
  echo "    $ndiff differing bytes out of 268435456"
  cmp -l "$W/copy1" "$W/copy2" 2>/dev/null | head -5 | \
    awk '{printf "    offset %-12s got \\%s  vs  \\%s\n", $1, $2, $3}'
fi

echo
echo "--- supporting detail ---"
echo "resolved address:"
getent hosts ftp.sra.ebi.ac.uk 2>/dev/null | sed 's/^/  /' || echo "  n/a"
echo "response headers (any proxy/cache in path would show here):"
curl -4 -sSI --max-time 60 "$URL" 2>/dev/null | \
  grep -iE '^HTTP|^via|^x-cache|^server|^age' | sed 's/^/  /'
echo "proxy environment:"
env | grep -iE '_proxy' | sed 's/^/  /' || echo "  none set"

echo
echo "=============================================================="
echo " Observed on this cluster, for reference:"
echo "   - 15 of 60 files failed their published md5 (ENA publishes one"
echo "     per file, which is the only reason this was noticed)"
echo "   - one 3.7 GB file downloaded 3 times gave 3 different checksums,"
echo "     none matching the published value"
echo "   - fetching that file as 14 separate 256 MB range requests, each"
echo "     completing with curl exit 0 at exactly the right length, still"
echo "     produced a corrupt result"
echo "   - throughput on gpu02 ~1 MB/s; on the login node ~4 MB/s"
echo "=============================================================="
