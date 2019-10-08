# Introduction

# Instructions

### Copy the stacks-pipeline folder

If using the University of Florida high performance computing resources, also referred to HiPerGator, the stacks-pipeline folder needs to be copied to your personal folder under the `/ufrc/` directory of the HiPerGator system.

### Edit the config file

You need to modify the `config.txt` file with general information about your HiPerGator account. The `email` field is where HiPerGator will send emails when jobs start and end. The `account` field should be set to the account name that has the computing resources you wish to use. The `cores` field should be set to the most cores you want to use simultaneously on HiPerGator. This value should not be higher than the number of cores that the account you use has available. It is important to note that there should not be any empty space on either side of a `=` in the config file.

### Processing raw sequence data

Create a folder for each library/plate in the data folder. The name of the folders should be numbers starting at 1. The compressed fastq sequencing files for each library should be placed in these folders (one library per folder). Each folder should then have a file named `key.txt` that has the sample name and barcode information in it. It's important that each sample name and barcode is separated by a tab; many text editors convert tabs to spaces, which will cause Stacks' process_radtag to fail. In the end, your data folder should have a layout that looks like this:

```
stacks-pipeline
|--data
|  |--1
|  |  |--part1.fq.gz
|  |  |--part2.fq.gz
|  |  |--part3.fq.gz
|  |  |--part4.fq.gz
|  |  |--key.txt
|  |--2
|  |  |--part1.fq.gz
|  |  |--part2.fq.gz
|  |  |--part3.fq.gz
|  |  |--part4.fq.gz
|  |  |--key.txt
...
```

The `config.txt` has a section for the process_radtags parameters that looks like this:
```
# Parameters for process_radtags
process_radtag_param="-e pstI -t 65 -r -c -q"
```
The meaning of these parameters can be found on the Stacks website for the process_radtags program [here](http://catchenlab.life.illinois.edu/stacks/comp/process_radtags.php). The enzyme and read length parameters are likely the only two that you might need to change. Note that the process_radtags parameters for specifying input folders, output folders, and the location of the barcode file are built in to the script and should not be added to the config file.

Once the files and config file are all setup, the program needs to be run. This is done by using a terminal logged into HiPerGator. You need to use the `cd` command to change the directory of the terminal to the `stacks-pipeline` folder. The program is then run using the command `sh 01_process_radtags.sh`.
