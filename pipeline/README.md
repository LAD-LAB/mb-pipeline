## Instructions

Currently I run these scripts using QIIME2 running in conda environment I installed in 
my home directory on DCC.  However, don't want to go back to everyone needing to 
maintain their own installations.  Options are 

- Use a container (only needs QIIME2 inside)
	[-] Tried running w both metabarcoding and 16S containers, but may be using 
incorrectly, not able to get to work

- Share an exported conda environment (YAML file) from my current environment
	- So then what everyone would need to do is install their own miniconda
	- Following instructions 
[here](https://conda.io/projects/conda/en/latest/user-guide/install/linux.html), get 
installer, scp it onto DCC, then follow latter steps
	- Then, put exported environment file onto DCC too and run `conda-env create -n 
my_env -f=my_env.yml`, naming the file and environment as desired
  
