A collection of scripts I wrote for myself and others to simplify the process of running certain analyses on UF's supercomputer. Essentially, the scripts use a config file with basic information to generate a custom optimized slurm script and automatically submit it to the scheduler. This removes most of the complexity involved for users that are less experienced with the process.

Some key goals of these scripts:
- Simplify the process of using the supercomputer for less technical users
- Automatically optimize analyses given pre-defined resources to minimize the time and experience needed to obtain good performance and not waste resources
- Automate analyses that require a complex sequence of steps and implement a crude system to avoid rerunning unnecessary steps when parameters need to be tweaked
- Minimize file system usage by cleaning up or avoiding intermediate files not needed at the end of an analysis

These scripts are old and may need updates to work properly.
