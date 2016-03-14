#!/bin/bash

isource=$1
NPROC_SPECFEM=$2
data_tag=$3
data_list=$4
velocity_dir=$5
SAVE_FORWARD=$6
WORKING_DIR=$7
DISK_DIR=$8
DATA_DIR=$9

if [ $isource -eq 1 ] ; then
echo "SPECFEM2D Forward Modeling ..."
echo "NPROC_SPECFEM=$NPROC_SPECFEM"
echo "data_tag=$data_tag"
echo "data_list=$data_list"
echo "velocity_dir=$velocity_dir"
echo "SAVE_FORWARD=$SAVE_FORWARD"
echo "WORKING_DIR=$WORKING_DIR"
echo "DISK_DIR=$DISK_DIR"
echo "DATA_DIR=$DATA_DIR"
fi


ISRC_WORKING_DIR=$( seq --format="$WORKING_DIR/%06.f/" $(($isource-1)) $(($isource-1)) ) # working directory (on local nodes, where specfem runs)
ISRC_DATA_DIR=$( seq --format="$DISK_DIR/%06.f/" $(($isource-1)) $(($isource-1)) )/$data_tag

mkdir -p $ISRC_WORKING_DIR $ISRC_DATA_DIR

cd $ISRC_WORKING_DIR

##echo "####### copy executables & input files ######"
cp -r $SUBMIT_DIR/SU_process ./
cp -r $SUBMIT_DIR/parameter ./
cp -r $SUBMIT_DIR/bin ./
cp -r $SUBMIT_DIR/DATA ./
if [ "$(ls -A $velocity_dir)" ]; then
cp $velocity_dir/* DATA/
fi

mkdir -p  OUTPUT_FILES SEM

# Source location
export xs=$(awk -v "line=$isource" 'NR==line { print $1 }' DATA/sources.dat)
export zs=$(awk -v "line=$isource" 'NR==line { print $2 }' DATA/sources.dat)

### echo " edit SOURCE "
   FILE="./DATA/SOURCE"
   sed -e "s/^xs.*$/xs =    $xs/g" $FILE > temp;  mv temp $FILE
   sed -e "s/^zs.*$/zs =    $zs/g" $FILE > temp;  mv temp $FILE

##### edit 'Par_file' #####
   FILE="./DATA/Par_file"
   sed -e "s#^SIMULATION_TYPE.*#SIMULATION_TYPE = 1 #g"  $FILE > temp; mv temp $FILE
   sed -e "s#^SAVE_FORWARD.*#SAVE_FORWARD = .$SAVE_FORWARD. #g"  $FILE > temp; mv temp $FILE


   ##### forward simulation (data) #####
   ./bin/xmeshfem2D > OUTPUT_FILES/output_mesher.txt

   if [ $isource -eq 1 ] ; then
   echo "mpirun -np $NPROC_SPECFEM ./bin/xspecfem2D"
   fi
   mpirun -np $NPROC_SPECFEM ./bin/xspecfem2D > OUTPUT_FILES/output_forward.txt


## copy and preprocessing of data 
arr=$(echo $data_list | tr "," "\n")

for x in $arr
do
    if [ $x =  'x' ]; then
        sh SU_process/process_syn.sh \
            OUTPUT_FILES/Ux_file_single.su \
            $ISRC_DATA_DIR/Ux_file_single.su
    fi
    if [ $x =  'y' ]; then
        sh SU_process/process_syn.sh \
            OUTPUT_FILES/Uy_file_single.su \
            $ISRC_DATA_DIR/Uy_file_single.su
    fi
    if [ $x =  'z' ]; then
        sh SU_process/process_syn.sh \
            OUTPUT_FILES/Uz_file_single.su \
            $ISRC_DATA_DIR/Uz_file_single.su
    fi
    if [ $x =  'p' ]; then
        sh SU_process/process_syn.sh \
            OUTPUT_FILES/Up_file_single.su \
            $ISRC_DATA_DIR/Up_file_single.su
    fi
done

  if [ "$data_tag" == "DATA_obs" ]; 
  then
    mkdir -p $DATA_DIR 
    ISRC_DATA_DIR_SAVE=$( seq --format="$DATA_DIR/%06.f/" $(($isource-1)) $(($isource-1)) )
    rm -rf $ISRC_DATA_DIR_SAVE
    mkdir -p $ISRC_DATA_DIR_SAVE 
    cp -r $ISRC_DATA_DIR/* $ISRC_DATA_DIR_SAVE/
  fi

