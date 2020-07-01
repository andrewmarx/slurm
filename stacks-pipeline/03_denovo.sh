#!/bin/bash

. ./config.txt

mkdir -p ./scripts/denovo/
mkdir -p ./output/denovo/
mkdir -p ./output/denovo/logs/
mkdir -p ./results/denovo/

slurm_modules="gcc/8.2.0 stacks/2.53"

num_samples=$(find ./output/samples/ -name "*.gz" | wc -l)
ustacks_jobs=$(($num_samples))
ustacks_cores=10

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=01_ustacks
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/denovo/logs/01_ustacks_%a.log
#SBATCH --error ./output/denovo/logs/01_ustacks_%a.log
#SBATCH --array=1-${ustacks_jobs}%$((${cores} / ${ustacks_cores}))
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${ustacks_cores}
#SBATCH --mem-per-cpu=2gb
#SBATCH --time=20:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}

counter=0


for data_file in ./output/samples/*.gz; do
  counter=\$((counter + 1))
  if [ \$counter -eq \$SLURM_ARRAY_TASK_ID ]; then
    break
  fi
done


sample_name=\$(basename \$data_file)
sample_name=\${sample_name%%.*}
echo \$sample_name


start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e ./output/denovo/\${sample_name}.ustacks.complete ]
then
  echo \"Sample already processed\"
else
  rm -r ./output/denovo/\${sample_name}.*

  cd ./output/
  rm \$(ls -I{*.alleles.tsv.gz,*.snps.tsv.gz,*.tags.tsv.gz,*.ustacks.complete})
  cd ..

  ustacks -f \$data_file -o ./output/denovo/ -i \$counter -p ${ustacks_cores} ${ustacks_param}
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  echo \"Creating completion marker\"
  touch ./output/denovo/\${sample_name}.ustacks.complete
else
  echo \"Bad return value from ustacks. Cancelling job.\"
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi
" > ./scripts/denovo/01_ustacks.sh



cstacks_cores=10


# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=02_cstacks
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/denovo/logs/02_cstacks.log
#SBATCH --error ./output/denovo/logs/02_cstacks.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${cstacks_cores}
#SBATCH --mem=20gb
#SBATCH --time=30:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}


start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e ./output/denovo/cstacks.complete ]
then
  echo \"cstacks already completed\"
else
  rm -r ./output/denovo/catalog.*

  cstacks -p ${cstacks_cores} --popmap ./data/catalog.tsv -P ./output/denovo/ ${cstacks_param}
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch ./output/denovo/cstacks.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi

" > ./scripts/denovo/02_cstacks.sh



sstacks_cores=5

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=03_sstacks
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/denovo/logs/03_sstacks.log
#SBATCH --error ./output/denovo/logs/03_sstacks.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${sstacks_cores}
#SBATCH --mem=15gb
#SBATCH --time=10:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}

start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e ./output/denovo/sstacks.complete ]
then
  echo \"sstacks already completed\"
else
  rm -r ./output/denovo/*.matches.tsv.gz

  sstacks -p ${sstacks_cores} --popmap ./data/popmap.tsv -P ./output/denovo/ ${sstacks_param}
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch ./output/denovo/sstacks.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi

" > ./scripts/denovo/03_sstacks.sh


tsv2bam_cores=2

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=04_tsv2bam
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/denovo/logs/04_tsv2bam.log
#SBATCH --error ./output/denovo/logs/04_tsv2bam.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${tsv2bam_cores}
#SBATCH --mem=5gb
#SBATCH --time=10:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}


start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e ./output/denovo/tsv2bam.complete ]
then
  echo \"tsv2bam already completed\"
else
  rm -r ./output/denovo/*.batches.bam

  tsv2bam -M ./data/popmap.tsv -P ./output/denovo/ -t ${tsv2bam_cores}
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch ./output/denovo/tsv2bam.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi

" > ./scripts/denovo/04_tsv2bam.sh



gstacks_cores=2

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=05_gstacks
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/denovo/logs/05_gstacks.log
#SBATCH --error ./output/denovo/logs/05_gstacks.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${gstacks_cores}
#SBATCH --mem=20gb
#SBATCH --time=10:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}


start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e ./output/denovo/gstacks.complete ]
then
  echo \"gstacks already completed\"
else
  rm -r ./output/denovo/gstacks.*

  gstacks -M ./data/popmap.tsv -P ./output/denovo/ -t ${gstacks_cores} ${gstacks_param}
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch ./output/denovo/gstacks.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi

" > ./scripts/denovo/05_gstacks.sh


pop_cores=5
# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=06_populations
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/denovo/logs/06_pop.log
#SBATCH --error ./output/denovo/logs/06_pop.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${pop_cores}
#SBATCH --mem=20gb
#SBATCH --time=2:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}

rm -r ./output/denovo/populations.*
rm -r ./results/denovo/populations.*
rm -r ./tmp

start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0

populations -P ./output/denovo/ -O ./results/denovo/ -M ./data/popmap.tsv -t ${pop_cores} ${populations_param} --vcf

mkdir -p ./tmp
awk -vOFS='\t' '!/^#/ {\$3=\$1 "_" (\$2-1)} 1' ./results/denovo/populations.snps.vcf > ./tmp/temp_1.vcf && \\
awk -vOFS='\t' '!/^#/ {\$2=\$1} 1' ./tmp/temp_1.vcf > ./tmp/temp_2.vcf && \\
awk -vOFS='\t' '!/^#/ {\$1=\"un\"} 1' ./tmp/temp_2.vcf > ./results/denovo/populations.snps.fixed.vcf && \\
rm -r ./tmp

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"


" > ./scripts/denovo/06_populations.sh







jid1=$(sbatch ./scripts/denovo/01_ustacks.sh | cut -f 4 -d' ')
echo "ustacks job #: $jid1"

jid2=$(sbatch --dependency=afterok:$jid1 --kill-on-invalid-dep=yes ./scripts/denovo/02_cstacks.sh | cut -f 4 -d' ')
echo "cstacks job #: $jid2"

jid3=$(sbatch  --dependency=afterok:$jid2 --kill-on-invalid-dep=yes ./scripts/denovo/03_sstacks.sh | cut -f 4 -d' ')
echo "sstacks job #: $jid3"

jid4=$(sbatch  --dependency=afterok:$jid3 --kill-on-invalid-dep=yes ./scripts/denovo/04_tsv2bam.sh | cut -f 4 -d' ')
echo "tsv2bam job #: $jid4"

jid5=$(sbatch  --dependency=afterok:$jid4 --kill-on-invalid-dep=yes ./scripts/denovo/05_gstacks.sh | cut -f 4 -d' ')
echo "gstacks job #: $jid5"

jid6=$(sbatch  --dependency=afterok:$jid5 --kill-on-invalid-dep=yes ./scripts/denovo/06_populations.sh | cut -f 4 -d' ')
echo "populations job #: $jid6"
