#!/bin/bash
#SBATCH -o count-reads.out
#SBATCH -e count-reads.err
#SBATCH -p scavenger
# usage: sbatch count-reads-NoContainer.sh /path/to/qiime 
wd=$PWD
cd $1
for f in [123]*.qzv; do
     unzip $f -d ${f%.qzv}
done
unzip 4_denoised-stats.qzv -d 4_denoised-stats
cd $wd
module load R
Rscript count-reads-noContainer.R $1