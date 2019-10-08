# Introduction

The files in this folder create a simple method for using UF's supercomputer to run diyabc simulations across multiple cores. It automatically generates the necessary slurm script for the supercomputer so that you do not have to do it yourself. All you have to do is modify a few parameters in the config file, copy your data files into the data folder, and run one script.

# Instructions

1. Copy your header.txt file and genetic data file into the data folder

2. Update the parameters in the config.txt file

3. Copy everything to the supercomputer

4. Use a terminal to navigate to the folder containing the diyabc.sh file.

5. Run the *diyabc.sh* file using the following command: ***sh ./diyabc.sh***

6. Once the jobs are finished, run the *merge_reftables.sh* file using the following command: ***sh ./merge_reftables.sh***

7. Copy the *reftable.bin* file in *./output/final/* to your diyabc project folder and restart diyabc.

# Files and Folders

## ./data/

This folder contains the header.txt file that has your scenario information, and a data file with your genetic information.

## ./output/

This folder is created automatically by the script. If the script detects that this folder already exists, it will delete it first before creating a new version. Everything generated is placed in here.

## ./output/jobs/

The script will create a numbered folder for every job run by the supercomputer. Files necessary for every job will be copied into these, and the output from every job will be generated here.

## ./output/final/

When each job finishes running, the reftable it created will be moved into this folder so that they are all in one convenient location

## ./output/logs/

This folder will contain all the numbered log and error files from each job.

## ./output/script.sh

This is the actual slurm script run by the supercomputer to do the diyabc simulations. It is automatically generated and run, so you should not have to modify it or use it directly.

## ./output/stats.csv

This is simple csv file that records the start time, end time, and run time (in seconds) for each job. This information can be useful for judging how much time should be allocated to each job.

## ./diyabc.sh

This is the script you run to setup and start diyabc on the supercomputer.

It creates the necessary output folders, RNG files for diyabc, creates a custom slurm script based on the config file, and then starts the slurm script for you. Note that it will delete all previous copies of these files and folders everytime you run it.

To run it, you use the terminal to navigate to the folder on the supercomputer that contains this file and use the following command: ***sh ./diyabc.sh***

## ./merge_reftables.sh

This is automatically created by the diyabc script. After the jobs have completed, you run this to merge your reftables using the following command: ***sh ./merge_reftables.sh***

## ./config.txt

This file contains all the parameters needed for setting up the scripts. The name of the parameter should be followed by an equals sign (**=**), then by a value for the parameter. There should be no spaces on either side of the equals sign. Using a config file makes it possible to customize things without having to understand and modify the script files.

* *email*

 This is the email that the supercomputer will use to let you know that jobs have started and ended.

* *max_simultaneous_jobs*

 This is the maximum number of jobs that you want the supercomputer to run simultaneously. It should not be set higher than the number of computing cores that your group has access to.

* *total_jobs*

 This is the number of jobs that you want to split your diyabc simulations across. It can be higher or lower than *max_simultaneous_jobs*. If it is lower, then it will run all the jobs at once without using your entire core limit. If it is higher, then it will only run up to *max_simultaneous_jobs* at a time, and as they finish, new jobs will be started until you've reached *total_jobs*

* *max_time_per_job*

 The amount of time each job is allowed to run. If a job exceeds this time limit, it will fail. The higher the time limit set here, the longer it might spend waiting in the queue before the supercomputer decides to run it. The amount of time you need to set will depend on the complexity of your scenarios and the number of simulations you set per job in the *simulations_per_job* variable.

* *mem_per_job*

 The amount of memory that should be alloted for each job. Like the *max_time_per_job* variable, the more memory you request per job, the longer your jobs could be spent waiting in the queue. Fortunately, I do not think the amount of memory you need will vary with the number of simulations, and maybe only a little with scenario complexity.

 Be aware that ***mem_per_job x max_simultaneous_jobs*** should be less than or equal to the total memory that the group has paid access to. For the UF supercomputer, groups are given 3gb of memory for every core they have purchased.

* *simulations_per_job*

 The number of diyabc simulations that you want each individual job to perform. Multiplying this value by *total_jobs* will give you your total number of diyabc simulations.

* *hpc_account*

 The name of the group that you want to run the jobs under. The group will have to have cores available for you to use.

# Tips

Splitting your total simulations across a larger number of jobs (*total_jobs*) reduces the amount of time that each job will need to run. This makes it more likely that they will get moved out of the supercomputer's queue sooner, making the overall process potentially faster.

Additionally, smaller jobs will finish faster, and you can start using results from the jobs that finish first while waiting for the rest to finish. As jobs finish, their reftable files will be placed into the *./output/final/* folder. Just copy the ones that have finished to your computer to use them.

When everything is finished, consider creating a compressed archive of everything. This way you have a backup of the data files, scripts, configuration, and output in one place. And if anyone ever wants to verify your procedure or reproduce your results, everything they need will be in the archive.


[//]: # (Convert to pdf: pandoc readme.md -o readme.pdf -V geometry:margin=1in)
