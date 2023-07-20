## Instructions

Overall, the steps are:
- **Organize the data from the sequencing run**. You will need
	- The raw sequencing data folder from the MiniSeq (usually named along the lines of `MNXXX_XXX`)
	- A sample sheet (`.csv` file) mapping each barcode well (*e.g.* 1-A01, 1-B01, 1-C01, or wells A1, B1, and C1 from barcode plate 1) to 8-basepair forward and reverse barcode sequences. The sample sheet format specifications come from Illumina and are tightly standardized. 
	- A sample data sheet (`.csv` file) mapping barcode wells to any metadata about your samples that is useful for quality control (*e.g.* extraction kit, protocol deviations, Qubit concentrations) or analysis (subject identity, intervention group, sample date, etc.)
- **Access DCC, do initial set up, and transfer data and sample sheet to the cluster**.
- **Run the pipeline**.  This consists of two steps, each with an accompanying script:
	1. Demultiplexing: `demux-barcodes.sh`
	2. Convert raw reads to inferred ASVs: `trnL-pipeline.sh`
- **Transfer processed data back to your local machine.**
- **Convert the processed data to a phyloseq object.** This is done in R using the notebook `Pipeline to phyloseq.Rmd`.

## Access and set up DCC

### Access

The Duke Compute Cluster (DCC) can be accessed by running the following in the terminal:

```
ssh netid@dcc-login.oit.duke.edu
```

Sharon can add you to our lab group account if you don't yet have access, and Ben wrote a [helpful guide](https://3.basecamp.com/3853188/buckets/23891967/uploads/4134861105) to using DCC.

### Setup

The only packages required by the pipeline scripts are Illumina's `bcl2fastq` (available as a pre-installed module on the cluster) and QIIME2. I (TM) created a Singularity container containing the 2023.5 version of QIIME2 using Duke Gitlabs, which is hosted here: https://gitlab.oit.duke.edu/lad-lab/qiime2

## Download container
```
> curl -O https://research-singularity-registry.oit.duke.edu/lad-lab/qiime2.sif 
```
## Transfer data to DCC

To move data on and off the cluser, use the `scp` command, which always takes the following form:

```
> scp [/path/to/data/source] [/path/to/data/destination]
```

If you are transfering an entire folder (like the raw MiniSeq data or the output of the pipeline), you'll need to add the "recursive" flag by using `scp -r`. For transfering a MiniSeq run from Isilon on a Mac, this might look something like the following:

```
scp -r /Volumes/All_Staff/Sequencing/Sequencing2023/230111_MN00462_0022_A000H5CCNH/ [netID]@dcc-login.oit.duke.edu:/hpc/group/ldavidlab/users/blp23/seqdata/20230111_WholyCow_trnL_12SV5
```

Because the `home` directory on DCC has limited storage, it's helpful to store data on our `group` area of DCC, which can be found at `/hpc/group/ldavidlab/`.  You can make a folder for yourself in `/hpc/group/ldavidlab/users`: I usually transfer my sequencing data there inside a descriptive folder name that allows me to easily navigate to it. 

Using this strategy, transfer both
- the **raw MiniSeq data folder** and
- the **sample sheet**
to a location on DCC where you can easily find them for the next pipeline steps. I recommend keeping both files together in their own directory with a short descriptive title, ie:
```
/path/to/FoodSeq-USA-teens
	<Miniseq data folder>
	samplesheet.csv
```

## Demultiplex

Next, we'll pick up with processing the data *on* DCC.  For these steps, you'll also need the actual scripts to process the data on the cluster. If you don't have them there already, use `scp` to transfer `demux-barcodes.sh` and `trnL-pipeline.sh` to DCC.  I tend to keep these in my home directory rather than the group directory, but you can keep them wherever is convenient for you to remember and easy to access.

## Run pipeline

First, run the demux-barcodes.sh script:
```
sbatch --mail-user=<youremail>@duke.edu demux-barcodes.sh /path/to/XXXXXX_MNXXXXX_XXXX_XXXXXXXXXX /path/to/samplesheet.csv
```
This will take ~1hr depending on how many samples were in the sequencing run. The output will result in a file structure that looks like this:
```
/path/to/
	XXXXXX_MNXXXXX_XXXX_XXXXXXXXXX
	XXXXXXXX_results
		demultiplexed
			<your demultiplexed .fastq.gz files will be here>
		Reports
			demux-barcodes-<jobid>.err
			demux-barcodes-<jobid>.out
```

Next, run the trnL-pipeline.sh script:
```
sbatch --mail-user=<youremail>@duke.edu trnL-pipeline.sh /path/to/demultiplexed /path/to/qiime2.sif
```
This will take several hours
## OPTIONAL: Count reads on cluster
The output files from trnL-pipeline.sh are pretty large and you only need 2 of them to build the phyloseq object. If you prefer, you can run the first QC step while still on the cluster so you don't have to download all the files.

To do this, you will need the R package tidyverse. I have it installed in the metabarcoding container, which you can download with this command: 
```
> curl -O https://research-singularity-registry.oit.duke.edu/lad-lab/metabarcoding.sif 
```
Now run count-reads.sh:
```
sbatch count-reads.sh /path/to/qiime-dir /path/to/metabarcoding.sif
```
This script will unzip the qiime output files and then run count-reads.R, which pulls the read count information from each step of the trnL pipeline. This will write a file called track-pipeline.csv, which will have the read counts for each sample at each step.

## Make phyloseq object

### Make phyloseq object locally
Code to organize the pipeline output into an ASV table and taxonomy table for a phyloseq is in the R notebook `Pipeline to phyloseq.Rmd`.

If it's your first time running this notebook you'll likely need to install the packages it uses.

`here` and `tidyverse` can be installed with base R's package installation function:
```
install.packages('here')
install.packages('tidyverse')
```

`phyloseq` needs to be installed using BiocManager:
```
(!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("phyloseq")
BiocManager::install("dada2")
BiocManager::install("ShortRead")
```

`MButils` and `qiime2R` need to be installed from GitHub:
```
(!require("devtools", quietly = TRUE))
    install.packages("devtools")

devtools::install_github('ammararuby/MButils')
devtools::install_github('jbisanz/qiime2R')
```



