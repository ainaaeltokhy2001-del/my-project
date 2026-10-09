#!/bin/bash
# Collect per-sample host fraction and join it to dose/sex.
# Spec 2 requires checking host fraction does not correlate with dose,
# since that would propagate into every abundance estimate.
PROJ=${PROJ:-$HOME/selenium}
cd "$PROJ"
printf "run_id\tgroup\tsex\thost_pct\n"
awk -F'\t' 'NR>1{print $1"\t"$2}' 00_meta/ena.tsv | while IFS=$'\t' read -r S alias; do
  log="logs/${S}.host.log"
  [ -f "$log" ] || continue
  pct=$(awk '/overall alignment rate/{gsub("%","",$1); print $1}' "$log")
  a=${alias#Rattus_L_SeMC_}; g=${a%_*}
  printf "%s\t%s\t%s\t%s\n" "$S" "${g%?}" "$([ "${g: -1}" = F ] && echo female || echo male)" "$pct"
done
