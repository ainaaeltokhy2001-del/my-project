# Public shotgun metagenomic datasets for dietary selenium × rodent gut microbiome

**Survey date:** 2026-09-28
**Research question:** rodent (mouse/rat) gut shotgun metagenomes where dietary selenium status is the only major experimental variable.
**Downstream purpose:** Se-responsive taxa, functional profiling, MAG reconstruction, Se-metabolism gene search (`selD`/`selA`/`selB`/`selC`/`selU`/`ybbB`, Se transport & reduction), and BGC genome mining for `sen`-like (selenoneine) clusters.

---

## 0. Read this first — verification status and environment limitation

The task required verifying that raw data are publicly downloadable. **I could not complete that
verification step in this session**, and nothing below should be treated as a confirmed accession.

This container's network egress policy denied every repository and publisher host:

| Host | Purpose | Result |
|---|---|---|
| `eutils.ncbi.nlm.nih.gov` | SRA / BioProject E-utilities | `403` at proxy CONNECT |
| `www.ebi.ac.uk` | ENA Portal API | egress blocked |
| `www.ncbi.nlm.nih.gov`, `pmc.ncbi.nlm.nih.gov` | BioProject/SRA web, full texts | egress blocked |
| `qiita.ucsd.edu` | Qiita | egress blocked |
| `api.mg-rast.org`, `www.mg-rast.org` | MG-RAST | egress blocked |
| `api.crossref.org`, `europepmc.org` | DOI/metadata resolution | egress blocked |
| `example.com` (control) | — | egress blocked |

Only Anthropic's server-side web search was usable. That is enough to **screen the literature** and
decide which studies are structurally eligible, but **not** enough to:

- resolve a paper's Data Availability statement to an accession,
- confirm an accession is public rather than embargoed/private,
- read `run` / `library_strategy` / `library_layout` per sample,
- confirm object sizes or that FASTQs actually download.

**To finish the job**, broaden *Network access* in the environment settings (cloud environment menu
in the session title bar → Edit), or allowlist at minimum:
`eutils.ncbi.nlm.nih.gov`, `www.ebi.ac.uk`, `ftp.sra.ebi.ac.uk`, `pmc.ncbi.nlm.nih.gov`,
`qiita.ucsd.edu`, `api.mg-rast.org`. Access levels are documented at
<https://code.claude.com/docs/en/claude-code-on-the-web>. §5 holds ready-to-run verification
commands that will complete in minutes once unblocked.

---

## 1. Headline finding

**No published dataset currently satisfies all of your strict criteria with verified public shotgun
data.** The constraint that bites is not selenium — it is the intersection of *selenium-only
intervention* × *rodent* × *shotgun metagenomics* × *public raw reads*.

Three structural facts about this literature:

1. **The rodent selenium–microbiome field is 16S-dominated.** Nearly every Se-only dietary design in
   mice (including the canonical Se-deficient / Se-sufficient / Se-enriched three-arm studies) was
   profiled by amplicon sequencing, and the functional claims were made with PICRUSt2/Tax4Fun
   *predictions* — not real shotgun data. These fail your sequencing criterion outright.
2. **Where real shotgun metagenomics appears, selenium is confounded** with a second major
   variable — tumour models, high-fat diet, antibiotic depletion, viral infection, or live
   probiotic administration — which fails your experimental-exclusion criteria.
3. **A large fraction of Se × gut-metagenome work is in production animals** (broilers, laying hens,
   weaned piglets), excluded by your organism criterion.

The single best structural match found is a **Sprague–Dawley rat** dose–response study (§2, Candidate 1):
selenium compound as the only intervention, five groups, vehicle control, fecal sampling, and
*actual metagenomic sequencing*. Its accession is unverified.

---

## 2. Candidate datasets, screened

Confidence uses your A/B/C scheme. Every "sequencing" and "accession" cell is **literature-reported,
not repository-verified** — see §0.

### Candidate 1 — L-Se-methylselenocysteine dose–response in rats ← best match

| Field | Value |
|---|---|
| Title | Gender-specific and dose-dependent responses to L-Se-methylselenocysteine are mediated by the gut microbiota-metabolite axis: implications for intestinal homeostasis and safe clinical application |
| Journal / year | Frontiers in Nutrition, 2026 |
| DOI | `10.3389/fnut.2026.1803630` |
| PMID | `41939187` |
| PMC | `PMC13045510` |
| Organism | *Rattus norvegicus*, Sprague–Dawley, SPF |
| Sex | Both, equal numbers |
| n | 80 rats, 5 groups (→ ~16/group, 8 M + 8 F) |
| Sample type | Fresh feces, collected day 90 |
| Se form | L-Se-methylselenocysteine (L-SeMC), organic |
| Dose | 0.25 – 0.75 mg/kg bw/day (graded), + vehicle control |
| Route | Oral gavage |
| Duration | 90 consecutive days |
| Sequencing | **Metagenomic sequencing** of fecal DNA; taxonomic + functional (pathway/enzyme) annotation |
| Accession | **NOT ESTABLISHED.** Not surfaced in search. Chinese-affiliated work often deposits to CNCB-NGDC GSA (`CRA######`) rather than SRA — check both |
| Platform / read length / layout | **Unknown** — needs repository lookup |

**Confidence: B (medium–high), promotable to A on accession verification.**

Why B and not A:
- Selenium *is* the only intervention and there is a proper vehicle control — this is exactly your
  "control vs Se supplementation" design, with dose–response as a bonus for dose-dependent gene-abundance modelling.
- **Caveat 1:** framed as a *90-day chronic toxicity* study. The top dose is supra-nutritional, so the
  high-dose arm probes Se excess/toxicity rather than nutritional repletion. Your exclusion list names
  "toxins" — I read that as excluding *exogenous* toxicants, not the Se compound under study, so I kept
  it. If you want strictly nutritional range, use the lower-dose arms and control.
- **Caveat 2:** oral gavage, not dietary incorporation. Dietary Se concentration (mg Se/kg chow) is
  therefore not the exposure metric; base diet Se background is unreported in what I could see.
- **Caveat 3:** sex is a deliberate second variable (the paper's point is sex-specificity). Good for
  power if you model sex; needs stratification.
- **Caveat 4:** rat, not mouse — relevant if you intend to reuse mouse MAG catalogues.

**Action:** pull `PMC13045510` Data Availability, then resolve in SRA **and** NGDC GSA.

---

### Candidate 2 — Kasaikina et al., dietary Se and host selenoproteome

| Field | Value |
|---|---|
| Title | Dietary selenium affects host selenoproteome expression by influencing the gut microbiota |
| Journal / year | The FASEB Journal, 2011 |
| DOI | `10.1096/fj.11-181990` |
| PMID | `21493887` |
| Organism | *Mus musculus* |
| Design | **Three arms: Se-deficient / Se-sufficient / Se-enriched** — textbook match to your ideal |
| Sample type | Gut/intestinal microbiota |
| Sequencing | "High-throughput sequencing" of community composition — 2011-era, i.e. **16S amplicon (454-class), not shotgun** |
| Accession | Not established; pre-dates routine SRA deposition mandates. Data may never have been deposited |

**Confidence: C (not recommended for your purpose)** — excluded on the sequencing criterion, and
likely on data availability too.

Keep it anyway as the **design template and biological prior**: it is the origin of the finding that
Se availability shifts community composition and that microbiota compete with the host for Se. Its
reported Se-responsive taxa are your positive-control expectation set when you analyse Candidate 1.

---

### Candidate 3 — Organic Se intervention, breast-cancer mice on high-fat diet

| Field | Value |
|---|---|
| Title | The role of selenium intervention in gut microbiota homeostasis and gene function in mice with breast cancer on a high-fat diet |
| Year | 2024 |
| PMC | `PMC11322145` |
| Organism | *Mus musculus* |
| Sample type | Feces |
| Sequencing | **True shotgun metagenomic sequencing** + gene/pathway annotation |
| Se form | Organic selenium |
| Reported effect | ↑ Proteobacteria, Actinobacteria, Verrucomicrobia under Se |
| Accession | Not established |

**Confidence: C by your criteria** — trips **two** exclusions (cancer model, high-fat diet).

But note honestly: this is one of the very few *real* rodent Se metagenomes. The Se vs no-Se contrast
is internally controlled **within** the HFD+tumour background, so if Candidate 1's data prove
unavailable, this is the fallback for gene-level Se-response signal — with the caveat that anything
you find is conditioned on tumour + HFD and cannot be presented as a clean dietary-Se effect. Treat
as hypothesis-generating only.

---

### Candidate 4 — Se supplementation ± antibiotic microbiota depletion (Huelva/Ferrer group series)

| Field | Value |
|---|---|
| Representative titles | *Untargeted Gut Metabolomics to Delve the Interplay between Selenium Supplementation and Gut Microbiota* (J Proteome Res 2021, `10.1021/acs.jproteome.1c00411`, `PMC8902802`); *Impact of Antibiotic-Induced Depletion of Gut Microbiota and Selenium Supplementation…* (J Agric Food Chem, `10.1021/acs.jafc.1c02622`, `PMC9161447`); *Selenium supplementation influences mice testicular selenoproteins driven by gut microbiota* (`PMC8913620`); *The role of selenium in shaping mice brain metabolome and selenoproteome through the gut-brain axis* (PMID `36958417`) |
| Organism | *Mus musculus*, BALB/c, male |
| Diet | Control **0.20 mg Se/kg chow** vs Se-enriched **0.65 mg Se/kg chow** — clean, well-specified nutritional contrast |
| Sample type | Feces / gut content |
| Sequencing | **16S rRNA amplicon only**; the omics depth is metabolomics/metallomics, not metagenomics |
| Data | Metabolomics deposited (MassIVE `MSV000087829`; a Zenodo record also exists, `zenodo.org/records/17486460`) — **metabolomics, not reads** |

**Confidence: C** — fails sequencing criterion; the antibiotic arms independently fail your exclusions.

Still the most useful **methods reference** in the set: it gives you a defensible dietary Se design
(0.20 vs 0.65 mg/kg chow) if you end up generating your own shotgun data.

---

### Candidate 5 — Se deficiency in aged telomere-humanized diabetic mice

| Field | Value |
|---|---|
| Title | Dietary Selenium Deficiency Accelerates the Onset of Aging-Related Gut Microbial Changes in Aged Telomere-Humanized Mice, With *Akkermansia muciniphila* Being the Most Prominent and Alleviating Selenium Deficiency-Induced Type 2 Diabetes |
| Journal / year | Aging Cell, 2025;24(8):e70130 |
| DOI | `10.1111/acel.70130` |
| PMID | `40540389` |
| PMC | `PMC12341817` |
| Organism | *Mus musculus*, **telomere-humanized C57BL/6J**, diabetic; both sexes (sexually dimorphic result) |
| Intervention | Dietary Se deficiency vs adequate |
| Sequencing | **Unverified** — not established from search; likely amplicon |
| Accession | Not established |

**Confidence: C.** The Se-deficiency contrast is on-target, but the model is a **genetically modified
animal** (your explicit exclusion) carrying a **metabolic-disease** phenotype (second exclusion), and
ageing is a co-variable. Worth one verification lookup only because Se-deficiency arms are scarce —
if it turns out to be shotgun, it moves to a heavily-caveated B/C boundary.

---

### Candidates 6–10 — screened out on intervention confounds

| # | Study | Organism | Why excluded |
|---|---|---|---|
| 6 | Effects of selenomethionine on intestinal microbiota … mice infected with **porcine deltacoronavirus** (Front Microbiol 2025, PMID `40980322`, `PMC12446368`) | mouse | **Infection model** |
| 7 | Dietary supplementation with novel **selenium-enriched *Pichia kudriavzevii*** regulates gut microbiota and host metabolism in mice (PMID `39417221`) | mouse | Live yeast = **probiotic**; Se and organism-vector inseparable |
| 8 | Comparative Study on the Effects of Selenium-Enriched Yeasts with Different Selenomethionine Contents (IJMS 2025, `10.3390/ijms26073315`, `PMC11989349`) | — | **16S rRNA only**; yeast-matrix comparison, not dietary Se dose |
| 9 | ***Ruminococcus torques*** Administration … in Selenium-deficient Mature Female Mice (Biol Trace Elem Res, `10.1007/s12011-026-05106-5`; `PMC12622185`) | mouse | **Bacterial administration** (probiotic) + glucose-intolerance endpoint |
| 10 | Se- and Zn-enriched ***Lactobacillus plantarum* SeZi** in ICR mice (`PMC7589369`) | mouse | **Probiotic**; Se confounded with Zn |

Also excluded wholesale on **organism**: the substantial Se × cecal-microbiome literature in
**broilers**, **laying hens**, and **early-weaned piglets** (e.g. `10.1093/jas/skag159`,
`PMC13260863`, `PMC12674293`, `PMC11837603`, `PMC10665811`).

---

## 3. Repository coverage achieved

| Repository | Searched | Result |
|---|---|---|
| NCBI SRA / BioProject | ✗ API blocked | No direct query possible; nothing verified |
| ENA | ✗ API blocked | Same |
| MG-RAST | ✗ blocked | Same. *Prior expectation: MG-RAST holds legacy 454/amplicon rodent sets; a Se-only rodent shotgun study there is unlikely but unchecked* |
| Qiita | ✗ blocked | Same. *Qiita is predominantly 16S/EMP-derived; low prior for shotgun Se rodent data* |
| CNCB-NGDC GSA | ✗ blocked | **Highest-priority unchecked repository** — most likely home of Candidate 1 |
| Literature (server-side web search) | ✓ | Basis for all of §2 |

**No repository was successfully queried.** §2 is a literature screen, not a repository search.

---

## 4. Sample metadata table

The per-sample table you requested (`Sample ID | Animal | Group | Selenium condition | Sample type | Accession`)
**cannot be populated for any candidate.** Per-sample IDs and run accessions live in SRA/ENA/GSA
run tables, which were unreachable. Fabricating plausible-looking accessions would be worse than
leaving this empty.

Expected shape once Candidate 1 resolves (**illustrative structure only — no real values**):

| Sample ID | Animal | Group | Selenium condition | Sample type | Accession |
|---|---|---|---|---|---|
| *from GSA/SRA run table* | rat, SD, M/F | control / low / mid / high / (5th) | vehicle; 0.25–0.75 mg/kg bw/d L-SeMC | feces, day 90 | `CRA…`/`SRR…` |

---

## 5. Resume-here verification script

Once egress is opened, run these in order. Steps 1–2 are decisive for Candidate 1.

```bash
# 1. Candidate 1 Data Availability statement -> accession
#    (also check the Frontiers HTML, which often carries it when PMC does not)
curl -sS "https://pmc.ncbi.nlm.nih.gov/articles/PMC13045510/" \
  | grep -iEo '(PRJ[NED][A-Z]?[0-9]+|CRA[0-9]{6,}|SRP[0-9]+|GSE[0-9]+|MSV[0-9]+)' | sort -u

# 2. If Chinese deposition: CNCB-NGDC GSA
curl -sS "https://ngdc.cncb.ac.cn/search/?dbId=gsa&q=selenomethylselenocysteine"
curl -sS "https://ngdc.cncb.ac.cn/search/?dbId=gsa&q=selenium+rat+gut"

# 3. Broad SRA sweep: Se + rodent + shotgun only (WGS strategy, excludes amplicon)
curl -sS 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi' \
  --data-urlencode 'db=sra' --data-urlencode 'retmax=500' --data-urlencode 'retmode=json' \
  --data-urlencode 'term=(selenium[All Fields] OR selenite[All Fields] OR selenomethionine[All Fields] OR selenocysteine[All Fields]) AND ("Mus musculus"[Organism] OR "Rattus norvegicus"[Organism] OR "mouse gut metagenome"[Organism] OR "mouse metagenome"[Organism]) AND ("wgs"[Strategy] OR "wga"[Strategy]) NOT "amplicon"[Strategy]'

# 4. ENA equivalent — returns library_strategy per run, so eligibility is checkable directly
curl -sS -G "https://www.ebi.ac.uk/ena/portal/api/search" \
  --data-urlencode 'result=read_run' \
  --data-urlencode 'query=library_strategy="WGS" AND (tax_eq(10090) OR tax_eq(10116) OR tax_eq(410661)) AND (study_title="*selenium*" OR study_title="*selenite*" OR study_title="*selenomethionine*")' \
  --data-urlencode 'fields=run_accession,study_accession,sample_accession,scientific_name,library_strategy,library_layout,instrument_platform,read_count,base_count,fastq_ftp,sample_title' \
  --data-urlencode 'format=tsv' --data-urlencode 'limit=1000'

# 5. Confirm downloadability for real (headers only — no bulk transfer)
#    Substitute a fastq_ftp path from step 4:
curl -sSI "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRRxxx/SRRxxxxxxx/SRRxxxxxxx_1.fastq.gz" | head -5

# 6. Qiita and MG-RAST
curl -sS "https://qiita.ucsd.edu/study/list/?search=selenium"
curl -sS "https://api.mg-rast.org/search?material=feces&text=selenium&limit=100"
```

Eligibility gate for step 4/5 output: `library_strategy == WGS` (never `AMPLICON`),
`scientific_name` in {mouse/rat gut metagenome, *Mus musculus*, *Rattus norvegicus*},
`fastq_ftp` non-empty, and a `HEAD` returning `200` with a plausible `Content-Length`.

---

## 6. Recommendation for your five downstream goals

Given the screen, plan for the likely case that **one usable rat dataset** exists rather than a cohort.

1. **Se-responsive taxa** — Candidate 1 is powered for this (5 groups × ~16, dose–response) **if**
   reads are public. Use Candidate 2's reported taxa as the a-priori expectation set, and treat
   Candidate 3 as an independent (confounded) replication check.
2. **Functional profiling** — only Candidates 1 and 3 carry real shotgun reads. Do **not** pool
   PICRUSt2-predicted functions from the 16S studies into a shotgun analysis; the field's Se
   "functional" claims are largely predictions and will not replicate at gene level.
3. **MAG reconstruction** — feasible from Candidate 1 (rat). Note it is *Rattus*: bin against a rat
   gut reference (a Sprague–Dawley rat gut gene catalogue exists, GigaScience 2018,
   `10.1093/gigascience/giy055`, PMID `29762673`; plus a brown-rat catalogue on Zenodo,
   `zenodo.org/records/14184150`) rather than mouse catalogues.
4. **Se-metabolism genes** — build the reference set independent of these datasets, then screen.
   Use `selD` (selenophosphate synthetase, required by all four known Se-utilisation traits),
   `selA`/`selB`/`selC` (Sec machinery), `selU`, and `ybbB` (tRNA 2-selenouridine synthase) plus
   `yqeB`/`yqeC`. **Selenoprofiles** is the established tool for these markers. This step does not
   depend on new data and can start now against existing public mouse gut metagenome catalogues
   (MRGM, iMGMC, CMMG) — a worthwhile parallel track that builds and validates your pipeline while
   dataset access is resolved.
5. **`sen`-like BGC mining** — the `sen` cluster is **three genes**: `senA` (an **EgtB homolog** —
   selenoneine is the Se analogue of ergothioneine), `senB` (**Se-glycosyltransferase**, previously
   uncharacterised superfamily), and `senC` (a **`selD` homolog**). Pathway order: SenC converts
   selenite → selenophosphate; SenB builds a selenosugar; SenA transfers Se from the selenosugar onto
   hercynine → selenoneine. Characterised in ***Variovorax paradoxus***. Key references:
   *Biosynthesis of selenium-containing small molecules in diverse microorganisms*, Nature 2022
   (`10.1038/s41586-022-05174-2`); bioRxiv `2022.04.13.486033`; SenB structure/mechanism
   (`10.1021/acs.biochem.3c00452`, `10.1038/s41467-024-46065-6`, `PMC11237966`).
   Mine for `selD`-adjacent gene neighbourhoods rather than `senA`/`senB` alone — `selD`/`senC`
   co-localisation is the discriminating signal that originally revealed the cluster, and hundreds of
   such clusters are already reported, giving you a validation set.

**Honest bottom line:** if Candidate 1's reads are not public, there is very likely **no** public
rodent shotgun metagenome with selenium as the sole variable, and generating your own — using the
0.20 vs 0.65 mg Se/kg chow design from Candidate 4, or a three-arm deficient/adequate/enriched design
after Candidate 2 — becomes the realistic path to goals 1–3. Goals 4 and 5 are dataset-independent
and can proceed immediately.

---

## 7. Sources

- Kasaikina et al., FASEB J 2011 — <https://faseb.onlinelibrary.wiley.com/doi/10.1096/fj.11-181990> · <https://pubmed.ncbi.nlm.nih.gov/21493887/>
- L-Se-methylselenocysteine, Front Nutr 2026 — <https://www.frontiersin.org/journals/nutrition/articles/10.3389/fnut.2026.1803630/full> · <https://pubmed.ncbi.nlm.nih.gov/41939187/> · <https://pmc.ncbi.nlm.nih.gov/articles/PMC13045510/>
- Se intervention, breast-cancer HFD mice — <https://pmc.ncbi.nlm.nih.gov/articles/PMC11322145/>
- Untargeted gut metabolomics, Se supplementation — <https://pubs.acs.org/doi/10.1021/acs.jproteome.1c00411> · <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8902802/> · <https://zenodo.org/records/17486460>
- Antibiotic depletion + Se supplementation — <https://pubs.acs.org/doi/10.1021/acs.jafc.1c02622> · <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9161447/>
- Se and testicular selenoproteins — <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8913620/>
- Se, brain metabolome, gut-brain axis — <https://pubmed.ncbi.nlm.nih.gov/36958417/>
- Se deficiency, telomere-humanized mice, Aging Cell 2025 — <https://onlinelibrary.wiley.com/doi/10.1111/acel.70130> · <https://pubmed.ncbi.nlm.nih.gov/40540389/> · <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12341817/>
- Selenomethionine + porcine deltacoronavirus — <https://www.frontiersin.org/journals/microbiology/articles/10.3389/fmicb.2025.1632166/full> · <https://pmc.ncbi.nlm.nih.gov/articles/PMC12446368/>
- Se-enriched *Pichia kudriavzevii* — <https://pubmed.ncbi.nlm.nih.gov/39417221/>
- Se-enriched yeasts, SeMet contents — <https://www.mdpi.com/1422-0067/26/7/3315> · <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11989349/>
- *Ruminococcus torques* in Se-deficient mice — <https://link.springer.com/article/10.1007/s12011-026-05106-5> · <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12622185/>
- *L. plantarum* SeZi, ICR mice — <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7589369/>
- Gut microbiota & Se bioavailability (review) — <https://www.nature.com/articles/s41538-025-00589-3> · <https://pmc.ncbi.nlm.nih.gov/articles/PMC12623734/>
- Selenoneine / `sen` cluster — <https://www.nature.com/articles/s41586-022-05174-2> · <https://www.biorxiv.org/content/10.1101/2022.04.13.486033v1.full> · <https://pubs.acs.org/doi/10.1021/acs.biochem.3c00452> · <https://www.nature.com/articles/s41467-024-46065-6> · <https://pmc.ncbi.nlm.nih.gov/articles/PMC11237966/>
- Rat gut gene catalogues — <https://academic.oup.com/gigascience/article/7/5/giy055/4995266> · <https://zenodo.org/records/14184150>
- CNCB-NGDC GSA — <https://ngdc.cncb.ac.cn/gsa/index.jsp>
</content>

---

## 8. Addendum (2026-10-01): accession numbers recovered

Re-attempted direct queries against **ENA** (`www.ebi.ac.uk`) and **CNCB-NGDC GSA**
(`ngdc.cncb.ac.cn`). Both still denied at the proxy (`403` on CONNECT); policy unchanged. Accessions
below were recovered **via server-side web search only** — no repository record was opened, so
platform, `library_strategy` and public/embargoed state are unconfirmed.

| Accession | Study | Sequencing | Meets criteria |
|---|---|---|---|
| `PRJNA857801` | Se intervention, breast-cancer mice on high-fat diet (`PMC11322145`) | shotgun metagenome | **No** — cancer + high-fat diet |
| `PRJNA1083232` | Se deficiency, aged telomere-humanized diabetic mice (`PMC12341817`, `10.1111/acel.70130`) | **16S rRNA, MiSeq** | **No** — amplicon; GM animal; type-2 diabetes |
| `PRJNA1056856` | Trace-element Se, **nude** mice, colorectal cancer (`PMC11279152`) | 16S rRNA | **No** — amplicon; cancer; immunodeficient |
| `PRJNA777712` | attributed to Se-nanoparticle / oxidative-stress intestinal-barrier work (`PMC9226128`) — **attribution unconfirmed** | unconfirmed | **No / unconfirmed** |
| `PRJNA834901` | same cluster as above — **attribution unconfirmed** | unconfirmed | **No / unconfirmed** |
| `PRJNA1261576` | **attribution unconfirmed** | unconfirmed | unconfirmed |
| `MSV000087829` | Se supplementation, MassIVE — **metabolomics, not reads** | n/a | **No** — not sequencing |

**Result: 0 of 7 accessions satisfy the inclusion criteria.**

- **Chinese databases:** no selenium rodent-gut accession found in NGDC GSA / CNGB. Searches for
  `CRA######` / `PRJCA######` returned none; every recovered accession is NCBI `PRJNA`.
- **ENA:** no ENA-native accession (`PRJEB`/`ERP`) found. The `PRJNA` projects above are
  INSDC-mirrored and therefore *should* be ENA-retrievable, but the `PRJNA`→`PRJEB`/`ERP` mapping
  was **not** confirmed and must not be guessed.
- **Candidate 1** (L-Se-methylselenocysteine SD-rat dose–response, `PMC13045510`) — the one
  structurally eligible study — still has **no recoverable accession**. Its Data Availability
  statement was not retrievable by search.

---

## 9. Candidate 1 full record (2026-10-02)

Egress still blocked (`www.frontiersin.org`, `pmc.ncbi.nlm.nih.gov`, `doi.org`,
`eutils.ncbi.nlm.nih.gov`, `www.ebi.ac.uk`, `ngdc.cncb.ac.cn` — all `403` at proxy CONNECT).
Everything below was reconstructed through server-side web search. **The repository records were
never opened**, so public/embargoed state, `library_strategy`, run count and file sizes are
unconfirmed.

### Publication

| Field | Value |
|---|---|
| Title | Gender-specific and dose-dependent responses to L-Se-methylselenocysteine are mediated by the gut microbiota-metabolite axis: implications for intestinal homeostasis and safe clinical application |
| Authors | Zhang (Hui Zhang), Wu, Sun, Sun, Chang, Yuan — *surname list; full given names not recovered* |
| Journal | Frontiers in Nutrition |
| Published | 19 March 2026 |
| DOI | `10.3389/fnut.2026.1803630` |
| PMID | `41939187` |
| PMCID | `PMC13045510` |

### Repository / accessions

| Accession | Content | Archive |
|---|---|---|
| **`PRJNA1417577`** | **Microbiome (metagenomic) raw data — the target dataset** | NCBI |
| `OMIX014882` | Metabolome | NGDC OMIX |
| `OMIX014883` | Metabolome | NGDC OMIX |

Download routes (**constructed from accession conventions, not verified**):

```
https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1417577
https://www.ebi.ac.uk/ena/browser/view/PRJNA1417577          # INSDC mirror
https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA1417577&result=read_run&fields=run_accession,library_strategy,library_layout,instrument_platform,read_count,fastq_ftp,sample_title&format=tsv
https://ngdc.cncb.ac.cn/omix/release/OMIX014882
https://ngdc.cncb.ac.cn/omix/release/OMIX014883
```

### Animals

| Field | Value |
|---|---|
| Species | *Rattus norvegicus* |
| Strain | Sprague–Dawley, SPF |
| Sex | Both; **8 male + 8 female per group** |
| n | **80 total — 16 per group × 5 groups** |
| Age / body weight at start | **not recovered** |
| Supplier | not recovered |

### Selenium intervention

| Field | Value |
|---|---|
| Compound | L-Se-methylselenocysteine (L-SeMC), organic Se |
| Route | Oral gavage |
| Duration | 90 consecutive days |
| Dietary Se concentration | **not reported** — exposure is gavage dose, not mg Se/kg chow; basal-diet Se background unknown |

| Group | Dose (mg/kg bw/day) |
|---|---|
| Control | 0 |
| T1 | 0.25 |
| T2 | 0.75 |
| T3 | 1.50 |
| T4 | 2.25 |

Human-equivalent for the T1–T2 range: ~1.04–3.12 mg per 60 kg bw/day.

### Sample & sequencing

| Field | Value |
|---|---|
| Sample type | Fresh **feces**, collected day 90, stored −80 °C |
| Profiling provider | Wuhan Metware Biotechnology Co., Ltd. (Wuhan, China) |
| Strategy | Metagenomic sequencing (shotgun) — **`library_strategy` not confirmed in SRA** |
| Platform / read length / layout | **not recovered** |
| n samples | not recovered (≤80 if one per animal) |
| Differential testing | LEfSe + log-fold-change in parallel |

Species-level resolution is reported (individual *Bifidobacterium* species), which is consistent with
true shotgun rather than amplicon data — supporting but not proving eligibility.

### Key findings

- Strong **sex asymmetry**: females far more responsive; dose-dependent α-diversity shifts.
  Females showed 7 down- vs 2 up-regulated taxa; male changes modest at every dose.
- **T1–T3 (0.25–1.50)**: protective "microbe → beneficial metabolite" axis supporting hepatic
  health; multiple beneficial *Bifidobacterium* species enriched in T3 females.
- **T4 (2.25)**: axis disrupted **in females only**, metabolic dysregulation and **irreversible
  hepatosplenic injury**; no such injury in males.

### Suitability for the selenium-only research question

**Confidence: B, usable — but only a subset of the design.**

- **Use** Control vs **T1 (0.25)** and **T2 (0.75)** — a clean graded Se-supplementation vs control
  contrast with no second intervention.
- **Exclude T4 (2.25)**: it produces frank organ injury, so it is a selenium *toxicity* arm and falls
  under your "toxins" exclusion. T3 (1.50) sits on the boundary — supra-nutritional but not injurious.
- **Model sex explicitly.** Sex is a deliberate variable with a large effect; pooling it will bury the
  Se signal. Per-sex n is 8 per dose.
- **Caveats:** gavage rather than dietary incorporation (no mg Se/kg chow figure, basal Se unknown);
  rat not mouse, so bin against rat gut references; no selenium-deficient arm — this answers
  "control vs supplementation" only.

### Still unresolved

1. Is `PRJNA1417577` public, and is its `library_strategy` `WGS` rather than `AMPLICON`?
2. Platform, read length, layout, run count, per-sample→group mapping.
3. Rat age/weight at study start; basal diet Se content.
4. Full author given names.

All four resolve from the two URLs above once egress is opened.

### Additional lead found

`PMC10745411` — *Comparative Analysis of Gut Microbiota from Rats Induced by Se Deficiency and T-2
Toxin* (Nutrients 2023;15(24):5027). Carries a **Se-deficiency rat arm**, which is the arm missing
from Candidate 1. The T-2 toxin arm is excluded, but a Se-deficient-vs-control contrast may be
separable. Sequencing strategy and accession unchecked — worth a lookup.

---

## 10. Non-fecal / small-intestine sampling (2026-10-09)

Egress still blocked (`www.ebi.ac.uk`, `pmc.ncbi.nlm.nih.gov` → `000`). Search-derived; no
repository record opened.

**Answer: yes, selenium studies sampling the small intestine exist — but every one is 16S amplicon.
No selenium rodent study was found that applied shotgun metagenomics to intestinal contents of any
segment.** All shotgun selenium rodent data located in this survey (`PRJNA1417577`, `PRJNA857801`)
are **fecal**.

| Study | Sample site | Sequencing | Se design | Notes |
|---|---|---|---|---|
| Wang F. et al., *Front Immunol* 2022;13:947655 (`PMC9299101`, `10.3389/fimmu.2022.947655`) | **Small intestinal contents** | 16S | **Se-deficient (LSe) vs Se-adequate (CSe)** | Best sample-type + design match. ↑ *Lactobacillus*, *Bifidobacterium*, *Ileibacterium*; ↓ *Romboutsia* in LSe. Accession not found |
| Wang G. et al., *BioFactors* 2024;50(2):311–325 (`10.1002/biof.2006`) | **Jejunum** | 16S (rRNA-targeted) | Se deficiency vs control | Also carries FMT and *L. reuteri* arms (excluded); the Se-deficient-vs-control contrast is separable. ↓ *L. reuteri* the dominant effect. Accession not found |
| Research Square `rs-3851778` (same group) | Small intestine contents (0.2 g) | 16S, Illumina NovaSeq | Se deficiency + *L. reuteri* | **Probiotic arm** — excluded |
| Se supplementation / testicular selenoproteins (`PMC8913620`) | **Colon** contents | 16S | Control vs Se-supplemented | Non-gut endpoint, gut sample usable |
| Mojadadi et al., *Redox Report* 2025 (`PMC12035940`, `10.1080/13510002.2025.2495367`, PMID `40277453`) | Stool from **large colon** | 16S V3–V4 | Inorganic vs organic vs nanoparticle Se, male mice | Three Se forms, Se-only intervention; amplicon only. Accession not found |
| Se-enriched egg powder, Kunming mice (`PMC13024860`) | **Cecal** microbiota | 16S | Se-enriched food matrix | Matrix confound (egg powder), not pure Se |

### Note on the *Front Immunol* 2022 study's eligibility

Its title names inflammation, autophagy, ER stress and apoptosis, which reads like an
inflammatory-disease model and therefore an exclusion. It is not: those are **downstream
consequences of the selenium deficiency itself**, measured as endpoints in intestinal smooth muscle.
The only manipulated variable is dietary Se (LSe vs CSe). The design is clean; it fails on
**sequencing strategy only**.

### Why this gap exists, and what it means

Small-intestinal and jejunal contents carry **low microbial biomass and a high host-DNA fraction**,
so shotgun libraries from them are dominated by mouse/rat reads and are expensive to sequence to
useful microbial depth. That is the practical reason the segment is almost always profiled by
amplicon. It is also a real constraint to plan around if generating new data: expect to need host-DNA
depletion and substantially deeper sequencing than for feces.

This leaves a genuine trade-off:

- **Small intestine** — the site where host–microbe competition for selenium absorption actually
  occurs, and biologically the more interesting target — has **no shotgun data**, so MAG
  reconstruction, functional profiling and `selD`/`sen` gene mining are not possible from it.
- **Shotgun depth** is available **only from feces** (`PRJNA1417577`).

For goals 3–5 (MAGs, functional profiling, Se-gene and BGC mining) the fecal dataset is the only
option. The small-intestine 16S studies are usable solely as taxonomic priors — they tell you which
genera to expect to shift (*Lactobacillus*, *Bifidobacterium*, *Ileibacterium*, *Romboutsia*,
*L. reuteri*), not what genes are present.

### Additional unchecked lead

A Japanese rat study with a **three-arm Se-deficient / Se-adequate / Se-excessive** design (likely
PMID `40268463`, on dimethyldiselenide and dimethylselenide gut metabolism) reportedly found distinct
communities and higher diversity under Se excess. Some arms use antibiotic microbiota suppression
(excluded), and the sample site and sequencing strategy were not recoverable. Worth one lookup — a
three-arm design is otherwise absent from everything found here.

---

## 11. Accessions confirmed; fetch attempted (2026-10-09)

The paper's Data availability statement was supplied directly and **confirms the accessions
recovered by search in §9**:

> The microbiome data of all groups are deposited in the National Center for Biotechnology
> Information (NCBI) database access number: **PRJNA1417577**. Metabolome data for all groups are
> deposited in the National Genomics Data Center (NGDC), access numbers: **OMIX014882** and
> **OMIX014883**.

### Fetch attempt: failed, environment-blocked

| Host | Purpose | Result |
|---|---|---|
| `ftp.sra.ebi.ac.uk` | ENA FASTQ delivery | blocked |
| `sra-download.ncbi.nlm.nih.gov` | SRA delivery | blocked |
| `trace.ncbi.nlm.nih.gov` | SRA run browser | blocked |
| `www.ebi.ac.uk` | ENA portal API | blocked (`403` at proxy) |
| `ngdc.cncb.ac.cn`, `download.cncb.ac.cn` | NGDC OMIX | blocked |
| `api.ncbi.nlm.nih.gov` | NCBI API | blocked |
| `pypi.org` | *control* | **200** |
| `github.com` | *control* | reachable |

The network policy is an **allowlist permitting package registries and GitHub only**; no scientific
data repository is reachable. SRA toolkit (`prefetch`, `fasterq-dump`), `aws` and `ascp` are not
installed, and PyPI being open means `sra-tools` still cannot be installed usefully — the binaries
would have nothing to talk to.

**Separately, the data would not fit.** This container has ~30 GB free. A shotgun metagenomic
project of up to 80 rat fecal samples is plausibly 300–800 GB of compressed FASTQ. Even with egress
opened, the reads need a machine with real storage; this container could hold a manifest and a
handful of runs at most.

### Deliverable: `fetch_selenium_datasets.sh`

A ready-to-run fetch script is committed at the repository root. Syntax-checked and executed here —
it runs correctly and fails only at the network boundary (`403` from the proxy), so it is ready to
work unchanged on an unrestricted machine.

```
./fetch_selenium_datasets.sh manifest       # run table only — small, do this first
./fetch_selenium_datasets.sh reads [N]      # download FASTQs (optionally first N runs)
./fetch_selenium_datasets.sh metabolome     # OMIX landing pages
```

`manifest` is the important one: it pulls the ENA run table and prints `library_strategy`,
platform, layout, organism, run count, total download size, and the per-run sample titles that carry
the group mapping. That settles every open question in §9 in one small request, before any bulk
transfer. The `reads` step **refuses to download unless `library_strategy` is `WGS`**, so an
amplicon deposit cannot be mistaken for shotgun data (override with `FORCE=1`).

A fallback SRA-toolkit recipe is included at the end of the script for the case where ENA has not
yet mirrored the project.

---

## 12. PRJNA1417577 RESOLVED — verified shotgun, 30 runs, full sample map (2026-10-09)

ENA egress was opened (`www.ebi.ac.uk`, `ftp.sra.ebi.ac.uk` → `200`; NCBI and NGDC still blocked).
The run table was retrieved and the data inspected directly.

### The dataset is real, public, and shotgun — but SRA mislabels it

| Field | Value |
|---|---|
| Runs | **30** (not 80 — see below) |
| `library_strategy` | **`AMPLICON` — THIS LABEL IS WRONG** |
| `library_source` | `METAGENOMIC` |
| Platform | **DNBSEQ-G400** (MGI/BGI), PAIRED, 150 bp |
| Depth | **~26.4 M read pairs / ~7.9 Gbp per sample** |
| Total | **173.3 GB** |
| BioSamples | `SAMN55001291`–`SAMN55001320` (contiguous) |

**The `AMPLICON` label is a submission error.** Three independent lines of evidence:

1. **Depth.** 7.9 Gbp/sample. A 16S V3–V4 run is ~0.05–0.1 Gbp — this is 50–150× deeper.
2. **`library_source = METAGENOMIC`**, which contradicts an amplicon strategy.
3. **Read diversity, measured directly.** A 20 MB chunk of `SRR37092220_1.fastq.gz` was downloaded
   and inspected: **49,636 distinct 25-base prefixes among 50,000 reads**, most common prefix seen
   **twice**. Reads are diverse random genomic fragments at a uniform 150 bp with no primer. True
   V3–V4 amplicon reads nearly all begin with the same conserved primer and would collapse to a
   handful of prefixes.

**Consequence: any automated filter on `library_strategy == WGS` silently discards this dataset.**
That includes the guard originally written into `fetch_selenium_datasets.sh`, now corrected to test
depth and read diversity rather than the label alone.

### Design correction: n = 3 per sex per dose, not 16

The paper's 80 rats are the full toxicology cohort. **Only 30 samples were sequenced** — 5 dose arms
× 2 sexes × **3 replicates**. Sample aliases decode as `Rattus_L_SeMC_<dose><sex>_<rep>`.

| Dose arm | mg/kg bw/day | Samples | Size |
|---|---|---|---|
| C | 0 | 6 (3 M + 3 F) | 33.1 GB |
| T1 | 0.25 | 6 | 35.8 GB |
| T2 | 0.75 | 6 | 33.7 GB |
| T3 | 1.50 | 6 | 35.2 GB |
| T4 | 2.25 | 6 | 35.5 GB |

**n = 3 per sex per dose is low power.** Since sex is a strong effect in this study, a sex-stratified
analysis rests on 3 vs 3. Treat per-sex findings as exploratory; the dose–response trend across
C→T1→T2 (9 animals per sex across three levels) is the better-powered contrast.

### Full sample map

Written to `selenium_data/sample_map.tsv` (run · biosample · dose · sex · replicate · GB).

| Dose | Sex | Runs |
|---|---|---|
| C | male | `SRR37092246`, `SRR37092245`, `SRR37092234` |
| C | female | `SRR37092223`, `SRR37092222`, `SRR37092221` |
| T1 | male | `SRR37092220`, `SRR37092219`, `SRR37092218` |
| T1 | female | `SRR37092217`, `SRR37092244`, `SRR37092243` |
| T2 | male | `SRR37092242`, `SRR37092241`, `SRR37092240` |
| T2 | female | `SRR37092239`, `SRR37092238`, `SRR37092237` |
| T3 | male | `SRR37092236`, `SRR37092235`, `SRR37092233` |
| T3 | female | `SRR37092232`, `SRR37092231`, `SRR37092230` |
| T4 | male | `SRR37092229`, `SRR37092228`, `SRR37092227` |
| T4 | female | `SRR37092226`, `SRR37092225`, `SRR37092224` |

### Downloading

`GROUPS=` now restricts to dose arms (verified: `GROUPS=C,T1,T2` selects exactly 18 runs):

```
GROUPS=C,T1,T2 ./fetch_selenium_datasets.sh reads     # 102.6 GB, the selenium-only contrast
./fetch_selenium_datasets.sh reads                    # all 173.3 GB
```

**This container cannot hold it.** ~30 GB free against 33.1 GB for the control arm alone. The reads
need a machine with real storage; what this environment could produce — the verified manifest and
sample map — is done and committed.

### Status

Candidate 1 is now **confidence A** on every criterion that can be checked without the reads:
shotgun metagenomics (verified empirically), selenium-only intervention, proper vehicle control, gut
samples, public and downloadable. The remaining caveats are design, not availability: gavage rather
than dietary Se, no Se-deficient arm, n = 3 per sex per dose, and T4 being a toxicity arm to exclude.

---

## 13. Full accession audit — all metagenomic data kept, mislabel corrected (2026-10-09)

Every accession in this survey was re-checked against ENA, and the two borderline cases were
verified by direct read inspection rather than by trusting the deposited metadata.

### Audit result

| Accession | Runs | Declared | Source | Mean Gbp | **Verified type** | Label correct |
|---|---|---|---|---|---|---|
| `PRJNA1417577` | 30 | `AMPLICON` | METAGENOMIC | **8.05** | **SHOTGUN** | **NO → corrected to WGS** |
| `PRJNA857801` | 10 | `WGS` | METAGENOMIC | 3.16 | SHOTGUN | yes |
| `PRJNA1083232` | 48 | `AMPLICON` | GENOMIC | 0.44 | 16S amplicon | yes |
| `PRJNA1056856` | 24 | `AMPLICON` | METAGENOMIC | 0.03 | 16S amplicon | yes |
| `PRJNA777712` | 32 | `AMPLICON` | METAGENOMIC | 0.02 | 16S amplicon | yes |
| `PRJNA834901` | 28 | `AMPLICON` | METAGENOMIC | 0.05 | 16S amplicon | yes |
| `PRJNA1261576` | 30 | `AMPLICON` | METAGENOMIC | 0.04 | 16S amplicon | yes |

Depth separates the two classes cleanly — 3.16–8.05 Gbp/sample for shotgun against 0.02–0.44 for
amplicon, with no overlap. **Exactly one deposit is mislabelled.**

`PRJNA1083232` was the one case depth alone could not settle (0.44 Gbp, ~10× the other amplicon
sets), so it was probed the same way as `PRJNA1417577`: **724 distinct 25-base prefixes in 30,000
reads**, the commonest (`CCTACGGGGGGCTGCAGTGAGGAAT`, 2,563 occurrences) being the **341F V3–V4
primer**, at 300 bp on MiSeq. Genuine amplicon — its `AMPLICON` label is right, and it stays
excluded. Contrast `PRJNA1417577`: 49,636/50,000 distinct prefixes, no primer, 150 bp.

### Corrected manifest — `selenium_data/metagenomic_runs_corrected.tsv`

**All 40 metagenomic runs, 186.4 GB, nothing dropped:**

| BioProject | Runs | Size | Corrected |
|---|---|---|---|
| `PRJNA1417577` | 30 | 173.3 GB | all 30: `AMPLICON` → `WGS` |
| `PRJNA857801` | 10 | 13.1 GB | none needed |

Each row carries both `library_strategy` (corrected) and `library_strategy_as_deposited`
(original), plus `label_corrected` and `correction_basis`, so the change is auditable and nothing is
silently overwritten. Decoded `dose_arm`, `sex` and `replicate` columns are included, with FASTQ
URLs and md5s.

All five dose arms are retained, T3 and T4 included. They remain **analytically** excluded from a
selenium-only contrast (T4 causes hepatosplenic injury), but the data are kept and labelled so that
decision stays yours rather than being baked into the manifest.

`PRJNA857801` is kept here because it **is** genuine shotgun metagenomic selenium data. Its study
design is still confounded (breast-cancer model on high-fat diet), so it is not a substitute for
Candidate 1 — but as a second, independent shotgun selenium dataset it is worth holding for
cross-checking any Se-responsive gene signal.

### Download layout

Files now land under `fastq/<bioproject>/<arm>_<sex>/`, verified to produce:

```
PRJNA1417577/C_female  C_male  T1_female  T1_male  T2_female  T2_male
               T3_female  T3_male  T4_female  T4_male      (3 runs each)
PRJNA857801/unassigned                                      (10 runs)
```

Defaults to **all** metagenomic runs; `GROUPS=C,T1,T2` narrows to the selenium-only contrast.

### The general lesson

`library_strategy` is submitter-supplied and unverified by the archive. A filter on
`library_strategy == WGS` would have silently discarded the single best dataset in this entire
survey. For selenium work specifically — where much of the field deposits through commercial
providers — screen on **`base_count` per sample** first and confirm with a read-diversity check.
Depth plus prefix entropy separated these seven deposits perfectly; the declared label did not.
