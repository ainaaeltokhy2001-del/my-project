#!/bin/bash
# Create the conda environments Phase A needs. Idempotent: skips what exists.
#
# Must run on a node with internet, so the interactive queue, not high.
# conda packages carry their own sha256, so the link corruption here is
# caught and retried by micromamba rather than slipping through.
set -u
PROJ=${PROJ:-$HOME/selenium}
MM="$PROJ/bin/micromamba"
CH="-c conda-forge -c bioconda"

[ -x "$MM" ] || { echo "micromamba missing at $MM"; exit 1; }
echo "micromamba $("$MM" --version)"
echo

mk(){ # mk <name> <packages...>
  local n=$1; shift
  if [ -d "$PROJ/envs/$n" ]; then
    echo "== $n already exists, skipping"
    return
  fi
  echo "== creating $n: $*"
  "$MM" create -y -p "$PROJ/envs/$n" $CH "$@" || { echo "FAILED: $n"; return 1; }
}

# Stage 1 - trimming and host removal
mk qc      fastp bowtie2 samtools seqkit

# Stage 2 - read-based taxonomy and function
mk prof    metaphlan

# Stage 3 - marker set construction and the DIAMOND screen
mk screen  diamond hmmer mafft trimal seqkit

# reporting
mk report  multiqc

echo
echo "=============== installed ==============="
for e in "$PROJ"/envs/*/; do
  n=$(basename "$e")
  printf "%-8s " "$n"
  case $n in
    qc)     "$MM" run -p "$e" fastp --version 2>&1 | head -1 ;;
    prof)   "$MM" run -p "$e" metaphlan --version 2>&1 | head -1 ;;
    screen) "$MM" run -p "$e" diamond --version 2>&1 | head -1 ;;
    report) "$MM" run -p "$e" multiqc --version 2>&1 | head -1 ;;
    *)      echo ;;
  esac
done
echo
echo "versions recorded to logs/versions.txt"
mkdir -p "$PROJ/logs"
{ date; for e in "$PROJ"/envs/*/; do echo "--- $(basename "$e") ---"; "$MM" list -p "$e" 2>/dev/null | tail -n +4; done; } \
  > "$PROJ/logs/versions.txt"
echo "done"
