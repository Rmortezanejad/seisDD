module seismo_parameters

  use constants, only: IIN, IOUT, MAX_STRING_LEN,MAX_FILENAME_LEN,MAX_KERNEL_NUM, &
                      MAX_LINES,MAX_MISFIT_TYPE, SIZE_REAL, SIZE_DOUBLE, CUSTOM_REAL,CUSTOM_COMPLEX,&
                      LARGE_VAL, SMALL_VAL,PI
 
  implicit none
 
!----------------------------------------------------------------------
! constants
! number of Gauss-Lobatto-Legendre (GLL) points (i.e., polynomial degree + 1)
integer, parameter :: NGLLX = 5
! number of Gauss-Lobatto-Jacobi (GLJ) points in the axial elements (i.e.,
! polynomial degree + 1)
! the code does NOT work if NGLLZ /= NGLLX because it then cannot handle a
! non-structured mesh
! due to non matching polynomial degrees along common edges
integer, parameter :: NGLLZ = 5
INTEGER, PARAMETER :: NGLLY=5

!! solver related 
CHARACTER (LEN=MAX_STRING_LEN) :: LOCAL_PATH='OUTPUT_FILES'
CHARACTER (LEN=MAX_STRING_LEN) :: IBOOL_NAME='ibool.bin'


!! FORWARD MODELNG INFO
INTEGER, PARAMETER :: NSTEP=4800 
real(kind=CUSTOM_REAL), PARAMETER :: deltat=0.06 
real(kind=CUSTOM_REAL), PARAMETER :: t0=0.0 
real(kind=CUSTOM_REAL), PARAMETER :: f0=0.084 
INTEGER, PARAMETER :: NREC=132 
INTEGER, PARAMETER :: NSRC=1 
INTEGER :: nrec_proc=0  ! trace from a single file
!! ADJOINT INFO
LOGICAL :: compute_adjoint

!! PRE-PROCESSING
! wavelet
INTEGER, PARAMETER :: Wscale=0 
!window
INTEGER, PARAMETER :: is_window=1 
INTEGER, PARAMETER :: window_type=3
real(kind=CUSTOM_REAL), PARAMETER :: Vmax=3900 
real(kind=CUSTOM_REAL), PARAMETER :: Vmin=1500
integer,dimension(:),allocatable  :: win_start, win_end
real(kind=CUSTOM_REAL) :: window_len=1.0/f0
real(kind=CUSTOM_REAL) :: taper_len=0.01

! damping
INTEGER, PARAMETER :: is_laplace=0
real(kind=CUSTOM_REAL), PARAMETER :: X_decay=1.0
real(kind=CUSTOM_REAL), PARAMETER :: T_decay=1.0
real(kind=CUSTOM_REAL) :: lambda_x=1.0/X_decay 
real(kind=CUSTOM_REAL) :: lambda_t=1.0/T_decay
! mute
INTEGER, PARAMETER :: mute_near=0 
real(kind=CUSTOM_REAL), PARAMETER :: offset_near=500 
INTEGER, PARAMETER :: mute_far=0 
real(kind=CUSTOM_REAL), PARAMETER :: offset_far=1000
real(kind=CUSTOM_REAL) :: mute_offset=offset_far
integer :: stage

! event scale
! averaged frequency/wavenumber/wavelength
real(kind=CUSTOM_REAL), PARAMETER :: lambda_min=Vmin/f0
real(kind=CUSTOM_REAL), PARAMETER :: lambda=Vmax/f0
real(kind=CUSTOM_REAL), PARAMETER :: wavenumber=2.0*pi/lambda
real(kind=CUSTOM_REAL), PARAMETER :: omega=2*pi*f0

! Adjoint/MISFIT
LOGICAL :: sensitivity=.false.

CHARACTER (LEN=20) :: solver='specfem2D'
character(len=MAX_STRING_LEN) :: measurement_list
character(len=MAX_STRING_LEN) :: misfit_type_list
real(kind=CUSTOM_REAL), PARAMETER :: cc_threshold=0.9 
real(kind=CUSTOM_REAL) :: ratio_data_syn=0.01

! ! INVERSION
! optimization
CHARACTER (LEN=2) :: opt_scheme='QN'
INTEGER, PARAMETER :: CGSTEPMAX=10 
CHARACTER (LEN=2) :: CG_scheme='PR'
INTEGER, PARAMETER :: BFGS_STEPMAX=4 
real(kind=CUSTOM_REAL), PARAMETER :: initial_step_length=0.04 
INTEGER, PARAMETER :: max_step=5
real(kind=CUSTOM_REAL), PARAMETER :: min_step_length=0.01 
LOGICAL :: backtracking=.false.
INTEGER, PARAMETER :: iter_start=1
INTEGER, PARAMETER :: iter_end=20

 ! POST-PROCESSING
LOGICAL :: smooth=.true.
!!!!!!!!!!!!!!!!! not change !!!!!!!!!!!!!!!!!!!!!!    

! shared variables
  real(kind=CUSTOM_REAL) :: threshold=1e-15
  integer :: myrank,nproc,iproc

!! data
  integer :: ndata
  integer,parameter :: MAX_DATA_NUM = 4
  integer, dimension(:), allocatable :: which_proc_receiver
  real(kind=CUSTOM_REAL), dimension(:,:),allocatable :: seism_obs
  real(kind=CUSTOM_REAL), dimension(:,:),allocatable :: seism_syn
  real(kind=CUSTOM_REAL), dimension(:,:),allocatable :: seism_adj
  real(kind=CUSTOM_REAL), dimension(:,:),allocatable :: seism_adj_DD
  real(kind=CUSTOM_REAL), dimension(:),allocatable :: st_xval,st_yval,st_zval
  real(kind=CUSTOM_REAL) :: x_source,y_source,z_source
  integer(kind=4) :: r4head(60)
  integer(kind=2) :: header2(2)

! source-timefunction
LOGICAL :: conv_stf=.false.
CHARACTER (LEN=MAX_FILENAME_LEN) :: stf_file='source.txt'
real(kind=CUSTOM_REAL) :: tshift_stf, integral_stf 
!=1.2*(10.0*deltat) !0.0 ! 16.8 ! tshift=1.2/f0 + 1.2*(10*deltat)
real(kind=CUSTOM_REAL), dimension(:),allocatable :: stf
integer :: stf_len

  ! misfit
  integer :: num_AD, num_DD
  integer, dimension(:,:), allocatable :: is_pair
  real(kind=CUSTOM_REAL), dimension(:),allocatable :: misfit_proc
  real(kind=CUSTOM_REAL) ::misfit_AD,misfit_DD, misfit
  real(kind=CUSTOM_REAL) :: misfit_ratio_initial=0.001
  real(kind=CUSTOM_REAL) :: misfit_ratio_previous=0.01

! kernels
  integer :: nspec
  integer, dimension(:), allocatable :: nspec_proc
  integer :: nker
  real(kind=CUSTOM_REAL), dimension(:),allocatable :: g_new
  real(kind=CUSTOM_REAL), dimension(:),allocatable :: p_new
  LOGICAL :: precond=.false.
  real(kind=CUSTOM_REAL) :: wtr_precond=0.1

! models
  integer :: nmod
  real(kind=CUSTOM_REAL), dimension(:),allocatable :: m_new
  real(kind=CUSTOM_REAL), dimension(:),allocatable :: m_try

! linesearch
  integer :: is_done=0, is_cont=0, is_brak=0
  real(kind=CUSTOM_REAL) :: step_length, next_step_length,optimal_step_length

!! DISPLAY 
LOGICAL :: DISPLAY_DETAILS=.true.
!----------------------------------------------------------------------
end module seismo_parameters
