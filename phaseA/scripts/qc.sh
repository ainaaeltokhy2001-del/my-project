#!/bin/bash
# Stage 1: fastp trim + bowtie2 host removal, one sample per array index.
# Submit: bsub -J "qc[1-30]" -q high -n 16 -o logs/qc.%I.out -e logs/qc.%I.err ...
set -e
PROJ=${PROJ:-$HOME/selenium}
MM="$PROJ/bin/micromamba"; ENV="$PROJ/envs/qc"
i=${LSB_JOBINDEX:?LSB_JOBINDEX not set - submit as a job array}
S=$(awk -F'\t' -v n="$i" 'NR==n+1{print $1}' "$PROJ/00_meta/ena.tsv")
[ -n "$S" ] || { echo "no run at index $i"; exit 1; }
cd "$PROJ"

# fastp: --detect_adapter_for_pe infers adapters from read overlap, so it is
# platform-agnostic. This matters here: the data is DNBSEQ-G400 (MGI), and
# BBTools' stock adapter file is Illumina-only (spec 2).
"$MM" run -p "$ENV" fastp \
  -i "01_raw/${S}_1.fastq.gz" -I "01_raw/${S}_2.fastq.gz" \
  -o "02_qc/${S}_1.filt.fq.gz" -O "02_qc/${S}_2.filt.fq.gz" \
  --detect_adapter_for_pe -q 20 -l 51 --cut_tail --trim_poly_g \
  -j "02_qc/${S}.fastp.json" -h "02_qc/${S}.fastp.html" -w 8

# Host removal. --un-conc-gz keeps the pairs that do NOT align to rat.
# SAM goes to /dev/null; the alignment rate we need is on stderr.
"$MM" run -p "$ENV" bowtie2 -x ref/rat \
  -1 "02_qc/${S}_1.filt.fq.gz" -2 "02_qc/${S}_2.filt.fq.gz" \
  --un-conc-gz "02_qc/${S}_%.nohost.fq.gz" \
  -p 16 -S /dev/null 2> "logs/${S}.host.log"

echo "done $S"
