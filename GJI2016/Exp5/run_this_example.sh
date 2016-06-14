#!/bin/bash

source parameter

echo "Run this example ..."

rm -rf submit_job

mkdir submit_job

cp -r $package_path/scripts/submit.sh submit_job/
cp -r DATA submit_job/
cp -r parameter submit_job/
if [ -d "SU_process" ]; then
    cp -r SU_process submit_job/
fi

echo 'cd submit_job/'
echo './submit.sh'
