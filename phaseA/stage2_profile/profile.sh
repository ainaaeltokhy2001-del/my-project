#!/bin/bash
# Stage 2: read-based taxonomic profile, one sample per array index.
# Reads the host-removed pairs from Stage 1.
set -e
PROJ=${PROJ:-$HOME/selenium}
MM="$PROJ/bin/micromamba"; ENV="$PROJ/envs/prof"; DB="$PROJ/db/metaphlan"
i=${LSB_JOBINDEX:?submit as a job array}
S=$(awk -F'\t' -v n="$i" 'NR==n+1{print $1}' "$PROJ/00_meta/ena.tsv")
[ -n "$S" ] || { echo "no run at index $i"; exit 1; }
cd "$PROJ"
mkdir -p 03_profiles

R1="02_qc/${S}_1.nohost.fq.gz"; R2="02_qc/${S}_2.nohost.fq.gz"
[ -s "$R1" ] && [ -s "$R2" ] || { echo "missing QC'd reads for $S"; exit 1; }

"$MM" run -p "$ENV" metaphlan "$R1,$R2" \
  --input_type fastq --bowtie2db "$DB" \
  --bowtie2out "03_profiles/${S}.bt2.bz2" \
  --nproc 16 --unclassified_estimation \
  -o "03_profiles/${S}.metaphlan.tsv"

echo "done $S"
