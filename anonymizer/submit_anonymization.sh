#!/bin/bash

# Master Script for Human Read Anonymization
# This script prepares the job array and submits to SLURM

set -e  # Exit on error

# ============================================================================
# CONFIGURATION - EDIT THESE VARIABLES
# ============================================================================

# Path to your Singularity container with R and Bioconductor (or "" for system R)
SINGULARITY_IMAGE="/path/to/container.sif"

# Path to human reference FASTA file
# This should contain known human sequences for k-mer matching
REF_FASTA="/path/to/human-sequences.fasta"

# Input directory containing FASTQ.gz files
INPUT_DIR="/path/to/input/fastq/files"

# Output directory for anonymized files
OUTPUT_DIR="/path/to/output/directory"

# K-mer matching parameters
THRESHOLD=0.7      # K-mer overlap threshold (0-1) for calling human
KMER_SIZE=8        # K-mer size (8 is default, matches DADA2)

# SLURM parameters
MAX_TIME="8:00:00"    # Maximum time per job
MEMORY="16G"           # Memory per job
PARTITION=""          # Leave empty for default, or specify partition

# ============================================================================
# END CONFIGURATION
# ============================================================================

# Print configuration
echo "========================================"
echo "Human Read Anonymization Pipeline"
echo "========================================"
echo "Configuration:"
echo "  Singularity image: $SINGULARITY_IMAGE"
echo "  Reference FASTA:   $REF_FASTA"
echo "  Input directory:   $INPUT_DIR"
echo "  Output directory:  $OUTPUT_DIR"
echo "  Threshold:         $THRESHOLD"
echo "  K-mer size:        $KMER_SIZE"
echo "========================================"

# Validate inputs
if [ ! -f "$REF_FASTA" ]; then
    echo "ERROR: Reference FASTA not found: $REF_FASTA"
    exit 1
fi

if [ ! -d "$INPUT_DIR" ]; then
    echo "ERROR: Input directory not found: $INPUT_DIR"
    exit 1
fi

if [ -n "$SINGULARITY_IMAGE" ] && [ ! -f "$SINGULARITY_IMAGE" ]; then
    echo "WARNING: Singularity image not found: $SINGULARITY_IMAGE"
    echo "Will attempt to use system R instead"
    SINGULARITY_IMAGE=""
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Create logs directory
mkdir -p logs

# Find all FASTQ.gz files and sort by size (largest first)
echo ""
echo "Finding FASTQ files in $INPUT_DIR..."
echo "Sorting by size (largest first) for optimal job scheduling..."
ls -lS "$INPUT_DIR"/*.fastq.gz 2>/dev/null | awk '{print $9}' > "${INPUT_DIR}/file_list.txt"
NFILES=$(wc -l < "${INPUT_DIR}/file_list.txt")

if [ "$NFILES" -eq 0 ]; then
    echo "ERROR: No FASTQ.gz files found in $INPUT_DIR"
    exit 1
fi

echo "Found $NFILES FASTQ.gz files (sorted by size)"
echo ""
echo "First 10 files (largest):"
head -10 "${INPUT_DIR}/file_list.txt"
echo "..."
echo "Last 10 files (smallest):"
tail -10 "${INPUT_DIR}/file_list.txt"
echo ""

# Prepare SLURM job script
echo "Preparing SLURM job script..."
cp slurm_anonymize_job.sh slurm_anonymize_job_prepared.sh

# Replace placeholders
sed -i "s|PLACEHOLDER_SINGULARITY_PATH|${SINGULARITY_IMAGE}|g" slurm_anonymize_job_prepared.sh
sed -i "s|PLACEHOLDER_NFILES|${NFILES}|g" slurm_anonymize_job_prepared.sh
sed -i "s|#SBATCH --time=.*|#SBATCH --time=${MAX_TIME}|g" slurm_anonymize_job_prepared.sh
sed -i "s|#SBATCH --mem=.*|#SBATCH --mem=${MEMORY}|g" slurm_anonymize_job_prepared.sh

# Add partition if specified
if [ -n "$PARTITION" ]; then
    sed -i "/#SBATCH --cpus-per-task=1/a #SBATCH --partition=${PARTITION}" slurm_anonymize_job_prepared.sh
fi

# Submit job array
echo "Submitting job array to SLURM..."
JOB_ID=$(sbatch \
    --export=ALL,REF_FASTA="${REF_FASTA}",INPUT_DIR="${INPUT_DIR}",OUTPUT_DIR="${OUTPUT_DIR}",THRESHOLD="${THRESHOLD}",KMER_SIZE="${KMER_SIZE}" \
    slurm_anonymize_job_prepared.sh | awk '{print $4}')

echo ""
echo "========================================"
echo "Job submitted successfully!"
echo "Job ID: $JOB_ID"
echo "Number of tasks: $NFILES"
echo "NOTE: Jobs will process largest files first for optimal scheduling"
echo "========================================"
echo ""
echo "Monitor job status with:"
echo "  squeue -u \$USER"
echo ""
echo "View logs in:"
echo "  logs/anonymize_${JOB_ID}_*.out"
echo "  logs/anonymize_${JOB_ID}_*.err"
echo ""
echo "Cancel jobs with:"
echo "  scancel $JOB_ID"
echo ""

# Save job information
cat > job_${JOB_ID}_info.txt <<EOF
Job ID: $JOB_ID
Submission time: $(date)
Number of files: $NFILES
Input directory: $INPUT_DIR
Output directory: $OUTPUT_DIR
Reference FASTA: $REF_FASTA
Threshold: $THRESHOLD
K-mer size: $KMER_SIZE
Note: Files sorted by size (largest first) for optimal job scheduling
EOF

echo "Job information saved to: job_${JOB_ID}_info.txt"