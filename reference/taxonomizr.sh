#!/bin/bash
#SBATCH --job-name=taxonomizr
#SBATCH --partition common-old,scavenger 
#SBATCH --mem=64000
#SBATCH -n 2  # Number of cores
#SBATCH --out=taxonomizr-%j.out
#SBATCH --error=taxonomizr-%j.err
#SBATCH --mail-user=blp23@duke.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# Usage: taxonomizr.sh /path/to/SQL/directory 

# source QIIME2 environment
source /hpc/home/blp23/miniconda3/etc/profile.d/conda.sh
conda activate qiime2-2022.8

# load R and run taxonomizr script
Rscript Rscript-echo.R taxonomizr.R $1
