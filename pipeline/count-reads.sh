#!/bin/bash
#SBATCH -o count-reads.out
#SBATCH -e count-reads.err
#SBATCH -p scavenger
# usage: sbatch count-reads.sh /path/to/qiime /path/to/where-scripts-are-stored /path/to/metabarcoding.sif 
wd=$PWD
cd $1
for f in [123]*.qzv; do
     unzip $f -d ${f%.qzv}
done
unzip 4_denoised-stats.qzv -d 4_denoised-stats
cd $wd
singularity exec --bind $1,$2,$PWD $3 Rscript $2/count-reads.R $1

cd $1/..
mv $wd/count-reads.out ./Reports
mv $wd/count-reads.err ./Reports
