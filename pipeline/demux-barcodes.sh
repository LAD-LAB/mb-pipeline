#!/bin/bash
#SBATCH --job-name=demux-barcode
#SBATCH --mem=20000
#SBATCH --partition scavenger 
#SBATCH --out=demux-barcode-%j.out
#SBATCH --error=demux-barcode-%j.err
#SBATCH --mail-user=blp23@duke.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# Usage: demux-barcode.sh /miniseq-dir samplesheetname 
# Example: sbatch demux-barcode.sh path/to/miniseq-dir /path/to/sample/sheet.csv 
cd $1
now=$(date +'%Y%m%d')
outdir=$now'_results'
mkdir $outdir

# Demultiplex
module load bcl2fastq
bcl2fastq -o $outdir --interop-dir InterOp/$now --stats-dir Stats/$now --reports-dir Reports/$now --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0 --sample-sheet $2

