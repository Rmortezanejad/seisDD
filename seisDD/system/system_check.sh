#!/bin/bash

echo 
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo
echo " source parameter file ..." 
source parameter

echo 
echo " create new job_info file ..."
rm -rf job_info
mkdir job_info

echo 
echo " compile hello.f90"
mpif90 -DUSE_MPI -o test/hello.exe -g -O3 -xSSSE3 -no-ip -fno-fnalias -fno-alias -vec-report1 -assume byterecl -sox -cpp  -traceback -w -ftz test/hello.f90

echo 
echo " edit request nodes and tasks ..."
nproc=$NPROC
ntaskspernode=$(echo "$max_nproc_per_node $nproc" | awk '{ print $1/$2 }')
nodes=$(echo $(echo "$ntasks $nproc $max_nproc_per_node" | awk '{ print $1*$2/$3 }') | awk '{printf("%d\n",$0+=$0<0?0:0.999)}')
echo " Request $nodes nodes, $ntasks tasks, $ntaskspernode tasks per node, $nproc cpus per task "

echo
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo

echo "submit job ..."
echo
if [ $system == 'slurm' ]; then
    echo "slurm system ..."
    echo "sbatch -N $nodes -n $ntasks --cpus-per-task=$nproc -t $WallTime -e job_info/error -o job_info/output test/test_job.sh"
    sbatch -N $nodes -n $ntasks --cpus-per-task=$nproc -t $WallTime -e job_info/error -o job_info/output test/test_job.sh

elif [ $system == 'pbs' ]; then
    echo "pbs system ..."
    echo
    echo "qsub -l nodes=$nodes:ppn=$max_nproc_per_node -l --walltime=$WallTime -e job_info/error -o job_info/output  test/test_job.sh"
    qsub -l nodes=$nodes:ppn=$max_nproc_per_node -l --walltime=$WallTime -e job_info/error -o job_info/output  test/test_job.sh
fi
echo
