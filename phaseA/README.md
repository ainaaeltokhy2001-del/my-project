# Phase A — PRJNA1417577

Scripts organised by stage. Each folder holds the `.sh` that does the work
and the `.lsf` that submits it.

| Folder | What it does |
|---|---|
| `stage0_retrieval/` | download, checksum-verify, build the rat index |
| `stage1_qc/` | fastp trimming, bowtie2 host removal, host-fraction check |
| `stage2_profile/` | read-based taxonomy *(not written yet)* |
| `stage3_screen/` | selenium marker set and DIAMOND screen *(not written yet)* |
| `diagnostics/` | network fault finding, and the standalone bug reproducer |
| `common/` | environment setup, safe downloads, pulling results to your laptop |
| `00_meta/` | `samples.tsv` — all 30 runs mapped to dose, sex, replicate |

## On the cluster

Everything goes through `bsub`. Never run anything substantial on a login
node — a watchdog kills it.

```bash
cd $PROJ && bsub < stage1_qc/qc.lsf
```

## Getting results back to your laptop

Run `common/pull_results.ps1` **on Windows**, not on the cluster. The
cluster cannot push to you. It copies logs, metadata, QC reports, profile
tables and figures into `D:\project\from-cluster`, and deliberately skips
the 173 GB of raw reads.

## Status

- Stage 0: **complete** — 60/60 files verified against ENA checksums,
  rat bowtie2 index built
- Stage 1: ready to submit
- Stages 2–3: to be written
