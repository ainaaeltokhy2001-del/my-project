# Working rules for this project

## How to give the user work

**Always hand over a script to submit, never a command to run directly.**
The user runs everything on an IBM LSF cluster and pastes output back.
Claude has no access to that cluster.

- Write `job.lsf` scripts, submit with `bsub < job.lsf`.
- Never suggest `nohup`, `setsid` or `&` for anything substantial.
- Keep pasted blocks small; long heredocs break on copy-paste.
- Put anything not meant to be run in plain text, never in a code block
  — the user runs code blocks, and twice this started duplicate
  downloads that corrupted files.

## The cluster: 作物遗传改良全国重点实验室 (hpc.ncpgr.cn)

### The login-node rule — this is the one that keeps biting

> 请勿在登录节点直接运行大型程序，监控程序会自动查杀
> Do not run large programs on the login node; a monitor kills them automatically.

A watchdog kills large processes on login nodes. It is a direct kill, so
`nohup` and `setsid` do not help. A 173 GB download was killed three
times before this was understood — each time it looked like an SSH
disconnect, and it never was.

Login nodes: login01, login02 (off-campus, port 33322), login03
(10 GbE), mn02. Test with `bsub -q interactive -Is bash`.

### Queues available to this account

`interactive`, `normal`, `high`, `smp`, `q2680v2`.
`parallel` and `short` are restricted — submission is refused.

| Queue | Notes |
|---|---|
| `interactive` | 0 pending, starts at once, max 2 jobs. **Its nodes have internet.** |
| `high` | ~187 pending. 10 GB per core, ≤36 cores. **No internet on its nodes.** |
| `normal` | ~9,400 pending. 5 GB per core, ≤36 cores. Exceeding per-core memory gets the job killed. |
| `smp` | ~1,100 pending, ≤50 cores, "huge memory" |
| `q2680v2` | ≤20 cores; use when others are congested |

**Memory is per core, not per job.** `high -n 16` gives 160 GB, not 11 GB.
To get more memory, ask for more cores.

### Internet access varies by node

Compute nodes on `high` return "Network is unreachable". `gpu02`, via
the `interactive` queue, reached ENA fine. **Anything that downloads
must run on an interactive-queue node**, never on `high` and never on a
login node.

### Environment

No conda, mamba, singularity or apptainer. micromamba is installed at
`$PROJ/bin/micromamba`; run tools with
`micromamba run -p $PROJ/envs/<env> <cmd>`.
`gzip` is old and rejects `-k` — use `gunzip -c in.gz > out`.
No `tmux`. `$PROJ` is `~/selenium`, set in `~/.bashrc`.

Useful: `diskquota`, `bpeek <jobid>`, `bhosts`, `bjobs`, `bkill`.

## Data: PRJNA1417577

30 runs, 173.3 GB gzipped FASTQ, 8.05 Gbases each, 2x150, DNBSEQ-G400.
5 dose arms x 2 sexes x 3 replicates.

**SRA labels it `AMPLICON`. That is wrong — it is shotgun.** Verified on
a 20 MB slice of `SRR37092220_1`: 49,636 distinct 25-mers in 50,000
reads, no primer, 150 bp. A real 16S set checked the same way gave 724,
dominated by the 341F primer. Any filter on `library_strategy == WGS`
silently discards this dataset.

Individual animals, not pools: 30 BioSamples, per-animal IDs in
`isolation_source`, no pooling wording anywhere.

## Download lessons

- Single stream 39 MB/min; 6 parallel streams 243 MB/min.
- **Exactly one download instance at a time.** Two writing the same
  filenames corrupt each other. Check with `pgrep -c curl` — not
  `pgrep -c dl_one.sh`, since orphaned curls outlive their parent.
- A file failing md5 must be deleted and refetched, not resumed:
  `curl -C -` would resume a corrupt file forever.
- Verify with `verify.sh` before trusting data. Files being present is
  not the same as files being correct.
