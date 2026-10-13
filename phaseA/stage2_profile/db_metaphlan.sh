#!/bin/bash
# Install the MetaPhlAn marker database (~5 GB).
# Interactive queue only: high-queue nodes have no outbound internet.
# MetaPhlAn verifies its own downloads, so the corruption on this link is
# caught and retried rather than silently installed.
set -u
PROJ=${PROJ:-$HOME/selenium}
MM="$PROJ/bin/micromamba"; ENV="$PROJ/envs/prof"
DB="$PROJ/db/metaphlan"
mkdir -p "$DB"

[ -d "$ENV" ] || { echo "env missing: $ENV  (run common/setup_envs.sh first)"; exit 1; }
echo "metaphlan $("$MM" run -p "$ENV" metaphlan --version 2>&1 | head -1)"
echo "installing database into $DB"
"$MM" run -p "$ENV" metaphlan --install --bowtie2db "$DB" --nproc 2
rc=$?
echo "exit $rc"
echo
ls -lh "$DB" | head
du -sh "$DB"
