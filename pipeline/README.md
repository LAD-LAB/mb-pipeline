# Pipeline

This folder contains scripts for processing raw metabarcoding sequencing data into phyloseq objects. The pipeline handles both trnL (plant) and 12Sv5 (animal) markers, including multiplex runs where both markers are pooled in a single sequencing run.

For detailed, step-by-step documentation, see the [FoodSeq Handbook](https://lad-lab.github.io/pipeline.html).

## Overview

The workflow has three stages:

1. **On the cluster** — demultiplex raw sequencing data and run the QIIME2/DADA2 pipeline
2. **On the cluster (optional)** — count reads at each pipeline step for quality control
3. **In R** — download results and create phyloseq objects using `Pipeline-to-Phyloseq.Rmd`

## Files

### Active

| File | Description |
|---|---|
| `Pipeline-to-Phyloseq.Rmd` | R notebook that downloads pipeline output from the cluster and creates trnL and 12Sv5 phyloseq objects. Uses the [`foodseq.tools`](https://github.com/Ashish-Subramanian/foodseq.tools) package. |
| `demux-barcodes.sh` | SLURM script for demultiplexing raw BCL data into per-sample FASTQ files using `bcl2fastq`. |
| `trnL-pipeline.sh` | SLURM script for running the trnL QIIME2/DADA2 pipeline on demultiplexed reads. |
| `12SV5-pipeline.sh` | SLURM script for running the 12Sv5 QIIME2/DADA2 pipeline on demultiplexed reads. |
| `count-reads.sh` | SLURM script that extracts per-sample read counts at each pipeline step and writes `track-pipeline.csv`. Required before downloading in minimal mode. |
| `count-reads.R` | R script called by `count-reads.sh` to parse QIIME2 output and assemble the read-tracking table. |

### Archived

Older versions of pipeline files are in the [`archive/`](archive/) folder for reproducibility. These include the original `Pipeline-to-phyloseq.Rmd` (which predates `foodseq.tools`), the original `README.md`, and `script-writer.Rmd`.

## Quick Start

### Prerequisites

- Access to an HPC cluster with SLURM and Singularity
- The Singularity containers `metabarcoding.sif` (for `bcl2fastq`) and `qiime2.sif` (for QIIME2) available on the cluster
- [R](https://www.r-project.org/) with the [`foodseq.tools`](https://github.com/Ashish-Subramanian/foodseq.tools) package installed
- Reference FASTAs for taxonomy assignment, available in [`reference/references/`](../reference/references/)

### 1. Demultiplex

Log into the cluster and submit the demultiplexing job:

```sh
sbatch --mail-user=[username]@[your-email] \
  [/path/to/demux-barcodes.sh] \
  [/path/to/XXXXXX_MNXXXXX_XXXX_XXXXXXXXXX] \
  [/path/to/samplesheet.csv] \
  [/path/to/metabarcoding.sif]
```

### 2. Run the marker pipeline

Once demultiplexing completes, run the appropriate pipeline script:

```sh
# For trnL:
sbatch --mail-user=[username]@[your-email] \
  [/path/to/trnL-pipeline.sh] \
  [/path/to/XXXXXXXX_results/demultiplexed] \
  [/path/to/qiime2.sif]

# For 12Sv5:
sbatch --mail-user=[username]@[your-email] \
  [/path/to/12SV5-pipeline.sh] \
  [/path/to/XXXXXXXX_results/demultiplexed] \
  [/path/to/qiime2.sif]
```

### 3. Count reads (optional but recommended)

If you plan to download in minimal mode (only the files needed for phyloseq creation), run `count-reads.sh` on the cluster first. This extracts read counts from the QIIME2 output and writes a `track-pipeline.csv` file that the R pipeline uses for quality control plots.

```sh
sbatch [/path/to/count-reads.sh] \
  [/path/to/XXXXXXXX_results/XXXXXXXX_output] \
  [/path/to/count-reads.R] \
  [/path/to/metabarcoding.sif]
```

The script takes three arguments: the path to the pipeline output directory (e.g., `20250115_trnL_output`), the path to `count-reads.R`, and the path to the Singularity container. It runs in seconds.

If you download in full mode instead, this step is not needed — `Pipeline-to-Phyloseq.Rmd` can process the QC data locally.

### 4. Create phyloseq objects in R

Open `Pipeline-to-Phyloseq.Rmd` in RStudio, fill in your user inputs (cluster hostname, paths, reference FASTAs), and run through the notebook. The pipeline will download your data from the cluster, create ASV tables, assign taxonomy, and assemble trnL and 12Sv5 phyloseq objects with quality control output at each step.

See the [FoodSeq Handbook pipeline page](https://lad-lab.github.io/pipeline.html) for a full walkthrough.
