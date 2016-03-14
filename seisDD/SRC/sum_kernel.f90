program sum_kernel
!! yanhuay@princeton.edu
!! To calculate summed kernel

#ifdef USE_MPI
  use mpi
#endif
 
use seismo_parameters
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
  integer, parameter :: NARGS = 3
!  integer :: nspec,myrank,nproc,iproc
! index used
  INTEGER :: itime, ier, isrc,i,j
  character(len=MAX_STRING_LEN) :: kernel_names(MAX_KERNEL_NUM)
  character(len=MAX_STRING_LEN) :: kernel_names_comma_delimited

  integer :: iker

  real(kind=CUSTOM_REAL), dimension(:,:,:,:),allocatable :: dat
  real(kind=CUSTOM_REAL), dimension(:,:,:,:),allocatable :: sum_dat

  ! filename
  character(len=MAX_STRING_LEN) :: arg(NARGS)
  character(len=MAX_STRING_LEN) :: input_dir,output_dir
  character(len=MAX_FILENAME_LEN) :: filename
  character, parameter :: delimiter=','
  real t1,t2

#ifdef USE_MPI
  call MPI_INIT(ier)
  call MPI_COMM_SIZE(MPI_COMM_WORLD,nproc,ier)
  call MPI_COMM_RANK(MPI_COMM_WORLD,myrank,ier)
#else
nproc = 1
myrank = 0
#endif


  if (myrank == 0) print *,"Running sum_kernel.exe on",NPROC,"processors"
  call cpu_time(t1)

  ! parse command line arguments
  if (command_argument_count() /= NARGS) then
    if (myrank == 0) then
        print *, 'USAGE:  mpirun -np NPROC bin/sum_kernel.exe KERNEL_NAME input_dir output_dir'
      stop ' Please check command line arguments'
    endif
  endif

#ifdef USE_MPI
  call MPI_BARRIER(MPI_COMM_WORLD,ier)
#endif

  do i = 1, NARGS
    call get_command_argument(i,arg(i), status=ier)
  enddo

  kernel_names_comma_delimited = arg(1)
  input_dir=arg(2)
  output_dir=arg(3)

  call split_string(kernel_names_comma_delimited,delimiter,kernel_names,nker)
  !if(myrank==0) print*,'number of kernels in list:', nker, kernel_names(1:nker)

  !! initialization  -- get number of spectral elements
  call initialize(output_dir) 

   !! allocation 
    allocate(dat(NGLLX,NGLLY,NGLLZ,NSPEC))
    allocate(sum_dat(NGLLX,NGLLY,NGLLZ,NSPEC))
    sum_dat = 0.0_CUSTOM_REAL
    dat = 0.0_CUSTOM_REAL


    ! loop over kernel
    do iker= 1, nker
    if(len(trim(adjustl(kernel_names(iker))))>0) then !non-empty
    ! initialize
    sum_dat = 0.0_CUSTOM_REAL
    dat = 0.0_CUSTOM_REAL

    ! loop over event
    do isrc=0, NSRC-1

    !! kernel file
    write(filename,'(a,i6.6,a,i6.6,a)') &
            trim(input_dir)//'/',isrc,'/'//trim(LOCAL_PATH)//'/proc',&
            myrank,'_'//trim(adjustl(kernel_names(iker)))//'.bin'

    if (myrank == 0 .and. isrc==0)  print*,'LOAD event_kernel -- ',trim(filename)
    ! gets slice of kernel
    open(unit=IIN,file=trim(filename),status='old',action='read',form='unformatted',iostat=ier)
    if (ier /= 0) then
      print *,'Error: could not open kernel file: ',trim(filename)
      stop 'Error reading neighbors external mesh file'
    endif
    ! global point arrays
    read(IIN) dat
    if(DISPLAY_DETAILS .and. isrc==0 .and. myrank==0) then
      print *,' Min / Max event_kernel = ', &
               minval(dat(:,:,:,:)),maxval(dat(:,:,:,:)),&
               'for ',trim(adjustl(kernel_names(iker)))
    endif
    close(IIN)

    !! sum over isrc
    if(trim(adjustl(kernel_names(iker))) .eq. 'hessian1_kernel' .or. &
        trim(adjustl(kernel_names(iker))) .eq. 'hessian2_kernel' ) then
       sum_dat = sum_dat + abs(dat)
    else
       sum_dat = sum_dat + dat
    endif
    enddo   ! isrc

   !! SAVE summed kernel
    write(filename,'(a,i6.6,a)') &
           trim(output_dir)//'/misfit_kernel/proc',myrank,&
          '_'//trim(adjustl(kernel_names(iker)))//'.bin'

    if (myrank == 0) print*,'SAVE misfit_kernel -- ', trim(filename)
    open(unit=IOUT,file=trim(filename),status='unknown',form='unformatted',iostat=ier)
    if (ier /= 0) then
       print*, 'Error: could not open gradient file: ',trim(filename)
      stop 'Error reading neighbors external mesh file'
    endif
    write(IOUT) sum_dat
    close(IOUT)

      if(DISPLAY_DETAILS .and. myrank==0) then
      print *,' Min / Max misfit_kernel = ',&
              minval(sum_dat(:,:,:,:)),maxval(sum_dat(:,:,:,:)),&
               'for ',trim(adjustl(kernel_names(iker)))

      endif

  endif ! non-empty
  
  
  enddo !iker

   !! finalize
    deallocate(dat)
    deallocate(sum_dat) 

   call cpu_time(t2)

   if (myrank == 0)  print *,'Computation time with CPU:',t2-t1

#ifdef USE_MPI
  ! stop all the processes and exit
  call MPI_FINALIZE(ier)
#endif
     

end program sum_kernel

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

subroutine initialize(directory)
use seismo_parameters
implicit none

  integer :: ier
  character(len=MAX_FILENAME_LEN) :: filename
  character(len=MAX_STRING_LEN) :: directory

  
  write(filename,'(a,i6.6,a)') &
           trim(directory)//'/misfit_kernel/proc',myrank,'_'//trim(IBOOL_NAME)
   
  open(IIN,file=trim(filename),status='old',action='read',form='unformatted',iostat=ier)
      if (ier /= 0) then
          print *,'Error: could not open database file: ',trim(filename)
          stop 'Error opening _NSPEC_IBOOL file'
      endif
      read(IIN) nspec
      close(IIN)
    if(DISPLAY_DETAILS .and. myrank==0) print*,' number of elements : ',nspec


end subroutine initialize


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


