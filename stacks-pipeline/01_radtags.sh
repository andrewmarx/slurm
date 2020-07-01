#!/bin/bash

. ./config.txt

rm -r ./output
rm -r ./results

mkdir -p ./output/
mkdir -p ./output/01_radtags/samples/
mkdir -p ./output/01_radtags/logs/
mkdir -p ./scripts/01_radtags/

process_jobs=$(find ./data/* -maxdepth 0 -type d | wc -l)
slurm_modules="gcc/8.2.0 stacks/2.53"

echo "#!/bin/bash

#SBATCH --job-name=radtags
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/01_radtags/logs/radtag_%a.log
#SBATCH --error ./output/01_radtags/logs/radtag_%a.log
#SBATCH --array=1-${process_jobs}%${cores}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=25gb
#SBATCH --time=75:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}

echo \"\$(date '+%F %T'): Starting script\"
echo

seq_libraries=(./data/*/)

process_radtags -p ./data/\${SLURM_ARRAY_TASK_ID} -o ./output/01_radtags/samples/ -b ./data/\${SLURM_ARRAY_TASK_ID}/key.txt ${process_radtag_param}

echo
echo \"\$(date '+%F %T'): Script finished\"
echo \"Time: \${SECONDS} seconds\"
" > ./scripts/01_radtags/process_radtags.sh

sbatch ./scripts/01_radtags/process_radtags.sh
