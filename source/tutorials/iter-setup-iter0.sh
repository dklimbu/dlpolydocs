#!/bin/bash
let i=0
#let j=i-1

if [ -d iter${i} ]; then
  echo iter${i} exists, change iteration number at first!!
  exit 1
else
  echo "running simulation for iter${i}"
  echo "copying necessary files ..."
fi
mkdir iter${i}
mkdir iter${i}/run
cp base_scripts/run_dlpoly_wulver.sh iter${i}/run/
cp base_scripts/run_avg.sh iter${i}/run/
cp base_scripts/run_IBI.sh iter${i}/
cd iter${i}/run
mkdir base_input
cp ../../FQCMD base_input/
cp ../../iterCONTROL base_input/CONTROL
cp ../../avgCONTROL CONTROL
cp ../../ref/run/base_input/*.table base_input/ 
cp ../../new_FIELD base_input/FIELD
cp ../../new_FIELD ../old_FIELD
cp ../../New_Potential.dat ../Previous_Potential.dat

job_ids=()
for k in $(seq -f "%03g" 1 20)
do
	mkdir traj${k}
	cp base_input/* traj${k}/
	cp run_dlpoly_wulver.sh traj${k}/
	cp ../../ref/run/traj${k}/CONFIG traj${k}/ 
	cd traj${k}
	job_id=$(sbatch -J itr${i}-${k} --parsable run_dlpoly_wulver.sh)
	job_ids+=($job_id)
	echo $job_id

	cd ../
done

# Set dependency for post-analysis job to run after all 20 jobs are complete
dependency_list=$(IFS=: ; echo "${job_ids[*]}")
# Submit the analysis script with a dependency on the completion of the setup job
ave_job_id=$(sbatch --parsable --dependency=afterok:${dependency_list} run_avg.sh)
echo "Submitted avgRDF for iteration $iteration with Job ID $ave_job_id after $dependency_list"
cd ..

ibi_job_id=$(sbatch --parsable --dependency=afterok:${ave_job_id} run_IBI.sh)
echo "Submitted IBI run for iteration $iteration with Job ID $ibi_job_id"

cd ..

#cd ../../
#echo "${job_ids[@]}"
# save the job IDs for dependency
#echo "${job_ids[@]}" >"iter${i}/run/job_ids.txt"
