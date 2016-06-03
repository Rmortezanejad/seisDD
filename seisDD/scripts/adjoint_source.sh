#!/bin/bash

isource=$1
NPROC_SPECFEM=$2
compute_adjoint=$3
data_list=$4
measurement_list=$5
misfit_type_list=$6
WORKING_DIR=$7
DISK_DIR=$8
Wscale=$9
wavelet_path=${10}

if [ $isource -eq 1 ]; then
    echo "adjoint source ..."
    echo "NPROC_SPECFEM=$NPROC_SPECFEM"
    echo "compute_adjoint=$compute_adjoint"
    echo "data_list=$data_list"
    echo "measurement_list=$measurement_list"
    echo "misfit_type_list=$misfit_type_list"
    echo "Wscale=$Wscale"
    echo "wavelet_path=$wavelet_path"
    echo "WORKING_DIR=$WORKING_DIR"
    echo "DISK_DIR=$DISK_DIR"
fi

ISRC_WORKING_DIR=$( seq --format="$WORKING_DIR/%06.f/" $(($isource-1)) $(($isource-1)) )

mkdir -p $ISRC_WORKING_DIR
cd $ISRC_WORKING_DIR

if [ $Wscale -gt 0 ]; then
    cp -r $wavelet_path ./
fi

INPUT_DIR=$( seq --format="$DISK_DIR/%06.f/" $(($isource-1)) $(($isource-1)) )
mkdir -p $INPUT_DIR/SEM

# adjoint source
mpirun -np $NPROC_SPECFEM ./bin/misfit_adjoint.exe $compute_adjoint $data_list $measurement_list $misfit_type_list $INPUT_DIR

## copy and postprocessing of adjoint source
arr=$(echo $data_list | tr "," "\n")

for x in $arr
do
    if [ $x =  'x' ]; then
        sh SU_process/process_adj.sh \
            $INPUT_DIR/SEM/Ux_file_single.su.adj \
            $ISRC_WORKING_DIR/SEM/Ux_file_single.su.adj
    fi
    if [ $x =  'y' ]; then
        sh SU_process/process_adj.sh \
            $INPUT_DIR/SEM/Uy_file_single.su.adj \
            $ISRC_WORKING_DIR/SEM/Uy_file_single.su.adj
    fi
    if [ $x =  'z' ]; then
        sh SU_process/process_adj.sh \
            $INPUT_DIR/SEM/Uz_file_single.su.adj \
            $ISRC_WORKING_DIR/SEM/Uz_file_single.su.adj
    fi
    if [ $x =  'p' ]; then
        sh SU_process/process_adj.sh \
            $INPUT_DIR/SEM/Up_file_single.su.adj \
            $ISRC_WORKING_DIR/SEM/Up_file_single.su.adj
    fi
done
