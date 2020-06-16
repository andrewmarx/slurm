#!/bin/bash

. ./config.txt

mkdir -p ./results/
mkdir -p ./results/02_param/
mkdir -p ./output/02_param/
mkdir -p ./scripts/02_param/
mkdir -p ./output/02_param/logs/
mkdir -p ./output/02_param/samples/
mkdir -p ./output/02_param/ustacks/
mkdir -p ./output/02_param/cstacks/
mkdir -p ./output/02_param/sstacks/
mkdir -p ./output/02_param/tsv2bam/
mkdir -p ./output/02_param/gstacks/
mkdir -p ./output/02_param/populations/
mkdir -p ./output/02_param/figures/

slurm_modules="stacks/2.53"

# Remove any files to avoid previous runs from causing unexpected results
rm -r ./output/02_param/samples/*

# Create an empty popmap file
> ./output/02_param/popmap.txt

for f in "${samples[@]}"; do
  # Make a symbolic link to the sample file
  ln -s "../../01_radtags/samples/${f}.fq.gz" ./output/02_param/samples/

  # Add the sample to the popmap file
  echo -e "${f}\t1" >> ./output/02_param/popmap.txt
done


#
# ustacks
#

num_samples=$(find ./output/02_param/samples/ -name "*.gz" | wc -l)
ustacks_jobs=$((${#M[@]} * ${#m[@]} * $num_samples))
ustacks_cores=10


# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=01_ustacks
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/02_param/logs/01_ustacks_%a.log
#SBATCH --error ./output/02_param/logs/01_ustacks_%a.log
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

for M in ${M[*]}; do
  for m in ${m[*]}; do
    f_counter=0
    for data_file in ./output/02_param/samples/*.gz; do
      counter=\$((counter + 1))
      f_counter=\$((f_counter + 1))
      if [ \$counter -eq \$SLURM_ARRAY_TASK_ID ]; then
        break 3
      fi
    done
  done
done

sample_name=\$(basename \$data_file)
sample_name=\${sample_name%%.*}
echo \$sample_name


outdir=\"./output/02_param/ustacks/\${M}_\${m}/\"
mkdir -p \$outdir

start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e \$outdir\${sample_name}.complete ]
then
  echo \"Sample already processed\"
else
  rm -r \$outdir\${sample_name}.*
  rm -r ./output/02_param/cstacks/\${M}_\${m}_*/
  rm -r ./output/02_param/sstacks/\${M}_\${m}_*/
  rm -r ./output/02_param/tsv2bam/\${M}_\${m}_*/
  rm -r ./output/02_param/gstacks/\${M}_\${m}_*/
  rm -r ./outputparam//populations/\${M}_\${m}_*/
  rm -r ./results/\${M}_\${m}_*/
  ustacks -f \$data_file -o \$outdir -i \$f_counter -M \${M} -m \${m} -p ${ustacks_cores}
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch \$outdir\${sample_name}.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi
" > ./scripts/02_param/01_ustacks.sh



#
# cstacks
#

cstacks_jobs=$((${#M[@]} * ${#m[@]} * ${#n[@]}))
cstacks_cores=5

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=02_cstacks
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/02_param/logs/02_cstacks_%a.log
#SBATCH --error ./output/02_param/logs/02_cstacks_%a.log
#SBATCH --array=1-${cstacks_jobs}%$((${cores} / ${cstacks_cores}))
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${cstacks_cores}
#SBATCH --mem-per-cpu=2gb
#SBATCH --time=20:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}


counter=0

for M in ${M[*]}; do
  for m in ${m[*]}; do
    for n in ${n[*]}; do
      counter=\$((counter + 1))
      if [ \$counter -eq \$SLURM_ARRAY_TASK_ID ]; then
        break 3
      fi
    done
  done
done

n=\$((n + M))

outdir=\"./output/02_param/cstacks/\${M}_\${m}_\${n}\"
mkdir \$outdir

for f in ./output/02_param/ustacks/\${M}_\${m}/*; do
  file_name=\$(basename \${f})
  ln -s ../../ustacks/\${M}_\${m}/\${file_name} \$outdir/
done

start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e \$outdir/cstacks.complete ]
then
  echo \"Cstacks already completed\"
else
  cstacks -n \${n} -p ${cstacks_cores} --popmap ./output/02_param/popmap.txt -P \$outdir/
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch \$outdir/cstacks.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi

" > ./scripts/02_param/02_cstacks.sh


#
# sstacks
#

sstacks_jobs=$((${#M[@]} * ${#m[@]} * ${#n[@]}))
sstacks_cores=5

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=03_sstacks
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/02_param/logs/03_sstacks_%a.log
#SBATCH --error ./output/02_param/logs/03_sstacks_%a.log
#SBATCH --array=1-${sstacks_jobs}%$((${cores} / ${sstacks_cores}))
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${sstacks_cores}
#SBATCH --mem-per-cpu=2gb
#SBATCH --time=10:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}

counter=0

for M in ${M[*]}; do
  for m in ${m[*]}; do
    for n in ${n[*]}; do
        counter=\$((counter + 1))
        if [ \$counter -eq \$SLURM_ARRAY_TASK_ID ]; then
          break 3
        fi
    done
  done
done

n=\$((n + M))

outdir=\"./output/02_param/sstacks/\${M}_\${m}_\${n}\"
mkdir \$outdir

for f in ./output/02_param/cstacks/\${M}_\${m}_\${n}/*; do
  file_name=\$(basename \${f})
  ln -s ../../cstacks/\${M}_\${m}_\${n}/\${file_name} \$outdir/
done


start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e \$outdir/sstacks.complete ]
then
  echo \"sstacks already completed\"
else
  sstacks -p ${sstacks_cores} --popmap ./output/02_param/popmap.txt -P \$outdir/
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch \$outdir/sstacks.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi

" > ./scripts/02_param/03_sstacks.sh



tsv2bam_jobs=$((${#M[@]} * ${#m[@]} * ${#n[@]}))
tsv2bam_cores=2

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=04_tsv2bam
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/02_param/logs/04_tsv2bam_%a.log
#SBATCH --error ./output/02_param/logs/04_tsv2bam_%a.log
#SBATCH --array=1-${tsv2bam_jobs}%$((${cores} / ${tsv2bam_cores}))
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${tsv2bam_cores}
#SBATCH --mem-per-cpu=2gb
#SBATCH --time=10:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}


counter=0

for M in ${M[*]}; do
  for m in ${m[*]}; do
    for n in ${n[*]}; do
        counter=\$((counter + 1))
        if [ \$counter -eq \$SLURM_ARRAY_TASK_ID ]; then
          break 3
        fi
    done
  done
done

n=\$((n + M))

outdir=\"./output/02_param/tsv2bam/\${M}_\${m}_\${n}\"
mkdir \$outdir

for f in ./output/02_param/sstacks/\${M}_\${m}_\${n}/*; do
  file_name=\$(basename \${f})
  ln -s ../../sstacks/\${M}_\${m}_\${n}/\${file_name} \$outdir/
done


start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e \$outdir/tsv2bam.complete ]
then
  echo \"tsv2bam already completed\"
else
  tsv2bam -M ./output/02_param/popmap.txt -P \$outdir/
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch \$outdir/tsv2bam.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi

" > ./scripts/02_param/04_tsv2bam.sh



gstacks_jobs=$((${#M[@]} * ${#m[@]} * ${#n[@]}))
gstacks_cores=2

# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=05_gstacks
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/02_param/logs/05_gstacks_%a.log
#SBATCH --error ./output/02_param/logs/05_gstacks_%a.log
#SBATCH --array=1-${gstacks_jobs}%$((${cores} / ${gstacks_cores}))
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${gstacks_cores}
#SBATCH --mem-per-cpu=2gb
#SBATCH --time=10:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load ${slurm_modules}


counter=0

for M in ${M[*]}; do
  for m in ${m[*]}; do
    for n in ${n[*]}; do
        counter=\$((counter + 1))
        if [ \$counter -eq \$SLURM_ARRAY_TASK_ID ]; then
          break 3
        fi
    done
  done
done

n=\$((n + M))

outdir=\"./output/02_param/gstacks/\${M}_\${m}_\${n}\"
mkdir \$outdir

for f in ./output/02_param/tsv2bam/\${M}_\${m}_\${n}/*; do
  file_name=\$(basename \${f})
  ln -s ../../tsv2bam/\${M}_\${m}_\${n}/\${file_name} \$outdir/
done


start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e \$outdir/gstacks.complete ]
then
  echo \"gstacks already completed\"
else
  gstacks -M ./output/02_param/popmap.txt -P \$outdir/
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch \$outdir/gstacks.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi
" > ./scripts/02_param/05_gstacks.sh



pop_jobs=$((${#M[@]} * ${#m[@]} * ${#n[@]} * ${#r[@]}))
pop_cores=2
# Create the slurm script that runs the simulations
echo "#!/bin/bash

#SBATCH --job-name=06_populations
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/02_param/logs/06_pop_%a.log
#SBATCH --error ./output/02_param/logs/06_pop_%a.log
#SBATCH --array=1-${pop_jobs}%$((${cores} / ${pop_cores}))
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${pop_cores}
#SBATCH --mem-per-cpu=1gb
#SBATCH --time=1:00:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

# Using older version of stacks for this because of a  bug when reading the catalog file
module load ${slurm_modules}


counter=0

for M in ${M[*]}; do
  for m in ${m[*]}; do
    for n in ${n[*]}; do
      for r in ${r[*]}; do
        counter=\$((counter + 1))
        if [ \$counter -eq \$SLURM_ARRAY_TASK_ID ]; then
          break 4
        fi
      done
    done
  done
done

n=\$((n + M))

outdir=\"./output/02_param/populations/\${M}_\${m}_\${n}_\${r}/\"
mkdir \$outdir

for f in ./output/02_param/gstacks/\${M}_\${m}_\${n}/*; do
  file_name=\$(basename \${f})
  ln -s ../../gstacks/\${M}_\${m}_\${n}/\${file_name} \$outdir/
done

start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

if [ -e \$outdir/pop.complete ]
then
  echo \"populations already completed\"
else
  populations -P \$outdir/ -M ./output/02_param/popmap.txt -r \${r}
  retval=\$?
fi

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"

if [ \${retval} -eq 0 ]
then
  touch \$outdir/pop.complete
else
  scancel \$SLURM_JOB_ID
  sleep 10
  exit -1
fi

cp \$outdir/populations.sumstats_summary.tsv ./results/02_param/\${M}_\${m}_\${n}_\${r}.tsv

" > ./scripts/02_param/06_populations.sh



echo "#!/bin/bash

#SBATCH --job-name=07_r_plot
#SBATCH --mail-type=ALL
#SBATCH --mail-user=${email}
#SBATCH --output ./output/02_param/logs/07_r_plot_%a.log
#SBATCH --error ./output/02_param/logs/07_r_plot_%a.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=3gb
#SBATCH --time=00:10:00
#SBATCH --account=${account}
#SBATCH --qos=${account}

module load R


start_time=\$(date '+%F %T')
echo
echo
echo \"\$start_time: Started\"
echo

SECONDS=0
retval=0

Rscript --vanilla ./param-plot.R

total_time=\${SECONDS}

end_time=\$(date '+%F %T')

echo
echo \"\$end_time: Finished\"
echo \"Time: \${total_time} seconds\"
" > ./scripts/02_param/07_plot.sh


jid1=$(sbatch ./scripts/02_param/01_ustacks.sh | cut -f 4 -d' ')
echo "ustacks job #: $jid1"

jid2=$(sbatch --dependency=afterok:$jid1 --kill-on-invalid-dep=yes ./scripts/02_param/02_cstacks.sh | cut -f 4 -d' ')
echo "cstacks job #: $jid2"

jid3=$(sbatch  --dependency=afterok:$jid2 --kill-on-invalid-dep=yes ./scripts/02_param/03_sstacks.sh | cut -f 4 -d' ')
echo "sstacks job #: $jid3"

jid4=$(sbatch  --dependency=afterok:$jid3 --kill-on-invalid-dep=yes ./scripts/02_param/04_tsv2bam.sh | cut -f 4 -d' ')
echo "tsv2bam job #: $jid4"

jid5=$(sbatch  --dependency=afterok:$jid4 --kill-on-invalid-dep=yes ./scripts/02_param/05_gstacks.sh | cut -f 4 -d' ')
echo "gstacks job #: $jid5"

jid6=$(sbatch  --dependency=afterok:$jid5 --kill-on-invalid-dep=yes ./scripts/02_param/06_populations.sh | cut -f 4 -d' ')
echo "populations job #: $jid6"

jid7=$(sbatch  --dependency=afterok:$jid6 --kill-on-invalid-dep=yes ./scripts/02_param/07_plot.sh | cut -f 4 -d' ')
echo "r plot job #: $jid7"
