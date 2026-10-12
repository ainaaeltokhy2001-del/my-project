#!/bin/bash
# Same as pull_results.ps1, for Git Bash / WSL / Mac / Linux.
# Run on YOUR LAPTOP, not the cluster.
USER_=alainaa26
HOST_=211.69.141.130      # off campus: 211.69.141.140
PORT=22333                # off campus: 33322
REMOTE=/public/home/alainaa26/selenium
LOCAL=${1:-/mnt/d/project/from-cluster}

mkdir -p "$LOCAL"
echo "pulling into $LOCAL"
for p in 00_meta logs 09_stats scripts; do
  echo -n "  $p"; scp -q -P $PORT -r "${USER_}@${HOST_}:${REMOTE}/$p" "$LOCAL" 2>/dev/null \
    && echo "   ok" || echo "   (nothing yet)"
done
for p in '02_qc/*.json' '02_qc/*.html' '03_profiles/*.tsv' '04_screen/*.tsv' '*.lsf'; do
  echo -n "  $p"; scp -q -P $PORT "${USER_}@${HOST_}:${REMOTE}/$p" "$LOCAL" 2>/dev/null \
    && echo "   ok" || echo "   (nothing yet)"
done
echo; ls -lh "$LOCAL"
