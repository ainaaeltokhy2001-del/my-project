# Start here — running this on your university server

Short guide to getting the selenium data onto your server and checking it is correct.

---

## 1. Get these files

```bash
git clone -b claude/selenium-microbiome-datasets-bin8ou \
  https://github.com/ainaaeltokhy2001-del/my-project.git
cd my-project
```

---

## 2. Check you have enough space

```bash
df -h .
```

You need:

| For | Space |
|---|---|
| Raw files (all 40 samples) | **190 GB** |
| Raw files (just control + T1 + T2) | **105 GB** |
| Assembly and genome binning on top | **500 GB – 1 TB** |

Do not start if you have less than about 250 GB free.

---

## 3. Download

All 40 samples:

```bash
./fetch_selenium_datasets.sh reads
```

Or just the three groups you need for a clean selenium comparison:

```bash
GROUPS=C,T1,T2 ./fetch_selenium_datasets.sh reads
```

Files land in folders by group and sex, like `fastq/PRJNA1417577/T2_female/`.

Every file is checked against its official checksum after downloading. If one is
broken you will see `md5 mismatch` in the output. Just run the command again —
it skips files that are already complete and resumes broken ones.

Run it inside `tmux` or `screen`, or with `nohup`. It takes hours and you do not
want it to die when you log out:

```bash
nohup ./fetch_selenium_datasets.sh reads > download.log 2>&1 &
tail -f download.log
```

---

## 4. IMPORTANT — the data is labelled wrong in the database

**NCBI says these files are `AMPLICON` (16S). They are not. They are real shotgun
metagenomes.**

We proved this by looking at the actual reads:

- Each sample has 7.9 billion bases. A real 16S sample has about 50 million. That is
  150 times more.
- We took 50,000 reads and looked at how they start. 49,636 of them started
  differently. In real 16S data nearly every read starts with the same primer
  sequence.

**Why this matters to you:** many pipelines throw away anything not labelled `WGS`.
If yours does that, it will silently delete this entire dataset and you will think
there was no data. Check for this before you run anything.

The file `selenium_data/metagenomic_runs_corrected.tsv` has the corrected label,
and also keeps the original wrong one so you can show a reviewer what changed.

---

## 5. What the samples are

Rats (Sprague-Dawley), fed L-Se-methylselenocysteine by mouth for 90 days, then
droppings collected. 30 samples sequenced.

| Group | Selenium dose | Samples |
|---|---|---|
| C | none (control) | 6 |
| T1 | 0.25 mg/kg/day | 6 |
| T2 | 0.75 mg/kg/day | 6 |
| T3 | 1.50 mg/kg/day | 6 |
| T4 | 2.25 mg/kg/day | 6 |

Each group is 3 males and 3 females.

**Two warnings about the design:**

1. **Only 3 animals per sex per dose.** That is very few. If you compare males and
   females separately you are comparing 3 against 3, which can easily show a
   difference by pure chance. Treat anything you find there as a hint, not a result.
   Comparing C against T1 against T2 as a trend is safer, because that uses 9 animals
   per sex.

2. **Skip T4 if you want a clean selenium result.** That dose damaged the liver and
   spleen in females. So T4 is showing you selenium poisoning, not normal selenium
   nutrition. C, T1 and T2 are the normal range.

Full list of which file is which animal: `selenium_data/sample_map.tsv`

---

## 6. There is a second dataset too

`PRJNA857801` — 10 samples, 13 GB, also real shotgun selenium data. It downloads
with the same command.

But be careful with it: those mice had breast tumours and were on a high-fat diet.
So you cannot use it to say anything about selenium on its own. It is only useful
as a second opinion — if you find a selenium gene effect in the rats, you can check
whether the same thing shows up here.

---

## 7. What to do first

Before any big analysis, check the data reads correctly:

```bash
# pick any downloaded file
zcat fastq/PRJNA1417577/C_female/SRR37092222_1.fastq.gz | head -8
```

You should see long lines of A, T, G and C that all look different from each other.
If every line starts with the same letters, something is wrong — tell me.

Then the usual order is: clean the reads, remove rat DNA, assemble, bin into
genomes, and finally search for the selenium genes (`selD`, `selA`, `selB`, `selC`,
`selU`, `ybbB`) and the three-gene `sen` cluster.

---

## Files in here

| File | What it is |
|---|---|
| `fetch_selenium_datasets.sh` | The download script |
| `selenium_data/metagenomic_runs_corrected.tsv` | All 40 samples, label fixed, with links |
| `selenium_data/sample_map.tsv` | Which file is which rat, dose and sex |
| `selenium_data/accession_audit.tsv` | Which datasets were labelled right or wrong |
| `selenium_rodent_metagenome_dataset_survey.md` | The full search and everything we ruled out |
