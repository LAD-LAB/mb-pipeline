# Human Read Anonymizer for Metabarcoding FASTQ Files

A computational tool for removing identifiable human DNA sequences from amplicon sequencing (metabarcoding) FASTQ files prior to public data deposition. Human reads are detected via k-mer similarity to a reference database and replaced with a fixed synthetic sequence that preserves downstream bioinformatic compatibility, including paired-end merging in DADA2.

## Motivation

Metabarcoding studies that use universal or broad-range primers (e.g., 12S rRNA) frequently co-amplify human DNA from the investigators or study participants. Public sequence repositories such as the NCBI Sequence Read Archive (SRA) require that identifiable human sequences be removed before submission. Simply discarding human reads alters per-sample read depths and may bias downstream diversity analyses. This tool instead **replaces** human reads with a standardized synthetic sequence, preserving read counts and FASTQ structure while removing all original human sequence information.

## Method

### Detection

Each read is screened for human origin using an exhaustive k-mer comparison against a curated reference database of human amplicon sequences. For each read:

1. The region downstream of the 5' primer (positions 19 onward) is decomposed into all constituent k-mers (default k = 8).
2. Both the forward and reverse-complement orientations are evaluated.
3. The fraction of query k-mers present in the human reference database is computed.
4. Reads exceeding a similarity threshold (default 0.70) are classified as human.

This approach is adapted from the k-mer exact-matching strategy used in DADA2's `assignTaxonomy()` function (Wang et al., 2007; Callahan et al., 2016).

### Replacement

Reads classified as human are replaced with a synthetic sequence derived from the human mitochondrial 12S rRNA gene. The replacement preserves the read structure expected by downstream primer-trimming (cutadapt) and denoising (DADA2) software:

```
R1: [5' forward primer][replacement core (100 bp)][3' reverse primer][original adapter tail]
R2: [5' RC(reverse primer)][RC(replacement core) (100 bp)][3' RC(forward primer)][original adapter tail]
```

Key design features:

- **Strand complementarity**: R1 receives the forward-strand replacement; R2 receives its reverse complement. This ensures successful paired-end merging in DADA2, which aligns denoised ASV sequences (not quality scores) from both reads.
- **Fixed 100 bp core**: The replacement insert matches the expected biological amplicon length between the 12Sv5 primers, producing a single 100 bp ASV after primer trimming.
- **Primer preservation**: Both 5' and 3' primers are retained in their expected positions, so cutadapt linked-adapter trimming behaves identically to untreated reads.
- **Adapter tail preservation**: The original Illumina adapter read-through sequence beyond the 3' primer is kept, avoiding any artifacts from adapter trimming.
- **Original quality scores**: Quality strings are preserved from the original read, maintaining realistic error profiles for DADA2's error model learning.
- **Taxonomic assignment**: The replacement sequence is derived from the human 12S mitochondrial region and is classified as *Homo sapiens* by standard reference databases (e.g., MitoFish, MIDORI2), ensuring that the replacement ASV is identifiable and removable in downstream analyses.

### Validation

The pipeline includes built-in verification:
- Read count preservation (input reads = output reads)
- Spot-check confirmation that replacement sequences are correctly inserted
- Length consistency between input and output reads

## Requirements

- **R** (>= 4.0) with Bioconductor packages:
  - `Biostrings`
  - `ShortRead`
- **Reference FASTA**: A file containing known human amplicon sequences for k-mer database construction. The included `human-sequences.fasta` contains 1,318 human 12S sequences.
- For HPC deployment: a Singularity/Apptainer container with the above R packages, or a system R installation.

## Repository Contents

| File | Description |
|------|-------------|
| `human_read_anonymizer.R` | Core anonymization script (k-mer detection and sequence replacement) |
| `submit_anonymization.sh` | Master submission script for SLURM HPC clusters |
| `slurm_anonymize_job.sh` | SLURM array job template (one task per FASTQ file) |
| `human-sequences.fasta` | Reference database of 1,318 human 12S amplicon sequences |

## Usage

### Single File

```bash
Rscript human_read_anonymizer.R \
    human-sequences.fasta \
    sample_R1_001.fastq.gz \
    output/sample_R1_001.fastq.gz \
    0.7 \
    8
```

Arguments:
1. Reference FASTA file
2. Input FASTQ.gz file
3. Output FASTQ.gz file
4. K-mer overlap threshold (default: 0.7)
5. K-mer size (default: 8)

**Note**: R1 and R2 files from the same sample are processed independently. The script automatically detects read direction from the filename (`_R1_` or `_R2_`).

### Batch Processing (SLURM)

1. Edit the configuration variables at the top of `submit_anonymization.sh`:

```bash
SINGULARITY_IMAGE="/path/to/container.sif"  # or "" for system R
REF_FASTA="/path/to/human-sequences.fasta"
INPUT_DIR="/path/to/input/fastq/files"
OUTPUT_DIR="/path/to/output/directory"
THRESHOLD=0.7
KMER_SIZE=8
```

2. Submit:

```bash
chmod +x submit_anonymization.sh slurm_anonymize_job.sh human_read_anonymizer.R
./submit_anonymization.sh
```

3. Monitor jobs:

```bash
squeue -u $USER
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `threshold` | 0.7 | Minimum fraction of query k-mers matching the human reference database to classify a read as human. Range: 0.6 (sensitive) to 0.8 (specific). |
| `k` | 8 | K-mer length for sequence comparison. k = 8 provides 65,536 possible k-mers and matches the default used in DADA2's taxonomy assignment. |

## Performance

- **Memory**: 8-16 GB per file (configurable via SLURM)
- **Runtime**: ~10-30 minutes per FASTQ file
- **Parallelization**: Processes all files simultaneously as a SLURM array job

## Validation Results

The pipeline was validated on 576 paired-end Illumina MiSeq samples (12Sv5 metabarcoding, ~70% human DNA contamination). Downstream QIIME 2/DADA2 analysis (denoise-paired, taxonomic classification) was performed identically on original and anonymized datasets.

| Metric | Value |
|--------|-------|
| Per-sample read depth correlation (original vs. anonymized) | r = 0.999 |
| Non-human ASV abundance correlation | r = 0.954 |
| Species with >4-fold abundance change | 0 |
| Beta diversity preservation (Bray-Curtis Mantel test) | r = 0.999, p < 0.001 |
| Beta diversity preservation (Procrustes correlation) | r = 1.000, p < 0.001 |
| Human ASVs remaining after anonymization | 3 (of 303 original), 372 total reads |
| Non-human species lost | 0 |

## Limitations

- Replacing a large fraction of reads (~70%) with an identical sequence alters DADA2's error model, which can lead to over-splitting of non-human ASVs at the ASV level. In validation, mean non-human ASV richness per sample increased from 4.5 to 7.9 (p = 0.016). However, species-level composition, beta diversity, and overall ecological conclusions were unaffected.
- The tool is designed for short-amplicon metabarcoding data. Adaptation to other marker genes requires changing the replacement core sequence, primer sequences, and reference database.

## Adapting to Other Marker Genes

To use this tool with a different amplicon target:

1. Replace `REPLACEMENT_CORE` in `human_read_anonymizer.R` with a sequence of appropriate length for your amplicon insert, derived from the corresponding human locus.
2. Update `FORWARD_PRIMER` and `REVERSE_PRIMER` to match your primer pair.
3. Provide a reference FASTA containing known human sequences for your target region.

## Citation

If you use this software, please cite:

> Subramanian AM. Human Read Anonymizer for Metabarcoding FASTQ Files. 2026. GitHub: [repository URL].

## References

- Callahan BJ, McMurdie PJ, Rosen MJ, Han AW, Johnson AJA, Holmes SP. DADA2: High-resolution sample inference from Illumina amplicon data. *Nature Methods*. 2016;13(7):581-583. doi:10.1038/nmeth.3869
- Wang Q, Garrity GM, Tiedje JM, Cole JR. Naive Bayesian classifier for rapid assignment of rRNA sequences into the new bacterial taxonomy. *Applied and Environmental Microbiology*. 2007;73(16):5261-5267. doi:10.1128/AEM.00062-07
- Martin M. Cutadapt removes adapter sequences from high-throughput sequencing reads. *EMBnet.journal*. 2011;17(1):10-12. doi:10.14806/ej.17.1.200
- Bolyen E, Rideout JR, Dillon MR, et al. Reproducible, interactive, scalable and extensible microbiome data science using QIIME 2. *Nature Biotechnology*. 2019;37(8):852-857. doi:10.1038/s41587-019-0209-9

## License

This software is provided for academic research use. See LICENSE file for details.
