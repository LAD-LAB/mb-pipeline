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

The only packages required by the pipeline scripts are Illumina's `bcl2fastq` (available as a pre-installed module on the cluster) and QIIME2.  Ultimately, we can maintain an installation of QIIME2 in a container that everyone can use for ease and reproducibility.  However, I (BP) can't get this to work currently with our 16S or metabarcoding containers.

Without a container at present, you'll need to make your own QIIME2 installation.  I recommend the following steps for doing this:

1. **Install Miniconda** in your home directory on DCC (`/hpc/home/[your NetID]/`). 
Following the instructions [here](https://conda.io/projects/conda/en/latest/user-guide/install/linux.html), download the installer and transfer 
it onto DCC. Then follow the instructions as written. 
2. **Use Miniconda to install QIIME2.**
Pick up the [QIIME2 installation instructions](https://docs.qiime2.org/2023.2/install/native/#updating-miniconda) beginning under the header **Updating Miniconda**. Select the QIIME2 release under the Linux tab, since we'll be using it on DCC (which runs Linux).

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
to a location on DCC where you can easily find them for the next pipeline steps.

## Demultiplex

Next, we'll pick up with processing the data *on* DCC.  For these steps, you'll also need the actual scripts to process the data on the cluster. If you don't have them there already, use `scp` to transfer `demux-barcodes.sh` and `trnL-pipeline.sh` to DCC.  I tend to keep these in my home directory rather than the group directory, but you can keep them wherever is convenient for you to remember and easy to access.

## Run pipeline

## Make phyloseq object

Code to organize the pipeline output into an ASV table and taxonomy table for a phyloseq is in the R notebook `Pipeline to phyloseq.Rmd`.

If it's your first time running this notebook you'll likely need to install the packages it uses.

`here` and `tidyverse` cna be installed with base R's package installation function:
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



