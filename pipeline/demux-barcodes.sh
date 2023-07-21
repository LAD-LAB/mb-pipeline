#!/bin/bash
#SBATCH --job-name=demux-barcode
#SBATCH --mem=20000
#SBATCH --partition scavenger
#SBATCH --out=demux-barcode-%j.out
#SBATCH --error=demux-barcode-%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# Usage: demux-barcode.sh /miniseq-dir /path/to/samplesheetname /path/to/metabarcoding.sif
# Example: sbatch demux-barcode.sh path/to/miniseq-dir /path/to/samplesheet.csv /hpc/group/ldavidlab/metabarcoding.sif


codedir=$PWD
cd $1
cd ..
parent=$PWD
now=$(date +'%Y%m%d')
resFolder=$now'_results'
outdir=$parent/$resFolder
mkdir $outdir

cd $1

singularity exec --bind $parent $3 bcl2fastq -o $outdir --interop-dir InterOp/$now --stats-dir Stats/$now --reports-dir Reports/$now --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0 --sample-sheet $2

# Clean up directory structure
mkdir $outdir/demultiplexed
mv $outdir/*.fastq.gz $outdir/demultiplexed/

# move .err and .out files
mkdir $outdir/Reports
mv $codedir/'demux-barcode-'$SLURM_JOB_ID'.out' $outdir/Reports
mv $codedir/'demux-barcode-'$SLURM_JOB_ID'.err' $outdir/Reports
