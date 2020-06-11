
##### Configuration
The config.txt file is the only file that should generally be modified by users. Most of the settings should be straightforward. The `ima3_options` variable takes a string that is exactly what you would use if running IMa3 directly.

Then main thing to be aware of is that the script is designed to be run repeatedly. This allows runs to be extended easily, but also makes it easier to break down long runs into shorter chunks that won't cause issues on the supercomputer. In order for this to work, the `-r` parameter in `ima3_options` must include the `7` value.

To aid in running the script repeatedly, it is possible to specify how many times the script should be run using the `iterations` option (minimum should be `1`). The value set for the `-L` option in `ima3_options` should be adjusted accordingly.

##### IMa2 to IMa3 command line changes
Be aware that some of the options have changed in the transition from IMa2 to IMa3. There is a cheatsheet on the changes here: https://github.com/jodyhey/IMa3/blob/master/documentation/IMa2_IMa3_commandline_conversion_cheatsheat.txt

*Note: I haven't verified that this cheatsheet is up to date*

##### Running the script
Running the script: `sh ima.sh`

##### Default folders
The script doesn't require any folders to be present, but will create several if they aren't. These include:

- logs: output will be put into log files here. Names are based on the job number and iteration
- script: The automatically created slurm script is placed here. In general, you shouldn't have to do anything with it.
- output: This folder is created, but only will be used if you specify it in the ima3_options variable. It is recommended that you do use it to help keep things organized.

##### Extending runs
To extend the runs, just rerun `sh ima.sh`. As long as the `-r` parameter has the `7`* option included, it will store the state after each iteration and reload it when starting a new iteration. The `2` option should not be necessary.

##### Changing parameters
The way the script is setup, it will always try to build on the output of previous runs. This means that if you try to change the parameters, you must also delete the old output. If you are using the output folder, then all you have to do is delete that folder.
