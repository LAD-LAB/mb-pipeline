#!/bin/bash
#SBATCH --job-name=demux-barcode
#SBATCH --mem=20000
#SBATCH --partition scavenger 
#SBATCH --out=demux-barcode-%j.out
#SBATCH --error=demux-barcode-%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# Usage: demux-barcode.sh /miniseq-dir /path/to/samplesheetname /path/to/metabarcoding.sif
# Example: sbatch demux-barcode.sh path/to/miniseq-dir /path/to/samplesheet.csv 
wd=$PWD
cd $1/..
datadir=$PWD
now=$(date +'%Y%m%d') # set output directory name to current date
outdir=$now'_results'
mkdir $outdir
mkdir $outdir/demultiplexed

# Demultiplex
singularity exec --bind $datadir $3 bcl2fastq -o $outdir/demultiplexed --interop-dir InterOp/$now --stats-dir Stats/$now --reports-dir Reports/$now --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0 --sample-sheet $2

# move .err and .out files
mkdir $outdir/Reports
mv $wd/'demux-barcode-'$SLURM_JOB_ID'.out' $outdir/Reports
mv $wd/'demux-barcode-'$SLURM_JOB_ID'.err' $outdir/Reports
