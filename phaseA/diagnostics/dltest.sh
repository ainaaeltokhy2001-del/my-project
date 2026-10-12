#!/bin/bash
# One controlled download: no retries, no parallelism, curl exit code shown.
PROJ=${PROJ:-$HOME/selenium}
cd "$PROJ" || exit 1
U=ftp.sra.ebi.ac.uk/vol1/fastq/SRR370/020/SRR37092220/SRR37092220_1.fastq.gz
M=64cf07ab8bde0fc1512d01c99e618f4a
rm -f dltest.gz
echo "host: $(hostname)   start: $(date)"
curl -4 -S --retry 0 -o dltest.gz "https://$U"
echo "curl exit code: $?"
echo "end: $(date)"
ls -l dltest.gz
echo "got      $(md5sum dltest.gz | cut -d' ' -f1)"
echo "expected $M"
