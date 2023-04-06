# Rscript-echo.R

# Using a combination of source() and sink(), get Rscript to produce an .Rout file like that
# produced by R CMD BATCH. 

# Command-line usage: Rscript Rscript-echo.R [Primary script name] [Primary script args]
# Remember to adjust args indices of receiving script accordingly!

args <- commandArgs(TRUE)
srcfile <- args[1]

outfile <- file.path(dirname(args[2]), paste0(make.names(date()), '.Rout'))

sink(outfile, split=TRUE)
source(srcfile, echo=TRUE)
