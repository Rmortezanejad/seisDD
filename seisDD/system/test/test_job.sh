#!/bin/bash

ulimit -s unlimited

source parameter
export user=$(whoami)

# Submit directory
if [ $system == 'slurm' ]; then
    export SUBMIT_DIR=$SLURM_SUBMIT_DIR
    echo "$SLURM_JOB_NODELIST"  >  ./job_info/NodeList
    echo "$SLURM_JOBID"  >  ./job_info/JobID
elif [ $system == 'pbs' ]; then
    export SUBMIT_DIR=$PBS_O_WORKDIR
    echo "$PBS_NODEFILE"  >  ./job_info/NodeList
    echo "$PBS_JOBID"  >  ./job_info/JobID
fi

echo
echo "       This is to check your system: $system "
echo "**********************************************************"
echo

STARTTIME=$(date +%s)
echo "start time is :  $(date +"%T")"
echo

# Runs tasks in serial or parallel on specified hosts
if [ $system == 'slurm' ]; then
    srun -l -W 0 test/hello.sh 2>./job_info/error_run 
elif [ $system == 'pbs' ]; then
    pbsdh -l -W 0 test/hello.sh 2>./job_info/error_run
fi

ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")" 
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."

echo
echo "******************well done*******************************"
