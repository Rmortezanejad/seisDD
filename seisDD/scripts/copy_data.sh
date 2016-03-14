#!/bin/bash

isource=$1
data_tag=$2
data_list=$3
WORKING_DIR=$4
DISK_DIR=$5
DATA_DIR=$6

ISRC_WORKING_DIR=$( seq --format="$WORKING_DIR/%06.f/" $(($isource-1)) $(($isource-1)) ) 

ISRC_DATA_DIR=$( seq --format="$DISK_DIR/%06.f/" $(($isource-1)) $(($isource-1)) )/$data_tag


mkdir -p $ISRC_WORKING_DIR $ISRC_DATA_DIR

cd $ISRC_WORKING_DIR

if [ $isource -eq 1 ]; then
 echo "copy data from $DATA_DIR"
fi
# Source location
DATA_DIR=$( seq --format="$DATA_DIR/%06.f/" $(($isource-1)) $(($isource-1)) )

cp -r $SUBMIT_DIR/SU_process ./
cp -r $SUBMIT_DIR/parameter ./
cp -r $DATA_DIR/* $ISRC_DATA_DIR/ 

## copy and preprocessing of data 
arr=$(echo $data_list | tr "," "\n")

for x in $arr
do
    if [ $x =  'x' ]; then
        sh SU_process/process_obs.sh \
            $DATA_DIR/Ux_file_single.su \
            $ISRC_DATA_DIR/Ux_file_single.su
    fi
    if [ $x =  'y' ]; then
        sh SU_process/process_obs.sh \
            $DATA_DIR/Uy_file_single.su \
            $ISRC_DATA_DIR/Uy_file_single.su
    fi
    if [ $x =  'z' ]; then                    
        sh SU_process/process_obs.sh \
            $DATA_DIR/Uz_file_single.su \
            $ISRC_DATA_DIR/Uz_file_single.su
    fi  
    if [ $x =  'p' ]; then                                    
        sh SU_process/process_obs.sh \
            $DATA_DIR/Up_file_single.su \
            $ISRC_DATA_DIR/Up_file_single.su
    fi   
done
