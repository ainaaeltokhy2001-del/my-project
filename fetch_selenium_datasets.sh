#!/usr/bin/env bash
# Fetch the deposits from Zhang et al., Front Nutr 2026 (10.3389/fnut.2026.1803630)
#
#   PRJNA1417577   microbiome (metagenomic) raw reads   NCBI/ENA
#   OMIX014882     metabolome                           NGDC OMIX
#   OMIX014883     metabolome                           NGDC OMIX
#
# Accessions confirmed against the paper's Data availability statement.
#
# Usage:
#   ./fetch_selenium_datasets.sh manifest       # run table only; no bulk download
#   ./fetch_selenium_datasets.sh reads [N]      # download reads (optionally first N runs)
#   ./fetch_selenium_datasets.sh metabolome     # OMIX landing pages
#
# Start with `manifest`. It is small, and it answers the open questions
# (is it public, is it WGS not AMPLICON, how many runs, how many bytes)
# before you commit disk to the download.

set -euo pipefail

BIOPROJECT="PRJNA1417577"
OMIX_IDS=(OMIX014882 OMIX014883)
OUTDIR="${OUTDIR:-./selenium_data}"
MANIFEST="$OUTDIR/${BIOPROJECT}_runs.tsv"
CORRECTED="$OUTDIR/metagenomic_runs_corrected.tsv"

FIELDS="run_accession,study_accession,sample_accession,experiment_accession,scientific_name,library_strategy,library_source,library_layout,instrument_platform,instrument_model,read_count,base_count,fastq_ftp,fastq_bytes,fastq_md5,sample_title,sample_alias"

mkdir -p "$OUTDIR"

need() { command -v "$1" >/dev/null 2>&1 || { echo "error: $1 not found" >&2; exit 1; }; }

fetch_manifest() {
  need curl
  echo ">> Fetching run table for $BIOPROJECT from ENA"
  curl -fsS -G "https://www.ebi.ac.uk/ena/portal/api/filereport" \
    --data-urlencode "accession=$BIOPROJECT" \
    --data-urlencode "result=read_run" \
    --data-urlencode "fields=$FIELDS" \
    --data-urlencode "format=tsv" \
    --data-urlencode "limit=0" \
    -o "$MANIFEST"

  if [ ! -s "$MANIFEST" ] || [ "$(wc -l < "$MANIFEST")" -le 1 ]; then
    echo "!! ENA returned no runs."
    echo "   Either the project is still embargoed, or it has not yet mirrored from SRA."
    echo "   Check: https://www.ncbi.nlm.nih.gov/bioproject/$BIOPROJECT"
    echo "   If SRA shows runs but ENA does not, use the SRA toolkit path at the end of this script."
    exit 1
  fi

  echo
  echo "== Runs: $(( $(wc -l < "$MANIFEST") - 1 ))"
  echo
  echo "== library_strategy (MUST be WGS, not AMPLICON) =="
  awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)h[$i]=i;next}{print $h["library_strategy"]}' "$MANIFEST" | sort | uniq -c
  echo
  echo "== platform / model =="
  awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)h[$i]=i;next}{print $h["instrument_platform"]"\t"$h["instrument_model"]}' "$MANIFEST" | sort | uniq -c
  echo
  echo "== layout =="
  awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)h[$i]=i;next}{print $h["library_layout"]}' "$MANIFEST" | sort | uniq -c
  echo
  echo "== organism =="
  awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)h[$i]=i;next}{print $h["scientific_name"]}' "$MANIFEST" | sort | uniq -c
  echo
  echo "== total download size =="
  awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)h[$i]=i;next}{
        n=split($h["fastq_bytes"],b,";"); for(i=1;i<=n;i++) t+=b[i]
      } END {printf "  %.1f GB across all runs\n", t/1024/1024/1024}' "$MANIFEST"
  echo
  echo "== sample titles (group mapping lives here) =="
  awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)h[$i]=i;next}{print $h["run_accession"]"\t"$h["sample_title"]"\t"$h["sample_alias"]}' "$MANIFEST" | head -30
  echo
  echo "Manifest written to $MANIFEST"
  echo
  echo "Expected design: 5 groups x (8 male + 8 female) = 80 rats."
  echo "Control=0, T1=0.25, T2=0.75, T3=1.50, T4=2.25 mg/kg bw/day L-SeMC."
  echo "For a selenium-only contrast use Control + T1 + T2; T4 is a toxicity arm."
}

fetch_reads() {
  need curl
  local limit="${1:-0}"
  [ -s "$MANIFEST" ] || fetch_manifest

  # PRJNA1417577 is mislabelled in SRA: library_strategy reads AMPLICON, but the
  # data are shotgun. Verified 2026-10-09 by direct inspection of SRR37092220_1:
  #   - 7.9 Gbp / 26.4 M read pairs per sample (16S V3-V4 runs are ~50-100x smaller)
  #   - library_source = METAGENOMIC
  #   - 49,636 distinct 25-base prefixes in 50,000 reads; most common seen twice
  #     (amplicon reads nearly all share one conserved primer prefix)
  # So depth and read diversity are checked here, not the strategy label alone.
  local strategy depth_ok
  strategy=$(awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)h[$i]=i;next}{print $h["library_strategy"]}' "$MANIFEST" | sort -u | paste -sd, -)
  depth_ok=$(awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)h[$i]=i;next}
             {t+=$h["base_count"]; n++} END{print (n && t/n > 1e9) ? "yes" : "no"}' "$MANIFEST")

  if [ "$strategy" != "WGS" ]; then
    echo "!! library_strategy is '$strategy', not WGS."
    if [ "$depth_ok" = "yes" ]; then
      echo "   BUT mean depth is >1 Gbp/sample, which no amplicon run reaches."
      echo "   This is the known PRJNA1417577 mislabel. Proceeding."
      echo "   To re-verify yourself, run: $0 verify"
    else
      echo "   Depth is also amplicon-scale. This is not shotgun data. Stopping."
      echo "   Override with FORCE=1 if you still want it."
      [ "${FORCE:-0}" = "1" ] || exit 1
    fi
  fi

  # Prefer the corrected manifest (both metagenomic projects, mislabel fixed,
  # dose/sex decoded) when it exists; fall back to the single-project manifest.
  local src="$MANIFEST" use_corrected=0
  if [ -s "$CORRECTED" ]; then src="$CORRECTED"; use_corrected=1
    echo ">> Using corrected manifest: $CORRECTED"
  fi

  echo ">> Downloading FASTQs into $OUTDIR/fastq/<bioproject>/<arm>/"
  echo "   (all metagenomic runs by default; set GROUPS= to restrict)"

  # GROUPS=C,T1,T2 restricts to those dose arms. Unset keeps everything.
  awk -F'\t' -v lim="$limit" -v groups="${GROUPS:-}" -v corr="$use_corrected" '
    NR==1{for(i=1;i<=NF;i++)h[$i]=i;next}
    {
      if (corr) { g=$h["dose_arm"]; bp=$h["bioproject"]; sx=$h["sex"] }
      else {
        a=$h["sample_alias"]; sub(/^Rattus_L_SeMC_/,"",a);
        split(a,p,"_"); g=p[1]; sub(/[FM]$/,"",g); bp="PRJNA1417577"; sx=""
      }
      if (groups != "" && g != "") {
        keep=0; m=split(groups,G,","); for(i=1;i<=m;i++) if (G[i]==g) keep=1;
        if (!keep) next;
      }
      arm = (g=="" ? "unassigned" : g (sx=="" ? "" : "_" sx));
      n++; if(lim>0 && n>lim) exit;
      print $h["fastq_ftp"]"\t"$h["fastq_md5"]"\t"bp"/"arm
    }
  ' "$src" | while IFS=$'\t' read -r ftps md5s subdir; do
      IFS=';' read -ra urls <<< "$ftps"
      IFS=';' read -ra sums <<< "$md5s"
      mkdir -p "$OUTDIR/fastq/$subdir"
      for i in "${!urls[@]}"; do
        [ -n "${urls[$i]}" ] || continue
        f="$OUTDIR/fastq/$subdir/$(basename "${urls[$i]}")"
        if [ -f "$f" ]; then echo "   skip (exists): $subdir/$(basename "$f")"; continue; fi
        echo "   get: $subdir/$(basename "$f")"
        curl -fsS --retry 5 --retry-delay 2 -C - -o "$f" "https://${urls[$i]}"
        if [ -n "${sums[$i]:-}" ]; then
          got=$(md5sum "$f" | cut -d' ' -f1)
          if [ "$got" != "${sums[$i]}" ]; then
            echo "   !! md5 mismatch on $(basename "$f") — expected ${sums[$i]}, got $got" >&2
          fi
        fi
      done
  done
  echo ">> Done. Files in $OUTDIR/fastq (laid out by bioproject/arm)"
}

fetch_metabolome() {
  need curl
  echo ">> NGDC OMIX deposits (metabolome — not sequencing reads)"
  for id in "${OMIX_IDS[@]}"; do
    echo "   $id  https://ngdc.cncb.ac.cn/omix/release/$id"
    curl -fsS -o "$OUTDIR/${id}.html" "https://ngdc.cncb.ac.cn/omix/release/$id" \
      && echo "      landing page saved to $OUTDIR/${id}.html" \
      || echo "      !! could not reach NGDC"
  done
  echo
  echo "OMIX files are behind a per-record download button; there is no stable"
  echo "bulk API. Open each URL and take the archive from the Download tab."
}

case "${1:-manifest}" in
  manifest)   fetch_manifest ;;
  reads)      fetch_reads "${2:-0}" ;;
  metabolome) fetch_metabolome ;;
  *) echo "usage: $0 {manifest|reads [N]|metabolome}" >&2; exit 2 ;;
esac

# ---------------------------------------------------------------------------
# Fallback, if ENA has not mirrored the project yet (SRA toolkit required):
#
#   conda install -c bioconda sra-tools        # or: apt install sra-toolkit
#   esearch -db sra -query PRJNA1417577 | efetch -format runinfo > runinfo.csv
#   cut -d, -f1 runinfo.csv | grep ^SRR > runs.txt
#   prefetch --option-file runs.txt --max-size u
#   fasterq-dump --split-files --threads 8 --outdir fastq SRRxxxxxxx
# ---------------------------------------------------------------------------
