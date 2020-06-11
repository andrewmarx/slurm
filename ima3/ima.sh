#!/bin/bash
dos2unix config.txt

. ./config.txt

mkdir -p ./logs/
mkdir -p ./output/
mkdir -p ./script/

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=IMa3
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./logs/%A_%a.txt
#SBATCH --error ./logs/%A_%a.txt
#SBATCH --array=1-${iterations}%1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${cores}
#SBATCH --mem-per-cpu=${mem_per_core}
#SBATCH --time=${iteration_time}
#SBATCH --account=${hpc_account}
#SBATCH --qos=${hpc_account}

module load intel/2019 openmpi/4.0.1 ima3/1.11

start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Starting IMa3\"
echo

SECONDS=0


# Not sure if mpirun would be better than srun
srun --mpi=pmix_v3 IMa3 ${ima3_options}
# mpirun -n ${cores} --mpi=pmix_v1 IMa3 ${ima3_options}

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: IMa3 finished\"
echo \"Time: \${total_time} seconds\"

echo \"\$SLURM_ARRAY_TASK_ID,\$start_time,\$end_time,\${SECONDS}\" >> ./output/stats.csv" > ./script/script.sh


# Create a file to keep track of basic stats
echo "job,start,finish,time" > ./output/stats.csv


sbatch ./script/script.sh
