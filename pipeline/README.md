## Instructions

Overall, the steps are:
- **Organize the data from the sequencing run**. You will need
	- The raw sequencing data folder from the MiniSeq (usually named along the lines of `MNXXX_XXX`)
	- A sample sheet (`.csv` file) mapping each barcode well (*e.g.* 1-A01, 1-B01, 1-C01, or wells A1, B1, and C1 from barcode plate 1) to 8-basepair forward and reverse barcode sequences. The sample sheet format specifications come from Illumina and are tightly standardized. See the "reference" folder for a template sample sheet.
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

The only packages required by the pipeline scripts are Illumina's `bcl2fastq` and QIIME2. I (TM) created a Singularity container containing the 2023.5 version of QIIME2 using Duke Gitlabs. It is located at /hpc/group/ldavidlab/qiime2.sif. The singularity container metabarcoding.sif has bcl2fastq already installed and is is located at /hpc/group/ldavidlab/metabarcoding.sif.

## Transfer data to DCC

To move data on and off the cluser, use the `scp` command, which always takes the following form:

```
> scp [/path/to/data/source] [/path/to/data/destination]
```

If you are transfering an entire folder (like the raw MiniSeq data or the output of the pipeline), you'll need to add the "recursive" flag by using `scp -r`. 
```
> scp -r [/path/to/data-dir] [/path/to/data/destination]
```

### How to transfer data from Isilon (Mac instructions)
For transfering a MiniSeq run from Isilon on a Mac, sometimes it only works if you navigate inside the Isilon folder from the terminal and then upload the data from there. 
#### Step 1: Connect to the Duke vpn
https://oit.duke.edu/service/vpn/ 
Open the Cisco AnyConnect application. Enter vpn.duhs.duke.edu as the vpn you want to connect to. It will ask you to enter your password and a passcode from the Duo app for 2-step authentication. 

#### Step 2: Connect to Isilon
Next, open the application "Finder". At the top of your screen, click "Go". Click "Connect to Server." Now enter 'smb://duhsnas-pri.dhe.duke.edu/dusom_mgm-david/All_Staff' and connect. (You will need to enter your netID and password). 

#### Step 3: Upload sequence data
Open the terminal. Navigate inside the Isilon folder:
```
cd /Volumes/All_Staff/Sequencing/Sequencing2023/
```
Now you can upload the sequence data directly to Isilon:
```
# EXAMPLE
scp -r 230111_MN00462_0022_A000H5CCNH [netID]@dcc-login.oit.duke.edu:/hpc/group/ldavidlab/users/blp23/seqdata/20230111_WholyCow_trnL_12SV5
```

Because the `home` directory on DCC has limited storage, it's helpful to store data on our `group` area of DCC, which can be found at `/hpc/group/ldavidlab/`.  You can make a folder for yourself in `/hpc/group/ldavidlab/users`: I usually transfer my sequencing data there inside a descriptive folder name that allows me to easily navigate to it. 
### Upload sample sheet
The "TEMPLATE_samplesheet.csv" file in this repository has all of the barcode sequences used by this lab. Download the file, delete the rows for the barcodes you don't need, and upload the file:
```
scp /path/to/samplesheet.csv <netid>@dcc-login.oit.duke.edu:/path/to/destination
```
Using this strategy, you should now have transferred
- the **raw MiniSeq data folder** and
- the **sample sheet**
to a location on DCC where you can easily find them for the next pipeline steps. I recommend keeping both files together in their own directory with a short descriptive title, ie:
```
/path/to/FoodSeq-USA-teens
	<Miniseq data folder>
	samplesheet.csv
```

## Upload analysis files
Next, we'll pick up with processing the data *on* DCC.  For these steps, you'll also need the actual scripts to process the data on the cluster. I (BP) tend to keep these in my home directory rather than the group directory, but you can keep them wherever is convenient for you to remember and easy to access.  
### Option 1: clone the repository onto the DCC
You can clone this repository directly onto the DCC using "git clone". This is the fastest way to get the scripts you need and will give you the most recent versions of the scripts. If you are prompted for your password, follow the instructions here to generate an access token: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens. Enter the access token instead of your password.
```
# connect to the DCC
ssh <netid>@dcc-login.oit.duke.edu

# navigate to where you want to keep these scripts
cd /hpc/group/ldavidlab/<user>

# clone respository
git clone https://github.com/LAD-LAB/mb-pipeline.git
<enter Github username>
<enter access token in place of password>
```
#### Option 2: Download the files and then upload
You can also just download the files locally and then upload to the DCC. After downloading the file, you can upload it to the DCC like this:
```
scp /path/to/demux-barcodes.sh <netid>@dcc-login.oit.duke.edu:/path/to/destination
```
You'll need to do this for each file. 
#### Option 3: Open blank file and paste code
Useful if a file has been updated and you are like me (TM) and don't know how to use push/pull with Github but need to quickly get a new version of a script:
```
# connect to the DCC
ssh <netid>@dcc-login.oit.duke.edu

# navigate to where you want to keep these scripts
cd /hpc/group/ldavidlab/<user>

# write file
vim demux-barcodes.sh
i # this means "insert" and lets you enter insert mode
<PASTE CODE> #copy code from this repository and then command + V to paste)
<press the escape key> # this exits insert mode
:wq # w means save and q means quit. This will save the file and then exit. 
```
Do this for each file. 
# Run pipeline
The R notebook "script-writer.Rmd" will write the correct sbatch commands for you. Just open the R notebook and enter your run information at the top, then follow the instructions to generate the correct sbatch commands. 
## Demultiplex

First, run the demux-barcodes.sh script. 
```
# connect to the DCC
ssh <netid>@dcc-login.oit.duke.edu
# navigate to wherever you store the demux-barcodes.sh script
cd /path/to/mb-pipeline
# enter command using following structure ('script-writer.Rmd' can also generate this for you)
sbatch --mail-user=<youremail>@duke.edu demux-barcodes.sh /path/to/XXXXXX_MNXXXXX_XXXX_XXXXXXXXXX /path/to/samplesheet.csv /hpc/group/ldavidlab/metabarcoding.sif
```
This will take 20min-1hr depending on how many samples were in the sequencing run. You can check on the status of the job with this command:
```
squeue -u <netid>
```
This will show all of the jobs that you have currently running.

The output will result in a file structure that looks like this:
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
# you can once again use 'script-writer.Rmd' to generate this command for you
sbatch --mail-user=<youremail>@duke.edu trnL-pipeline.sh /path/to/demultiplexed /hpc/group/ldavidlab/qiime2.sif
```
This may take several hours
## OPTIONAL: Count reads on cluster
The output files from trnL-pipeline.sh are pretty large and you only need 2 of them to build the phyloseq object. If you prefer, you can run the first QC step while still on the cluster so you don't have to download all the files.
```
sbatch count-reads.sh /path/to/qiime-dir /path/to/qiime2.sif
```
This will only take a few seconds to run.
\n
The count-reads script will unzip the qiime output files and then run the Rscript, which pulls the read count information from each step of the trnL pipeline. This will write a file called track-pipeline.csv, which will have the read counts for each sample at each step.

## Make phyloseq object

Code to organize the pipeline output into an ASV table and taxonomy table for a phyloseq is in the R notebook `Pipeline to phyloseq.Rmd`.

If it's your first time running this notebook you'll likely need to install the packages it uses. The code for installing all required packages is already in the R notebook, just commented out, but for further explanation see below:

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



