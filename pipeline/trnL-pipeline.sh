#!/bin/bash
#SBATCH --job-name=trnL-pipeline
#SBATCH --mem=20000
#SBATCH --partition scavenger 
#SBATCH --out=/hpc/home/%u/trnL-pipeline-%j.out
#SBATCH --error=/hpc/home/%u/trnL-pipeline-%j.err
#SBATCH --mail-user=blp23@duke.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# Usage: 
# sbatch trnL-pipeline.sh /path/to/demux-dir reference-reads reference-taxonomy

## Set up input, output directories ############################################

INPUT=$1
cd $INPUT/..
mkdir ${1##*/}_output
cd ${1##*/}_output

source /hpc/home/blp23/miniconda3/etc/profile.d/conda.sh
conda activate qiime2-2022.8

## Import ######################################################################

qiime tools import \
     --type 'SampleData[PairedEndSequencesWithQuality]' \
     --input-path $INPUT \
     --input-format CasavaOneEightSingleLanePerSampleDirFmt \
     --output-path 1_demultiplexed.qza
     
qiime demux summarize \
  --i-data 1_demultiplexed.qza \
  --o-visualization 1_demultiplexed.qzv

## Trim adapter ################################################################

qiime cutadapt trim-paired \
     --i-demultiplexed-sequences 1_demultiplexed.qza \
     --p-adapter-f CTGTCTCTTATACACATCT \
     --p-adapter-r CTGTCTCTTATACACATCT \
     --verbose \
     --o-trimmed-sequences 2_adapter-trimmed.qza \
     &> 2_adapter-trimmed.txt

qiime demux summarize \
  --i-data 2_adapter-trimmed.qza \
  --o-visualization 2_adapter-trimmed.qzv
     
## Trim primers ################################################################

qiime cutadapt trim-paired \
     --i-demultiplexed-sequences 2_adapter-trimmed.qza \
     --p-adapter-f ^GGGCAATCCTGAGCCAA...GATAGGTGCAGAGACTCAATGG \
     --p-adapter-r ^CCATTGAGTCTCTGCACCTATC...TTGGCTCAGGATTGCCC \
     --p-error-rate 0.15 \
     --p-minimum-length 1 \
     --p-overlap 5 \
     --p-discard-untrimmed \
     --verbose \
     --o-trimmed-sequences 3_primer-trimmed.qza \
     &> 3_primer-trimmed.txt
     
qiime demux summarize \
  --i-data 3_primer-trimmed.qza \
  --o-visualization 3_primer-trimmed.qzv

## Denoise sequences ###########################################################

qiime dada2 denoise-paired \
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

qiime metadata tabulate \
     --m-input-file 4_denoised-table.qza \
     --o-visualization 4_denoised-table.qzv

# This maps hash to seqs
qiime feature-table tabulate-seqs \
     --i-data 4_denoised-seqs.qza \
     --o-visualization 4_denoised-seqs.qzv

qiime metadata tabulate \	
     --m-input-file 4_denoised-stats.qza \
     --o-visualization 4_denoised-stats.qzv
