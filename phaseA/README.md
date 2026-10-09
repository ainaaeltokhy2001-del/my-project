# Phase A — PRJNA1417577 (Stages 0–3)

Cluster: IBM LSF, submit with `bsub` (not `sbatch`). Queue **high**
(no hard memory cap; `normal` has 9,000+ pending). Compute nodes have
36 cores / 384 GB.

**Compute nodes have no outbound internet.** Downloads run on the login
node; everything else runs in jobs.

## Layout on the cluster

    $PROJ = ~/selenium
      00_meta/ena.tsv        ENA run table (30 runs)
      01_raw/                FASTQ, 173 GB, 60 files
      ref/                   mRatBN7.2 + bowtie2 index
      envs/qc/               fastp, bowtie2, samtools, seqkit
      bin/micromamba         no conda on this cluster
      scripts/ logs/

## Scripts

| Script | Runs on | Notes |
|---|---|---|
| `dlp.sh` | login node | 6 parallel streams, ~12 h. **One instance only.** |
| `dl_one.sh` | — | worker; md5-verifies, deletes bad files to force refetch |
| `idx.sh` | compute (`bsub -q high -n 16`) | bowtie2 index, 1–3 h |

Start a download with `nohup bash scripts/dlp.sh > logs/dlp.log 2>&1 &`
— single `&`, nothing after it. Check `pgrep -c dl_one.sh` is 0 first.
Two concurrent instances corrupt the same files.

## Deviations from the spec, recorded

- **bowtie2, not bbmap**, for host removal: ~4 GB versus ~16 GB index.
  Spec §3 names bowtie2 as its own fallback.
- **Reference not masked**, unlike JGI. Slightly more aggressive host
  removal; the §2 host-fraction-versus-dose check will catch any damage.
- **`bbcms` skipped in Phase A.** Its output feeds metaSPAdes in §5
  (Phase B) only; Stages 2 and 3 read the `.nohost` files.

## Already settled (§1 blockers)

- **AMPLICON flag is wrong — the data is shotgun.** 49,636 distinct
  25-mers in 50,000 reads of `SRR37092220_1`, no primer, 150 bp. A real
  16S set tested the same way gave 724, dominated by the 341F primer.
- **Individual animals, not pools.** 30 BioSamples, per-animal IDs in
  `isolation_source` (`Sprague-Dawley Rattus_T4F1`), no pooling wording.
  3 per group×sex cell. So §9 inference stands, with n=3 per cell.
- **Size:** 173.3 GB of gzipped FASTQ (ENA), not the 143 GB in §1 —
  that figure is the `.sra` archive size.
