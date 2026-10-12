#!/bin/bash
# Build the bowtie2 index for host removal (rat, mRatBN7.2).
# Compute nodes have no internet, so this runs after the genome is on disk.
# Note: the reference is NOT masked, a documented deviation from JGI (spec 2).
PROJ=${PROJ:-$HOME/selenium}
cd "$PROJ/ref" || exit 1
gunzip -kf Rattus_norvegicus.mRatBN7.2.dna.toplevel.fa.gz
"$PROJ/bin/micromamba" run -p "$PROJ/envs/qc" bowtie2-build --threads 16 \
  Rattus_norvegicus.mRatBN7.2.dna.toplevel.fa rat
echo "index done"
