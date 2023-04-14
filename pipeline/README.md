## Instructions

Overall, the steps are:
- **Access DCC and do initial set up**.
	- Currently I run these scripts using QIIME2 running in conda environment I installed in my home directory on DCC.  However, don't want to go back to everyone needing to maintain their own installations.   Ultimately, we could adapt these scripts to use QIIME2 in a shared container.  I'Tried running w both metabarcoding and 16S containers, but may be using 
incorrectly, not able to get to work
- **Run the pipeline**.  This consists of two steps, each with an accompanying script:
	1. *Demultiplexing*: `demux-barcodes.sh`
	2. *Convert raw reads to inferred ASVs*: `trnL-pipeline.sh`


### Access and set up DCC

The Duke Compute Cluster (DCC) can be accessed by running the following in the terminal:

```
ssh netid@dcc-login.oit.duke.edu
```

Sharon can add you to our lab group account if you don't yet have access, and Ben wrote a [helpful guide](https://3.basecamp.com/3853188/buckets/23891967/uploads/4134861105) to using DCC.

Without a container at preset, you'll need to install your own miniconda following instructions 
[here](https://conda.io/projects/conda/en/latest/user-guide/install/linux.html), get 
installer, scp it onto DCC, then follow latter steps. 
  
## Install R packages

## Transfer sequencing data to DCC

To move data on and off the cluser, use the `scp` command:

```
> scp -r path/to/raw/MN000_directory/ your
```

