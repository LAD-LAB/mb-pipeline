#!/bin/bash
#SBATCH --job-name=human_anonymize
#SBATCH --output=logs/anonymize_%A_%a.out
#SBATCH --error=logs/anonymize_%A_%a.err
#SBATCH --time=8:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --array=1-PLACEHOLDER_NFILES

# SLURM Job Script for Human Read Anonymization
# This script processes one FASTQ file per array task

# Load required modules or singularity container
# Set by submit_anonymization.sh — do not edit manually
SINGULARITY_IMAGE="PLACEHOLDER_SINGULARITY_PATH"

# Input parameters (passed via environment or config file)
REF_FASTA="${REF_FASTA}"
INPUT_DIR="${INPUT_DIR}"
OUTPUT_DIR="${OUTPUT_DIR}"
THRESHOLD="${THRESHOLD:-0.7}"
KMER_SIZE="${KMER_SIZE:-8}"

# Get the file to process for this array task
FILELIST="${INPUT_DIR}/file_list.txt"
INPUT_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$FILELIST")

# Extract filename
FILENAME=$(basename "$INPUT_FILE")
OUTPUT_FILE="${OUTPUT_DIR}/${FILENAME}"

echo "=========================================="
echo "SLURM Job: ${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}"
echo "Node: ${SLURM_NODELIST}"
echo "Start time: $(date)"
echo "=========================================="
echo "Input: ${INPUT_FILE}"
echo "Output: ${OUTPUT_FILE}"
echo "Reference: ${REF_FASTA}"
echo "Threshold: ${THRESHOLD}"
echo "K-mer size: ${KMER_SIZE}"
echo "=========================================="

# Run the anonymization script
if [ -n "$SINGULARITY_IMAGE" ] && [ -f "$SINGULARITY_IMAGE" ]; then
    echo "Running with Singularity container: $SINGULARITY_IMAGE"
    # Adjust bind mounts (-B) to match your cluster's filesystem layout
    singularity exec \
        "$SINGULARITY_IMAGE" Rscript human_read_anonymizer.R \
        "$REF_FASTA" \
        "$INPUT_FILE" \
        "$OUTPUT_FILE" \
        "$THRESHOLD" \
        "$KMER_SIZE"
else
    echo "Running with system R (no singularity)"
    Rscript human_read_anonymizer.R \
        "$REF_FASTA" \
        "$INPUT_FILE" \
        "$OUTPUT_FILE" \
        "$THRESHOLD" \
        "$KMER_SIZE"
fi

EXIT_CODE=$?

echo "=========================================="
echo "End time: $(date)"
echo "Exit code: $EXIT_CODE"
echo "=========================================="

exit $EXIT_CODE
