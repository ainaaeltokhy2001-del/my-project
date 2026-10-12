#!/bin/bash
# Is the corruption random or systematic?
#  - gzip -t: a 3 GB gzip with random bit errors fails its internal CRC.
#    If it passes, the file is internally consistent and we were served
#    different-but-valid content, which points at a proxy or cache.
#  - Two fetches of the same 20 MB range: differing from each other means
#    random corruption; identical but wrong means something deterministic
#    sits in the path.
PROJ=${PROJ:-$HOME/selenium}
cd "$PROJ" || exit 1
U=https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR370/020/SRR37092220/SRR37092220_1.fastq.gz
echo "host: $(hostname)"

echo "== gzip integrity of the 3 GB file we already have =="
if [ -f dltest.gz ]; then gzip -t dltest.gz && echo "gzip: VALID" || echo "gzip: BROKEN"; else echo "dltest.gz missing"; fi

echo "== same 20 MB range, fetched twice =="
curl -4 -fsS -r 0-20971519 -o r1.bin "$U"; echo "fetch1 exit $?  md5 $(md5sum r1.bin | cut -d' ' -f1)  size $(stat -c%s r1.bin)"
curl -4 -fsS -r 0-20971519 -o r2.bin "$U"; echo "fetch2 exit $?  md5 $(md5sum r2.bin | cut -d' ' -f1)  size $(stat -c%s r2.bin)"
if cmp -s r1.bin r2.bin; then echo "RESULT: identical -> deterministic, not random corruption"; else
  echo "RESULT: differ -> random corruption in transit"; cmp r1.bin r2.bin | head -3; fi
rm -f r1.bin r2.bin
