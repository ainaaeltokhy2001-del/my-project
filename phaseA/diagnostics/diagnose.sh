#!/bin/bash
# Network/transfer diagnostic for the PRJNA1417577 download corruption.
#
# Symptom: files arrive with the correct byte count and curl exit 0, but the
# wrong md5. Retries usually fix it, so the corruption is intermittent.
#
# Run on several nodes and compare:
#   bsub -q interactive -n 1 -o logs/diag.gpu.%J.out "bash scripts/diagnose.sh gpu"
#   bsub -q high        -n 1 -o logs/diag.high.%J.out "bash scripts/diagnose.sh high"
#   bash scripts/diagnose.sh login      # small + quick, safe on a login node
#
# Each section prints PASS/FAIL/INFO so results line up across nodes.

LABEL=${1:-unlabelled}
PROJ=${PROJ:-$HOME/selenium}
U="https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR370/020/SRR37092220/SRR37092220_1.fastq.gz"
RANGE="0-52428799"          # first 50 MB
WORK=$(mktemp -d "${TMPDIR:-/tmp}/diag.XXXXXX") || exit 1
trap 'rm -rf "$WORK"' EXIT

echo "=========================================================="
echo " node   : $(hostname)"
echo " label  : $LABEL"
echo " date   : $(date)"
echo " tmpdir : $WORK   (local disk if /tmp, shared if not)"
echo "=========================================================="

echo
echo "### 1. Is anything sitting in the network path?"
echo "proxy env vars:"
env | grep -iE '_proxy|^no_proxy' || echo "  (none set)"
echo "response headers from ENA:"
curl -4 -sSI --max-time 30 "$U" 2>&1 | grep -iE '^HTTP|^via|^x-cache|^server|^age|^x-forwarded' | sed 's/^/  /'
echo "resolved IP(s):"
getent hosts ftp.sra.ebi.ac.uk | sed 's/^/  /' || echo "  (getent unavailable)"

echo
echo "### 2. Same 50 MB range, fetched 5 times — random or deterministic?"
declare -a SUMS
for i in 1 2 3 4 5; do
  t0=$(date +%s)
  curl -4 -fsS -r "$RANGE" -o "$WORK/r$i" "$U"; rc=$?
  t1=$(date +%s)
  s=$(md5sum "$WORK/r$i" 2>/dev/null | cut -d' ' -f1)
  SUMS[$i]="$s"
  printf "  fetch %d: exit=%d  %5ds  %s  bytes=%s\n" \
     "$i" "$rc" "$((t1-t0))" "${s:-NO_FILE}" "$(stat -c%s "$WORK/r$i" 2>/dev/null || echo 0)"
done
UNIQ=$(printf '%s\n' "${SUMS[@]}" | sort -u | wc -l)
if [ "$UNIQ" -eq 1 ]; then
  echo "  RESULT: all 5 identical -> transfers are reproducible on this node"
else
  echo "  RESULT: $UNIQ different checksums across 5 fetches -> RANDOM CORRUPTION"
fi

echo
echo "### 3. Local disk vs shared filesystem — is it the storage, not the network?"
if [ -d /tmp ] && [ -w /tmp ]; then
  L=$(mktemp /tmp/diagl.XXXXXX)
  curl -4 -fsS -r "$RANGE" -o "$L" "$U"
  echo "  /tmp (local)   : $(md5sum "$L" | cut -d' ' -f1)"
  rm -f "$L"
fi
S="$PROJ/.diag_shared.$$"
curl -4 -fsS -r "$RANGE" -o "$S" "$U"
echo "  \$PROJ (shared) : $(md5sum "$S" | cut -d' ' -f1)"
rm -f "$S"
echo "  (differing checksums between the two would implicate the filesystem)"

echo
echo "### 4. Does a file already on disk still read back the same?"
echo "    Re-reading the same bytes twice tests storage, not the network."
BAD="$PROJ/01_raw/SRR37092226_1.fastq.gz"
if [ -f "$BAD" ]; then
  a=$(md5sum "$BAD" | cut -d' ' -f1)
  b=$(md5sum "$BAD" | cut -d' ' -f1)
  echo "  read 1: $a"
  echo "  read 2: $b"
  [ "$a" = "$b" ] && echo "  PASS: stable on disk (so corruption happened in transit)" \
                  || echo "  FAIL: SAME FILE READS DIFFERENTLY -> storage or memory fault"
  echo -n "  gzip integrity: "; gzip -t "$BAD" 2>&1 && echo "VALID (archive self-consistent)" || echo "BROKEN"
else
  echo "  ($BAD not present, skipping)"
fi

echo
echo "### 5. Where in the stream does it go wrong?"
echo "    Scattered differences suggest the network; one tight cluster suggests memory."
if [ "$UNIQ" -gt 1 ]; then
  cmp -l "$WORK/r1" "$WORK/r2" 2>/dev/null | head -5 | sed 's/^/  byte /'
  n=$(cmp -l "$WORK/r1" "$WORK/r2" 2>/dev/null | wc -l)
  echo "  differing bytes between fetch 1 and 2: $n (of 52428800)"
else
  echo "  (fetches agreed, nothing to compare)"
fi

echo
echo "### 6. Node health"
echo "  load:   $(uptime | sed 's/.*average/average/')"
echo "  memory: $(free -g 2>/dev/null | awk '/Mem:/{print $2" GB total, "$7" GB available"}')"
echo "  disk under \$PROJ:"; df -h "$PROJ" 2>/dev/null | tail -1 | sed 's/^/    /'
echo "  NIC errors (if visible):"
if command -v ip >/dev/null; then
  ip -s link 2>/dev/null | awk '/^[0-9]+:/{d=$2} /errors/{getline; if ($3+$4+0 > 0) print "    "d" errors/dropped: "$3"/"$4}' | head -5
fi
echo
echo "=========== end of report for $LABEL on $(hostname) ==========="
