#!/bin/bash
#SBATCH -o count-reads.out
#SBATCH -e count-reads.err
#SBATCH -p scavenger
# usage: sbatch count-reads.sh /path/to/qiime /path/to/metabarcoding.sif 
wd=$PWD
cd $1
for f in [123]*.qzv; do
     unzip $f -d ${f%.qzv}
done
unzip 4_denoised-stats.qzv -d 4_denoised-stats
cd $wd
singularity exec --bind $1,$PWD $2 Rscript count-reads.R $1
