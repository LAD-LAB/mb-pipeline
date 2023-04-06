
# Prepare NCBI taxonomy SQL database on cluster (runs out of memory locally) 

# Setup -----------------------------------------------------------------------

args <- commandArgs(trailingOnly=TRUE) 
print(args)
setwd(args[2]) # Set the directory

library(taxonomizr); packageVersion('taxonomizr') # Read in library

tempdir() # Check setting of temp directory
system("df -Ph $TMPDIR")

# Format SQL database ---------------------------------------------------------
prepareDatabase('accessionTaxa.sql')
