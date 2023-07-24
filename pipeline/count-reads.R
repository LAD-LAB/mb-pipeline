library(tidyverse)
args=commandArgs(trailingOnly=TRUE)
qiime.dir=args[1]
print(paste('qiime directory set to',qiime.dir))
count.fs <- list.files(qiime.dir,
                pattern = "per-sample-fastq-counts.tsv|metadata.tsv",
                recursive = TRUE,
                full.names = TRUE)

print("found the following count files")
print(count.fs)
for (i in seq_along(count.fs)) {
  f=count.fs[i]
  split_result=unlist(str_split(f,"/")) # unzipped qiime directories go /name-of-qzv/random-numbers/data/file.tsv
  dirName=split_result[length(split_result) - 3] # so I can access what step of the pipeline the file came from by going back 3
  f=read_delim(f)
  if (dirName=='4_denoised-table') {
    break # this file doesn't have read count info
  }
  if (dirName=='4_denoised-stats') {
    f=f[-1,] %>%
      mutate(sample_ID=`sample-id`) %>%
      dplyr::select(sample_ID,filtered,denoised,merged,`non-chimeric`) 
    
  } 
  else {
  colnames(f)=str_replace_all(colnames(f),fixed(" "),"_")
  f$reverse_sequence_count=NULL
  colnames(f)[2]=dirName }
  if (i==1) {
    count.files=f
  } else {
    count.files=left_join(count.files,f,by='sample_ID')
  }
}
print('count table prior to renaming')
head(count.files)
if (length(colnames(count.files)) !=8) {
  print(paste('Unexpected number of columns:' length(colnames(count.files))))
  print('Expected number of columns: 8')
  print('Are you missing output files from trnL-pipeline.sh? Are there extra directories in your qiime-dir?')
}
names(count.files) <- c('sample', 
                         'raw',
                         'adapter_trim',
                         'primer_trim',
                        'filtered',
                        'denoised',
                        'merged',
                        'non_chimeric')
print('your count table')
count.files
write.csv(count.files,file.path(qiime.dir,
                                'track-pipeline.csv'))
