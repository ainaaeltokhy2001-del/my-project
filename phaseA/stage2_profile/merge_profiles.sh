#!/bin/bash
# Merge the 30 MetaPhlAn tables into one matrix and attach dose/sex,
# so the result is directly usable for the Stage 8 statistics.
set -u
PROJ=${PROJ:-$HOME/selenium}
MM="$PROJ/bin/micromamba"; ENV="$PROJ/envs/prof"
cd "$PROJ/03_profiles" || exit 1

n=$(ls -1 *.metaphlan.tsv 2>/dev/null | wc -l)
echo "found $n profile tables (expect 30)"
[ "$n" -gt 0 ] || exit 1

"$MM" run -p "$ENV" merge_metaphlan_tables.py *.metaphlan.tsv > merged_abundance.tsv
echo "wrote merged_abundance.tsv  ($(wc -l < merged_abundance.tsv) rows)"

# species-level only, which is what the statistics use
awk 'NR==1 || /s__/ && !/t__/' merged_abundance.tsv > merged_species.tsv
echo "wrote merged_species.tsv    ($(( $(wc -l < merged_species.tsv) - 1 )) species)"

# sample -> dose/sex key, so nothing downstream has to re-derive it
# samples.tsv columns: 1 run_id  2 sample_id  3 biosample  4 sex  5 group
#                      6 dose_mg_kg  7 dose_ordinal  8 replicate
awk -F'\t' 'NR==1{print "sample_id\trun_id\tgroup\tsex\tdose_ordinal\treplicate"; next}
  {print $2"\t"$1"\t"$5"\t"$4"\t"$7"\t"$8}' "$PROJ/00_meta/samples.tsv" > sample_key.tsv
echo "wrote sample_key.tsv"
