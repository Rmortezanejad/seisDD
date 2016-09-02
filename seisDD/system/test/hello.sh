#!/bin/bash

# parameters
source parameter

# local id (from 0 to $ntasks-1)
if [ $system == 'slurm' ]; then
    iproc=$SLURM_PROCID
elif [ $system == 'pbs' ]; then
    iproc=$PBS_VNODENUM
fi

echo "hello.sh iproc=$iproc"

# run serial exe 
./test/hello.exe

# run mpi exe 
mpirun -np $NPROC test/hello_mpi.exe
