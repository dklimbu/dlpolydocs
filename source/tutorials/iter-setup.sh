#!/bin/bash
let i=1
let j=i-1
let ntraj=50

if [ -d iter${i} ]; then
  echo iter${i} exists, change iteration number at first!!
  exit 1
elif [ ! -d iter${j} ]; then
  echo iter${j} does not exist, change iteration number at first!!
  exit 1
else
  echo "running simulation for iter${i}"
  echo "copying necessary files from iter${j}"
fi
mkdir iter${i}
mkdir iter${i}/run
cp base_scripts/run_dlpoly.sh iter${i}/run/
cp base_scripts/run_avg.sh iter${i}/run/
cp base_scripts/run_IBI.sh iter${i}/
cd iter${i}/run
mkdir base_input
cp ../../FQCMD base_input/
cp ../../iterCONTROL base_input/CONTROL
cp ../../avgCONTROL CONTROL
cp ../../iter${j}/*.table base_input/ 
cp ../../iter${j}/new_FIELD base_input/FIELD
cp ../../iter${j}/new_FIELD ../old_FIELD
cp ../../iter${j}/New_Potential.dat ../Previous_Potential.dat

for k in $(seq -f "%03g" 1 ${ntraj})
do
   mkdir traj${k}
   cp base_input/* traj${k}/
   cp run_dlpoly.sh traj${k}/
   cp ../../ref/run/traj${k}/CONFIG traj${k}/ 
   cd traj${k}
      sbatch -J itr${i}-${k} run_dlpoly.sh
   cd ../
done
cd ../..
