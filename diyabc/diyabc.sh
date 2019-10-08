#!/bin/bash
dos2unix config.txt
dos2unix data/header.txt
dos2unix data/*.DIYABC.snp
. ./config.txt

module load diyabc

if [ -d "./output" ]; then
  rm -r ./output
fi

mkdir ./output/
mkdir ./output/rng/
mkdir ./output/jobs/
mkdir ./output/final/
mkdir ./output/logs/

diyabc_core -p ./output/rng/ -n "t:1;c:$total_jobs;s:-1"

rng_list=(./output/rng/RNG*.bin)

for ((n=0;n<$total_jobs;n++)); do
    mkdir ./output/jobs/"${n}"/

    cp "${rng_list[${n}]}" ./output/jobs/"${n}"/
done

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=diyabc
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/logs/%a.out
#SBATCH --error ./output/logs/%a.out
#SBATCH --array=0-$((total_jobs - 1))%${max_simultaneous_jobs}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=${mem_per_job}
#SBATCH --time=${max_time_per_job}
#SBATCH --account=${hpc_account}
#SBATCH --qos=${hpc_account}

module load diyabc

cp ./data/* ./output/jobs/\$SLURM_ARRAY_TASK_ID/

start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Starting diyabc simulations\"
echo

SECONDS=0

diyabc_core -t 1 -p ./output/jobs/\$SLURM_ARRAY_TASK_ID/ -w \$SLURM_ARRAY_TASK_ID -r $simulations_per_job

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: diyabc finished\"
echo \"Time: \${total_time} seconds\"

echo \"\$SLURM_ARRAY_TASK_ID,\$start_time,\$end_time,\${SECONDS}\" >> ./output/stats.csv

mv ./output/jobs/\$SLURM_ARRAY_TASK_ID/reftable.bin ./output/final/reftable_\$SLURM_ARRAY_TASK_ID.bin" > ./output/script.sh


# Create a file to keep track of basic stats
echo "job,start,finish,time" > ./output/stats.csv


# Create a script for merging the reftables
echo "#!/bin/bash

module load diyabc

diyabc_core -p ./output/final/ -q" > ./merge_reftables.sh

sbatch ./output/script.sh
