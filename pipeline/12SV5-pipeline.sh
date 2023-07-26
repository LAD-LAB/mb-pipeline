#!/bin/bash
#SBATCH --job-name=12SV5-pipeline
#SBATCH --mem=20000
#SBATCH --partition scavenger
#SBATCH --out=12SV5-pipeline.out
#SBATCH --error=12SV5-pipeline.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# Usage:
# sbatch --mail-user=netID@duke.edu 12SV5-pipeline.sh /path/to/demux-dir /path/to/qiime2.sif

## Set up input, output directories ############################################
reportdir=$PWD
INPUT_DIR=$1
cd $INPUT_DIR/..
wd=$PWD
now=$(date +'%Y%m%d')
OUTPUT_DIR=$now'_12SV5_output'
mkdir $OUTPUT_DIR
export MPLCONFIGDIR=$OUTPUT_DIR # this environment variable needs a writable directory
cd $OUTPUT_DIR

## Import ######################################################################

singularity exec --bind $wd $2 qiime tools import \
     --type 'SampleData[PairedEndSequencesWithQuality]' \
     --input-path $INPUT_DIR \
     --input-format CasavaOneEightSingleLanePerSampleDirFmt \
     --output-path 1_demultiplexed.qza

singularity exec --bind $wd $2 qiime demux summarize \
  --i-data 1_demultiplexed.qza \
  --o-visualization 1_demultiplexed.qzv

## Trim adapter ################################################################

singularity exec --bind $wd $2 qiime cutadapt trim-paired \
     --i-demultiplexed-sequences 1_demultiplexed.qza \
     --p-adapter-f CTGTCTCTTATACACATCT \
     --p-adapter-r CTGTCTCTTATACACATCT \
     --verbose \
     --o-trimmed-sequences 2_adapter-trimmed.qza \
     &> 2_adapter-trimmed.txt

singularity exec --bind $wd $2 qiime demux summarize \
  --i-data 2_adapter-trimmed.qza \
  --o-visualization 2_adapter-trimmed.qzv

## Trim primers ################################################################

singularity exec --bind $wd $2 qiime cutadapt trim-paired \
     --i-demultiplexed-sequences 2_adapter-trimmed.qza \
     --p-adapter-f ^TAGAACAGGCTCCTCTAG...GCATAGTGGGGTATCTAA\
     --p-adapter-r ^TTAGATACCCCACTATGC...CTAGAGGAGCCTGTTCTA\
     --p-error-rate 0.15 \
     --p-minimum-length 1 \
     --p-overlap 5 \
     --p-discard-untrimmed \
     --verbose \
     --o-trimmed-sequences 3_primer-trimmed.qza \
     &> 3_primer-trimmed.txt

singularity exec --bind $wd $2 qiime demux summarize \
  --i-data 3_primer-trimmed.qza \
  --o-visualization 3_primer-trimmed.qzv

## Denoise sequences ###########################################################

singularity exec --bind $wd $2 qiime dada2 denoise-paired \
     --i-demultiplexed-seqs 3_primer-trimmed.qza \
     --p-trunc-len-f 0 \
     --p-trunc-len-r 0 \
     --p-max-ee-f 2 \
     --p-max-ee-r 2 \
     --p-trunc-q 2 \
     --p-min-overlap 12 \
     --p-pooling-method 'independent' \
     --verbose \
     --o-table 4_denoised-table.qza \
     --o-representative-sequences 4_denoised-seqs.qza \
     --o-denoising-stats 4_denoised-stats.qza \
     &> 4_denoised.txt

## Make feature table ##########################################################

singularity exec --bind $wd $2 qiime metadata tabulate \
     --m-input-file 4_denoised-table.qza \
     --o-visualization 4_denoised-table.qzv

# This maps hash to seqs
singularity exec --bind $wd $2 qiime feature-table tabulate-seqs \
     --i-data 4_denoised-seqs.qza \
     --o-visualization 4_denoised-seqs.qzv

singularity exec --bind $wd $2 qiime metadata tabulate \
     --m-input-file 4_denoised-stats.qza \
     --o-visualization 4_denoised-stats.qzv

# move .err and .out files
mkdir Reports
mv $reportdir/12SV5-pipeline.out ./Reports/'12SV5-pipeline_'$SLURM_JOB_ID'.out'
mv $reportdir/12SV5-pipeline.err ./Reports/'12SV5-pipeline_'$SLURM_JOB_ID'.err'
