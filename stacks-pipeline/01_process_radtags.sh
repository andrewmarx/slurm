#!/bin/bash

. ./config.txt

rm -r ./output
rm -r ./results

mkdir -p ./output/
mkdir -p ./output/samples/
mkdir -p ./output/logs/
mkdir -p ./output/logs/process_radtags/
mkdir -p ./scripts/process/

process_jobs=$(find ./data/* -maxdepth 0 -type d | wc -l)
slurm_modules="stacks/2.1"

echo "#!/bin/bash

#SBATCH --job-name=process_radtags
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/logs/process_radtags/process_radtag_%a.log
#SBATCH --error ./output/logs/process_radtags/process_radtag_%a.log
#SBATCH --array=1-${process_jobs}%${cores}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10gb
#SBATCH --time=10:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}

echo \"\$(date '+%F %T'): Starting script\"
echo

seq_libraries=(./data/*/)

process_radtags -p ./data/\${SLURM_ARRAY_TASK_ID} -o ./output/samples/ -b ./data/\${SLURM_ARRAY_TASK_ID}/key.txt ${process_radtag_param}

echo
echo \"\$(date '+%F %T'): Script finished\"
echo \"Time: \${SECONDS} seconds\"
" > ./scripts/process/process_radtags.sh

sbatch ./scripts/process/process_radtags.sh
