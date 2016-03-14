#!/bin/bash

# pass parameter 
source parameter

# directory
currentdir=`pwd`
EXE_DIR="$currentdir/bin"        # exacutable files directory

############################# parameter files ############################################################### 
   FILE="$EXE_DIR/seismo_parameters.f90"
   sed -e "s#^Job_title=.*#Job_title=$Job_title #g"  $FILE > temp;  mv temp $FILE

### solver related parameters
if [ "$solver" = "specfem2D" ]; then 
   sed -e "s#^INTEGER, PARAMETER :: NGLLY.*#INTEGER, PARAMETER :: NGLLY=1 #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^CHARACTER (LEN=MAX_STRING_LEN) :: LOCAL_PATH.*#CHARACTER (LEN=MAX_STRING_LEN) :: LOCAL_PATH='OUTPUT_FILES'  #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^CHARACTER (LEN=MAX_STRING_LEN) :: IBOOL_NAME.*#CHARACTER (LEN=MAX_STRING_LEN) :: IBOOL_NAME='NSPEC_ibool.bin'  #g"  $FILE > temp;  mv temp $FILE
fi

if [ "$solver" = "specfem3D" ]; then
   sed -e "s#^INTEGER, PARAMETER :: NGLLY.*#INTEGER, PARAMETER :: NGLLY=5 #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^CHARACTER (LEN=MAX_STRING_LEN) :: LOCAL_PATH.*#CHARACTER (LEN=MAX_STRING_LEN) :: LOCAL_PATH='OUTPUT_FILES/DATABASES_MPI'  #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^CHARACTER (LEN=MAX_STRING_LEN) :: IBOOL_NAME.*#CHARACTER (LEN=MAX_STRING_LEN) :: IBOOL_NAME='external_mesh.bin'  #g"  $FILE > temp;  mv temp $FILE
fi

### FORWARD MODELNG INFO 
   sed -e "s#^INTEGER, PARAMETER :: NSTEP=.*#INTEGER, PARAMETER :: NSTEP=$NSTEP #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: deltat=.*#real(kind=CUSTOM_REAL), PARAMETER :: deltat=$deltat #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: t0=.*#real(kind=CUSTOM_REAL), PARAMETER :: t0=$t0 #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: f0=.*#real(kind=CUSTOM_REAL), PARAMETER :: f0=$f0 #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: NREC=.*#INTEGER, PARAMETER :: NREC=$NREC #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: NSRC=.*#INTEGER, PARAMETER :: NSRC=$NSRC #g"  $FILE > temp;  mv temp $FILE

### ADJOINT INFO
   ## PRE-PROCESSING
   # wavelet
   sed -e "s#^INTEGER, PARAMETER :: Wscale=.*#INTEGER, PARAMETER :: Wscale=$Wscale #g"  $FILE > temp;  mv temp $FILE
   # window
   sed -e "s#^INTEGER, PARAMETER :: is_window=.*#INTEGER, PARAMETER :: is_window=$is_window #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: window_type=.*#INTEGER, PARAMETER :: window_type=$window_type#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: Vmax=.*#real(kind=CUSTOM_REAL), PARAMETER :: Vmax=${Vmax} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: Vmin=.*#real(kind=CUSTOM_REAL), PARAMETER :: Vmin=${Vmin} #g"  $FILE > temp;  mv temp $FILE
   # damping
   sed -e "s#^INTEGER, PARAMETER :: is_laplace=.*#INTEGER, PARAMETER :: is_laplace=$is_laplace #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: X_decay=.*#real(kind=CUSTOM_REAL), PARAMETER :: X_decay=${X_decay} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: T_decay=.*#real(kind=CUSTOM_REAL), PARAMETER :: T_decay=${T_decay} #g"  $FILE > temp;  mv temp $FILE
   # mute
   sed -e "s#^INTEGER, PARAMETER :: mute_near=.*#INTEGER, PARAMETER :: mute_near=$mute_near #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: offset_near=.*#real(kind=CUSTOM_REAL), PARAMETER :: offset_near=${offset_near} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: mute_far=.*#INTEGER, PARAMETER :: mute_far=$mute_far #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: offset_far=.*#real(kind=CUSTOM_REAL), PARAMETER :: offset_far=${offset_far} #g"  $FILE > temp;  mv temp $FILE


   # MISFIT
   sed -e "s#^LOGICAL :: sensitivity=.*#LOGICAL :: sensitivity=.$sensitivity.#g"  $FILE > temp;  mv temp $FILE 
   sed -e "s#^CHARACTER (LEN=20) :: solver=.*#CHARACTER (LEN=20) :: solver='$solver'#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: cc_threshold=.*#real(kind=CUSTOM_REAL), PARAMETER :: cc_threshold=${cc_threshold} #g"  $FILE > temp;  mv temp $FILE


   # INVERSION
   sed -e "s#^CHARACTER (LEN=2) :: opt_scheme=.*#CHARACTER (LEN=2) :: opt_scheme='$opt_scheme'#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: CGSTEPMAX=.*#INTEGER, PARAMETER :: CGSTEPMAX=$CGSTEPMAX #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^CHARACTER (LEN=2) :: CG_scheme=.*#CHARACTER (LEN=2) :: CG_scheme='$CG_scheme'#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: BFGS_STEPMAX=.*#INTEGER, PARAMETER :: BFGS_STEPMAX=$BFGS_STEPMAX #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: initial_step_length=.*#real(kind=CUSTOM_REAL), PARAMETER :: initial_step_length=$initial_step_length #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^real(kind=CUSTOM_REAL), PARAMETER :: min_step_length=.*#real(kind=CUSTOM_REAL), PARAMETER :: min_step_length=$min_step_length #g" $FILE > temp;  mv temp $FILE                                                                                            
   sed -e "s#^INTEGER, PARAMETER :: max_step=.*#INTEGER, PARAMETER :: max_step=$max_step#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: backtracking=.*#LOGICAL :: backtracking=.$backtracking.#g"  $FILE > temp;  mv temp $FILE

   # POST-PROCESSING
   sed -e "s#^LOGICAL :: smooth=.*#LOGICAL :: smooth=.$smooth.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: precond=.*#LOGICAL :: precond=.$precond.#g"  $FILE > temp;  mv temp $FILE

### DISPLAY
   sed -e "s#^LOGICAL :: DISPLAY_DETAILS=.*#LOGICAL :: DISPLAY_DETAILS=.$DISPLAY_DETAILS.#g"  $FILE > temp;  mv temp $FILE

 
