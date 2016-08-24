#!/bin/bash

source parameter
currentdir=`pwd`

echo "Configure and compile specfem2D ..."
cd $specfem_path
make clean
if [ $NPROC_SPECFEM == 1 ]; then
    ./configure FC=$compiler 
else
    ./configure FC=$compiler --with-mpi
fi
make all

echo "Compile seisDD lib file"
cd $seisDD/seisDD/lib
make -f make_lib clean
make -f make_lib 

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Run this example ..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cd $currentdir

rm -rf submit_job

mkdir submit_job

cp -r $package_path/scripts/submit.sh submit_job/
cp -r DATA submit_job/
cp -r parameter submit_job/
if [ -d "SU_process" ]; then
    cp -r SU_process submit_job/
fi

echo 'cd submit_job/'
cd submit_job
echo './submit.sh'
./submit.sh

