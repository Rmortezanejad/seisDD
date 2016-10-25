!! main subroutines to evaluate misfit and ajoint source
!! created by Yanhua O. Yuan ( yanhuay@princeton.edu)

!----------------------------------------------------------------------
subroutine misfit_adj_AD(measurement_type,d,s,NSTEP,deltat,f0,ntstart,ntend,&
        window_type,compute_adjoint, &
        adj,num)
    !! conventional way to do tomography, 
    !! using absolute-difference measurements of data(d) and syn (s)

    use constants
    implicit none

    ! inputs & outputs 
    character(len=2), intent(in) :: measurement_type
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d,s
    real(kind=CUSTOM_REAL), intent(in) :: deltat,f0
    integer, intent(in) :: NSTEP,ntstart,ntend,window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj

    ! initialization within loop of irec
    adj(1:NSTEP)=0.d0
    num=1

    select case (measurement_type)
    case ("CC")
        if(DISPLAY_DETAILS) print*, 'CC (traveltime) misfit (s-d)'
        call CC_misfit(d,s,NSTEP,deltat,f0,ntstart,ntend,&
            window_type,compute_adjoint, &
            adj,num)
    case ("WD")
        if(DISPLAY_DETAILS) print*, 'WD (waveform-difference) misfit (s-d)'
        call WD_misfit(d,s,NSTEP,deltat,ntstart,ntend,&
            window_type,compute_adjoint,&
            adj,num)
    case ("ET")
        if(DISPLAY_DETAILS) print*, 'ET (envelope cc-traveltime) misfit (s-d)'
        call ET_misfit(d,s,NSTEP,deltat,f0,ntstart,ntend,&
            window_type,compute_adjoint,&
            adj,num)
    case ("ED")
        if(DISPLAY_DETAILS) print*, 'ED (envelope-difference) misfit (s-d)'
        call ED_misfit(d,s,NSTEP,deltat,ntstart,ntend,&
            window_type,compute_adjoint,&
            adj,num)
    case ("IP")
        if(DISPLAY_DETAILS) print*, 'IP (instantaneous phase) misfit (s-d)'
        call IP_misfit(d,s,NSTEP,deltat,ntstart,ntend,&
            window_type,compute_adjoint,&
            adj,num)
    case ("MT")
        if(DISPLAY_DETAILS) print*, 'MT (multitaper traveltime) misfit (d-s)'
        call MT_misfit(d,s,NSTEP,deltat,f0,ntstart,ntend,&
            window_type,'MT',compute_adjoint,&
            adj,num)
    case ("MA")
        if(DISPLAY_DETAILS) print*, 'MA (multitaper amplitude) misfit (d-s)'
        call MT_misfit(d,s,NSTEP,deltat,f0,ntstart,ntend,&
            window_type,'MA',compute_adjoint,&
            adj,num)
    case default
        print*, 'measurement_type must be among "CC"/"WD"/"ET"/"ED"/"IP"/"MT"/"MA"/...';
        stop
    end select

end subroutine misfit_adj_AD
!------------------------------------------------------------------------
subroutine misfit_adj_DD(measurement_type,d,d_ref,s,s_ref,NSTEP,deltat,f0,&
        ntstart,ntend,ntstart_ref,ntend_ref,window_type,compute_adjoint,&
        adj,adj_ref,num)
    !! relative way to do tomography, 
    !! using double-difference measurements of data(d) and ref data(d_ref);
    !! syn (s) and ref syn(s_ref)
    use constants
    implicit none

    ! inputs & outputs 
    character(len=2), intent(in) :: measurement_type
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d,s,d_ref,s_ref
    real(kind=CUSTOM_REAL), intent(in) :: deltat,f0
    integer, intent(in) :: NSTEP,ntstart,ntend,ntstart_ref,ntend_ref,window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj,adj_ref

    ! initialization within loop of irec
    adj(1:NSTEP)=0.d0
    adj_ref(1:NSTEP)=0.d0
    num=1

    select case (measurement_type)
    case ("CC")
        if(DISPLAY_DETAILS) print*, '*** Double-difference CC (traveltime) misfit'
        call CC_misfit_DD(d,d_ref,s,s_ref,NSTEP,deltat,&
            ntstart,ntend,ntstart_ref,ntend_ref,window_type,compute_adjoint,&
            adj,adj_ref,num)
    case ("WD")
        if(DISPLAY_DETAILS) print*, '*** Double-difference WD (waveform) misfit'
        call WD_misfit_DD(d,d_ref,s,s_ref,NSTEP,deltat,&
            ntstart,ntend,ntstart_ref,ntend_ref,window_type,compute_adjoint,&
            adj,adj_ref,num)
    case ("IP")
        if(DISPLAY_DETAILS) print*, '*** Double-difference IP (instantaneous) misfit'
        call IP_misfit_DD(d,d_ref,s,s_ref,NSTEP,deltat,&
            ntstart,ntend,ntstart_ref,ntend_ref,window_type,compute_adjoint,&
            adj,adj_ref,num)
    case ("MT")
        if(DISPLAY_DETAILS) print*, '*** Double-difference MT (multitaper) misfit'
        call MT_misfit_DD(d,d_ref,s,s_ref,NSTEP,deltat,f0,&
            ntstart,ntend,ntstart_ref,ntend_ref,window_type,'MT',compute_adjoint,&
            adj,adj_ref,num)
    case ("MA")
        if(DISPLAY_DETAILS) print*, '*** Double-difference MA (multitaper) misfit'
        call MT_misfit_DD(d,d_ref,s,s_ref,NSTEP,deltat,f0,&
            ntstart,ntend,ntstart_ref,ntend_ref,window_type,'MT',compute_adjoint,&
            adj,adj_ref,num)

    case default
        print*, 'measurement_type must be among CC/WD/IP/MT/MA ...';
        stop

    end select

end subroutine misfit_adj_DD
!------------------------------------------------------------------------

!----------------------------------------------------------------------
!---------------subroutines for misfit_adjoint-------------------------
!-----------------------------------------------------------------------
subroutine WD_misfit(d,s,npts,deltat,i_tstart,i_tend,window_type,compute_adjoint,&
        adj,num)
    !! waveform difference between d and s

    use constants
    implicit none

    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d,s
    real(kind=CUSTOM_REAL), intent(in) :: deltat
    integer, intent(in) :: i_tstart, i_tend 
    integer, intent(in) :: npts,window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj

    ! index 
    integer :: i
    real(kind=CUSTOM_REAL) :: const=1.0

    ! window
    integer :: nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d_tw,s_tw
    ! adjoint
    real(kind=CUSTOM_REAL), dimension(npts) ::  adj_tw

    !! window
    call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
    call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
    if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen

    !! WD misfit
    const = sum(d_tw(1:nlen)**2)*deltat
    do i=1,nlen 
    write(IOUT,*) (s_tw(i)-d_tw(i))*sqrt(deltat)/sqrt(const)
    enddo
    num=nlen

    if( DISPLAY_DETAILS) then
        print*
        print*, 'time-domain winodw'
        print*, 'time window boundaries : ',i_tstart,i_tend
        print*, 'time window length : ', nlen
        open(1,file=trim(output_dir)//'/dat_syn',status='unknown')
        open(2,file=trim(output_dir)//'/dat_syn_win',status='unknown')
        do  i = i_tstart,i_tend
        write(1,'(I5,2e15.5)') i, d(i),s(i)
        enddo
        do  i = 1,nlen
        write(2,'(I5,2e15.5)') i, d_tw(i),s_tw(i)
        enddo
        close(1)
        close(2)
    endif

    !! WD adjoint
    if(COMPUTE_ADJOINT) then
        adj_tw(1:nlen) =  (s_tw(1:nlen)-d_tw(1:nlen))/const

        ! reverse window and taper again 
        call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)

        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/adj_WD',status='unknown')
            do  i =  i_tstart,i_tend
            write(1,'(I5,e15.5)') i,adj(i)
            enddo
            close(1)
        endif

    endif

end subroutine WD_misfit
!-----------------------------------------------------------------------
subroutine CC_misfit(d,s,npts,deltat,f0,i_tstart, i_tend,window_type,compute_adjoint,&
        adj,num)
    !! CC traveltime shift between d and s

    use constants
    implicit none 

    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d,s
    real(kind=CUSTOM_REAL), intent(in) :: deltat,f0
    integer, intent(in) :: i_tstart, i_tend
    integer, intent(in) :: npts,window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj

    ! index
    integer :: i

    ! window
    integer :: nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d_tw,s_tw 
    ! cc 
    integer :: ishift
    real(kind=CUSTOM_REAL) :: tshift, dlnA, cc_max 
    ! adjoint
    real(kind=CUSTOM_REAL) :: Mtr
    real(kind=CUSTOM_REAL), dimension(npts) :: s_tw_vel, adj_tw 

    !! window
    call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
    call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
    if(nlen<1 .or. nlen>npts) print*,'check i_start,i_tend, nlen ',i_tstart,i_tend,nlen

    !! CC misfit
    call xcorr_calc(s_tw,d_tw,npts,1,nlen,ishift,dlnA,cc_max) ! T(s-d)
    tshift = ishift*deltat  
    write(IOUT,*) tshift
    num=1

    if( DISPLAY_DETAILS) then
        print*
        print*, 'time-domain winodw'
        print*, 'time window boundaries : ',i_tstart,i_tend
        print*, 'time window length (sample /  second) : ', nlen, nlen*deltat
        print*, 'cc ishift/tshift/dlnA of s-d : ', ishift,tshift,dlnA
        open(1,file=trim(output_dir)//'/dat_syn_win',status='unknown')
        do  i = 1,nlen
        write(1,'(I5,2e15.5)') i, d_tw(i),s_tw(i)
        enddo
        close(1)
    endif

    !! cc adjoint
    if(COMPUTE_ADJOINT) then
        ! computer velocity 
        call compute_vel(s_tw,npts,deltat,nlen,s_tw_vel)

        ! constant on the bottom 
        Mtr=-sum(s_tw_vel(1:nlen)*s_tw_vel(1:nlen))*deltat

        ! adjoint source
        adj_tw(1:nlen)=  tshift*s_tw_vel(1:nlen)/Mtr 

        ! reverse window and taper again 
        call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)


        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/adj_CC',status='unknown')
            do  i =  i_tstart,i_tend
            write(1,'(I5,e15.5)') i,adj(i)
            enddo
            close(1)
        endif

    endif

end subroutine CC_misfit
! -----------------------------------------------------------------------
subroutine ET_misfit(d,s,npts,deltat,f0,i_tstart,i_tend,window_type,compute_adjoint,&
        adj,num)
    !! Envelope time shift between d and s

    use constants
    use m_hilbert_transform
    implicit none

    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d,s
    real(kind=CUSTOM_REAL), intent(in) :: deltat,f0
    integer, intent(in) :: i_tstart,i_tend
    integer, intent(in) :: npts, window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj

    ! window
    integer :: nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d_tw,s_tw

    ! for hilbert transformation
    real(kind=CUSTOM_REAL) :: epslon
    real(kind=CUSTOM_REAL), dimension(npts) :: E_d,E_s,E_ratio,hilbt_ratio,hilbt_d,hilbt_s

    ! adjoint
    integer :: i
    real(kind=CUSTOM_REAL), dimension(npts) :: adj_tw
    real(kind=CUSTOM_REAL), dimension(npts) :: seism_vel
    real(kind=CUSTOM_REAL) :: Mtr

    ! cc 
    integer :: ishift
    real(kind=CUSTOM_REAL) :: tshift, dlnA, cc_max

    !! window
    call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
    call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
    if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen

    !! Envelope time_shift misfit
    ! initialization 
    E_s(:) = 0.0
    E_d(:) = 0.0
    E_ratio(:) = 0.0
    hilbt_ratio (:) = 0.0
    hilbt_d(:) = 0.0
    hilbt_s(:) = 0.0

    ! hilbert transform of d
    hilbt_d(1:nlen) = d_tw(1:nlen)
    call hilbert(hilbt_d,nlen)
    ! envelope
    E_d(1:nlen) = sqrt(d_tw(1:nlen)**2+hilbt_d(1:nlen)**2)

    ! hilbert transform of s
    hilbt_s(1:nlen) = s_tw(1:nlen)
    call hilbert(hilbt_s,nlen)
    ! envelope
    E_s(1:nlen) = sqrt(s_tw(1:nlen)**2+hilbt_s(1:nlen)**2)

    ! misfit
    call xcorr_calc(E_s,E_d,nlen,1,nlen,ishift,dlnA,cc_max) ! T(Es-Ed)
    tshift = ishift*deltat
    write(IOUT,*) tshift
    num=1

    if( DISPLAY_DETAILS) then
        print*
        print*, 'time-domain winodw'
        print*, 'time window boundaries : ',i_tstart,i_tend
        print*, 'time window length (sample /  second) : ', nlen, nlen*deltat
        print*, 'cc ishift/tshift/dlnA of Es-Ed : ', ishift,tshift,dlnA
        open(1,file=trim(output_dir)//'/dat_syn_win',status='unknown')
        open(2,file=trim(output_dir)//'/dat_syn_env',status='unknown')
        do  i = 1,nlen
        write(1,'(I5,2e15.5)') i, d_tw(i),s_tw(i)
        write(2,'(I5,2e15.5)') i, E_d(i),E_s(i)
        enddo
        close(1)
        close(2)
    endif

    !! Envelope time_shift adjoint
    if(COMPUTE_ADJOINT) then

        ! computer velocity 
        call compute_vel(E_s,npts,deltat,nlen,seism_vel)

        ! constant factor
        Mtr=-sum(seism_vel(1:nlen)*seism_vel(1:nlen))*deltat

        ! E_ratio
        epslon=wtr_env*maxval(E_s)
        E_ratio(1:nlen) =  tshift /Mtr*seism_vel(1:nlen)/(E_s(1:nlen)+epslon)

        ! hilbert transform for E_ratio*hilbt
        hilbt_ratio=E_ratio * hilbt_s
        call hilbert(hilbt_ratio,nlen)

        ! adjoint source
        adj_tw(1:nlen)=E_ratio(1:nlen)*s_tw(1:nlen)-hilbt_ratio(1:nlen)
        adj_tw(1:nlen)=adj_tw(1:nlen)

        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/E_ratio',status='unknown')
            print*
            print*, 'water level for E_ratio is : ', epslon
            do  i = 1,nlen
            write(1,'(I5,2e15.5)') i,E_ratio(i),hilbt_ratio(i)
            enddo
            close(1)
        endif

        ! reverse window and taper again 
        call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)

        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/adj_ET',status='unknown')
            do  i = i_tstart,i_tend
            write(1,'(I5,e15.5)') i,adj(i)
            enddo
            close(1)
        endif

    endif

end subroutine ET_misfit
!-----------------------------------------------------------------------
subroutine ED_misfit(d,s,npts,deltat,i_tstart,i_tend,window_type,compute_adjoint,&
        adj, num)
    !! Envelope difference between d and s

    use constants
    use m_hilbert_transform
    implicit none

    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d,s
    real(kind=CUSTOM_REAL), intent(in) :: deltat
    integer, intent(in) :: i_tstart,i_tend
    integer, intent(in) :: npts, window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj

    ! window
    integer :: nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d_tw,s_tw

    ! for hilbert transformation
    real(kind=CUSTOM_REAL) :: epslon
    real(kind=CUSTOM_REAL), dimension(npts) :: E_d,E_s,E_ratio,hilbt_ratio,hilbt_d,hilbt_s

    ! adjoint
    integer :: i
    real(kind=CUSTOM_REAL), dimension(npts) :: adj_tw

    !! window
    call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
    call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
    if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen

    !! Envelope difference misfit
    ! initialization 
    E_s(:) = 0.0
    E_d(:) = 0.0
    E_ratio(:) = 0.0
    hilbt_ratio (:) = 0.0
    hilbt_d(:) = 0.0
    hilbt_s(:) = 0.0

    ! hilbert transform of d
    hilbt_d(1:nlen) = d_tw(1:nlen)
    call hilbert(hilbt_d,nlen)
    ! envelope
    E_d(1:nlen) = sqrt(d_tw(1:nlen)**2+hilbt_d(1:nlen)**2)

    ! hilbert for s
    hilbt_s(1:nlen) = s_tw(1:nlen)
    call hilbert(hilbt_s,nlen)
    ! envelope
    E_s(1:nlen) = sqrt(s_tw(1:nlen)**2+hilbt_s(1:nlen)**2) 

    ! ED misfit
    do i=1,nlen
    write(IOUT,*) (E_s(i)-E_d(i))*sqrt(deltat)
    enddo
    num=nlen

    if( DISPLAY_DETAILS) then
        print*
        print*, 'time-domain winodw'
        print*, 'time window boundaries : ',i_tstart,i_tend
        print*, 'time window length : ', nlen
        open(1,file=trim(output_dir)//'/dat_env',status='unknown')
        open(2,file=trim(output_dir)//'/syn_env',status='unknown')
        do  i = 1,nlen
        write(1,'(I5,2e15.5)') i, d_tw(i),E_d(i)
        write(2,'(I5,2e15.5)') i, s_tw(i),E_s(i)
        enddo
        close(1)
        close(2)
    endif

    !! Envelope difference adjoint
    if(COMPUTE_ADJOINT) then

        ! E_ratio
        epslon=wtr_env*maxval(E_s)
        E_ratio(1:nlen)=(E_s(1:nlen)-E_d(1:nlen))/(E_s(1:nlen)+epslon)

        ! hilbert transform for E_ratio*hilbt
        hilbt_ratio=E_ratio * hilbt_s
        call hilbert(hilbt_ratio,nlen)

        ! adjoint source
        adj_tw(1:nlen)=E_ratio(1:nlen)*s_tw(1:nlen)-hilbt_ratio(1:nlen)

        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/E_ratio',status='unknown')
            print*
            print*, 'water level for E_ratio is : ', epslon
            do  i = 1,nlen
            write(1,'(I5,2e15.5)') i,E_ratio(i),hilbt_ratio(i)
            enddo
            close(1)
        endif

        ! reverse window and taper again 
        call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)

        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/adj_ED',status='unknown')
            do  i = i_tstart,i_tend
            write(1,'(I5,e15.5)') i,adj(i)
            enddo
            close(1)
        endif

    endif

end subroutine ED_misfit
!-----------------------------------------------------------------------
subroutine IP_misfit(d,s,npts,deltat,i_tstart,i_tend,window_type,compute_adjoint,&
        adj,num)
    !! Instantaneous phase difference between d and s (need to be fixed)

    use constants
    use m_hilbert_transform
    implicit none

    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d,s
    real(kind=CUSTOM_REAL), intent(in) :: deltat
    integer, intent(in) :: i_tstart,i_tend
    integer, intent(in) :: npts, window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj

    ! index 
    integer :: i

    ! window
    integer :: nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d_tw,s_tw

    ! for hilbert transformation
    real(kind=CUSTOM_REAL) :: wtr_d, wtr_s
    real(kind=CUSTOM_REAL), dimension(npts) :: E_d,E_s,E_ratio,hilbt_ratio
    real(kind=CUSTOM_REAL), dimension(npts) :: norm_s, norm_d
    real(kind=CUSTOM_REAL), dimension(npts) :: hilbt_d, hilbt_s, real_diff, imag_diff

    real(kind=CUSTOM_REAL) :: tas(npts)
    ! adjoint
    real(kind=CUSTOM_REAL), dimension(npts) :: adj_tw

    !! window
    call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
    call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
    if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen

    !tas(1:npts)=0.d0
    !call window(npts,1,nlen,window_type,tas)
    !! Instantaneous phase misfit
    ! initialization 
    real_diff(:) = 0.0
    imag_diff(:) = 0.0
    E_d(:) = 0.0
    E_s(:) = 0.0 
    E_ratio(:) = 0.0
    hilbt_ratio (:) = 0.0
    hilbt_d(:)=0.0
    hilbt_s(:)=0.0

    !! be careful about phase measurement -- cycle-skipping

    !! hilbert for obs
    hilbt_d(1:nlen)=d_tw(1:nlen)
    call hilbert(hilbt_d,nlen)
    E_d(1:nlen)=sqrt(hilbt_d(1:nlen)**2+d_tw(1:nlen)**2)

    !! hilbert for syn
    hilbt_s(1:nlen)=s_tw(1:nlen)
    call hilbert(hilbt_s,nlen)
    E_s(1:nlen)=sqrt(hilbt_s(1:nlen)**2+s_tw(1:nlen)**2)

    !! removing amplitude info 
    wtr_d=wtr_env*maxval(E_d)
    wtr_s=wtr_env*maxval(E_s)

    !! diff for real & imag part
    norm_s=sqrt((s_tw(1:nlen)/(E_s(1:nlen)+wtr_s))**2+(hilbt_s(1:nlen)/(E_s(1:nlen)+wtr_s))**2)
    norm_d=sqrt((d_tw(1:nlen)/(E_d(1:nlen)+wtr_d))**2+(hilbt_d(1:nlen)/(E_d(1:nlen)+wtr_d))**2)
    real_diff= (s_tw(1:nlen)/(E_s(1:nlen)+wtr_s) - d_tw(1:nlen)/(E_d(1:nlen)+wtr_d)) !*tas(1:nlen)
    imag_diff= (hilbt_s(1:nlen)/(E_s(1:nlen)+wtr_s) - hilbt_d(1:nlen)/(E_d(1:nlen)+wtr_d)) !*tas(1:nlen)

    ! IP misfit
    do i=1,nlen
    write(IOUT,*) real_diff(i)*sqrt(deltat)
    write(IOUT,*) imag_diff(i)*sqrt(deltat)
    enddo
    num=nlen*2

    if(DISPLAY_DETAILS) then
        print*
        print*, 'time-domain winodw'
        print*, 'time window boundaries : ',i_tstart,i_tend
        print*, 'time window length : ', nlen
        open(1,file=trim(output_dir)//'/dat_env',status='unknown')
        open(2,file=trim(output_dir)//'/syn_env',status='unknown')
        open(3,file=trim(output_dir)//'/phi_dat_syn',status='unknown')
        do  i = 1,nlen
        write(1,'(I5,2e15.5)') i, d_tw(i),E_d(i)
        write(2,'(I5,2e15.5)') i, s_tw(i),E_s(i)
        write(3,'(I5,2e15.5)') i, real_diff(i), imag_diff(i)
        enddo
        close(1)
        close(2)
        close(3)
    endif

    !! Instantaneous phase adjoint
    if(COMPUTE_ADJOINT) then
        ! both real and imaginary
        E_ratio = (real_diff*hilbt_s**2 - imag_diff*s_tw*hilbt_s) /(E_s+wtr_s)**3
        hilbt_ratio = (real_diff*s_tw*hilbt_s-imag_diff*s_tw**2)/(E_s+wtr_s)**3
        ! hilbert transform for hilbt_ratio
        call hilbert(hilbt_ratio,nlen)

        ! adjoint source
        adj_tw(1:nlen)=E_ratio(1:nlen) + hilbt_ratio

        ! reverse window and taper again 
        call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)

        if(DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/adj_IP',status='unknown')
            do  i = i_tstart,i_tend
            write(1,'(I5,3e15.5)') i,d(i),s(i),adj(i)
            enddo
            close(1)
        endif

    endif

end subroutine IP_misfit
!-----------------------------------------------------------------------
subroutine MT_misfit(d,s,npts,deltat,f0,i_tstart, i_tend,window_type,misfit_type,&
        compute_adjoint,adj,num)
    !! MT between d and s (d-s) 

    use constants
    implicit none

    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d,s
    real(kind=CUSTOM_REAL), intent(in) :: deltat,f0
    integer, intent(in) :: i_tstart,i_tend
    integer, intent(in) :: npts,window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj
    character(len=2), intent(in) :: misfit_type

    ! index
    integer :: i,j
    ! window
    integer :: nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d_tw,s_tw, d_tw_cc
    ! cc 
    integer :: ishift
    real(kind=CUSTOM_REAL) :: tshift, dlnA, cc_max
    real(kind=CUSTOM_REAL) :: err_dt_cc=0.0,err_dlnA_cc=1.0

    ! FFT parameters
    real(kind=CUSTOM_REAL), dimension(NPT) :: wvec,fvec
    real(kind=CUSTOM_REAL) :: df,df_new,dw

    ! mt 
    integer :: i_fstart, i_fend
    !  real(kind=CUSTOM_REAL) ::B,W, NW
    !  integer :: ntaper,mtaper
    !  real(kind=CUSTOM_REAL), dimension(NPT) :: eigens, ey2
    !  real(kind=CUSTOM_REAL), dimension(:,:),allocatable :: tas
    real(kind=CUSTOM_REAL), dimension(NPT) :: dtau_w, dlnA_w,err_dtau_mt,err_dlnA_mt
    complex(CUSTOM_REAL), dimension(NPT) :: trans_func

    ! adjoint
    real(kind=CUSTOM_REAL), dimension(npts) :: adj_p_tw,adj_q_tw

    !! window
    ishift = 0 
    dlnA = 0.0
    call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
    call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
    if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen

    !! cc correction
    call xcorr_calc(d_tw,s_tw,npts,1,nlen,ishift,dlnA,cc_max) ! T(d-s)
    tshift= ishift*deltat
    if( DISPLAY_DETAILS) then
        print*
        print*, 'xcorr_cal: d-s'
        print*, 'xcorr_calc: calculated ishift/tshift = ', ishift,tshift
        print*, 'xcorr_calc: calculated dlnA = ',dlnA
        print*, 'xcorr_calc: cc_max ',cc_max
    endif

    !! cc_error
    if(USE_ERROR_CC)  call cc_error(d_tw,s_tw,npts,deltat,nlen,ishift,dlnA,&
        err_dt_cc,err_dlnA_cc)

    ! correction for d using negative cc
    ! fixed window for s, correct the window for d
    !dlnA =0.0
    ! call cc_window(d,npts,window_type,i_tstart,i_tend,-ishift,-dlnA,nlen,d_tw_cc)
    call cc_window(d,npts,window_type,i_tstart,i_tend,-ishift,0.0,nlen,d_tw_cc)

    if( DISPLAY_DETAILS) then
        print*
        print*, 'CC corrections to data using negative ishift/tshift/dlnA: ',-ishift,-tshift,-dlnA
        open(1,file=trim(output_dir)//'/dat_syn_datcc',status='unknown')
        do  i = 1,nlen
        write(1,'(I5,3f15.5)') i, d_tw(i),s_tw(i),d_tw_cc(i)
        enddo
        close(1)
    endif

    d_tw = d_tw_cc

    !! MT misfit
    !-----------------------------------------------------------------------------
    !  set up FFT for the frequency domain
    !----------------------------------------------------------------------------- 
    df = 1./(NPT*deltat)
    dw = TWOPI * df
    ! calculate frequency spacing of sampling points
    df_new = 1.0 / (nlen*deltat)
    ! assemble omega vector (NPT is the FFT length)
    wvec(:) = 0.
    do j = 1,NPT
    if(j > NPT/2+1) then
        wvec(j) = dw*(j-NPT-1)   ! negative frequencies in second half
    else
        wvec(j) = dw*(j-1)       ! positive frequencies in first half
    endif
    enddo
    fvec = wvec / TWOPI

    !!   find the relaible frequency limit
    call frequency_limit(s_tw,nlen,deltat,i_fstart,i_fend) ! limit from spectra
    i_fend = min(i_fend, floor(1.0/(2*deltat)/df)+1,floor(f0*2.5/df)+1)  ! not exceeding the sampling rate
    i_fstart = max(i_fstart,ceiling(3.0/(nlen*deltat)/df)+1,ceiling(f0/2.5/df)+1) ! include at least 5 cyles in window

    if( DISPLAY_DETAILS) then
        print*
        print*, 'find the spectral boundaries for reliable measurement'
        print*, 'min, max frequency limits : ', i_fstart, i_fend
        print*, 'frequency interval df= ', df, ' dw=', dw
        print*, 'effective bandwidth (Hz) : ',fvec(i_fstart), fvec(i_fend), fvec(i_fend)-fvec(i_fstart)
        print*, 'half time-bandwidth product : ', NW
        print*, 'number of tapers : ',ntaper
        print*, 'resolution of multitaper (Hz) : ', NW/(nlen*deltat)
        print*, 'number of segments of frequency bandwidth : ', ceiling((fvec(i_fend)-fvec(i_fstart))*nlen*deltat/NW)
    endif


    !! mt phase and ampplitude measurement 
    call mt_measure(d_tw,s_tw,npts,deltat,nlen,tshift,0.0,i_fstart,i_fend,&
        wvec,&!mtaper,NW,&
        trans_func,dtau_w,dlnA_w,err_dtau_mt,err_dlnA_mt) !d-s

    if(misfit_type=='MT') then 
        ! MT misfit
        do i=i_fstart,i_fend
        write(IOUT,*) dtau_w(i)*sqrt(dw)
        enddo
    elseif(misfit_type=='MA') then
        ! MA misfit
        do i=i_fstart,i_fend
        write(IOUT,*) dlnA_w(i)*sqrt(dw)
        enddo
    endif
    num=i_fend-i_fstart+1

    if(DISPLAY_DETAILS) then
        !! write into file 
        open(1,file=trim(output_dir)//'/dtau_mtm',status='unknown')
        open(2,file=trim(output_dir)//'/dlnA_mtm',status='unknown')
        do  i = i_fstart,i_fend
        write(1,'(3e15.5)') fvec(i),dtau_w(i),tshift !err_dtau_mt(i)
        write(2,'(3e15.5)') fvec(i),dlnA_w(i),dlnA !err_dlnA_mt(i)
        enddo
        close(1)
        close(2)
    endif

    !! MT adjoint
    if(COMPUTE_ADJOINT) then

        ! adjoint source
        call mtm_adj(s_tw,npts,deltat,nlen,df,i_fstart,i_fend,dtau_w,dlnA_w,&
            err_dt_cc,err_dlnA_cc,&
            err_dtau_mt,err_dlnA_mt, &
            ! mtaper,NW,&
        adj_p_tw,adj_q_tw)

        adj_p_tw(1:nlen) = adj_p_tw(1:nlen) * cc_max**2
        adj_q_tw(1:nlen) = adj_q_tw(1:nlen) * cc_max**2

        ! inverse window and taper again 
        if(misfit_type=='MT') then
            call cc_window_inverse(adj_p_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)
        elseif(misfit_type=='MA') then
            call cc_window_inverse(adj_q_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)
        endif
        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/adj_MT',status='unknown')
            do  i =  i_tstart,i_tend
            write(1,'(I5,e15.5)') i,adj(i)
            enddo
            close(1)
            close(2)
        endif

    endif

    !deallocate (tas)

end subroutine MT_misfit
! -----------------------------------------------------------------------
subroutine CC_misfit_DD(d1,d2,s1,s2,npts,deltat,&
        i_tstart1,i_tend1,i_tstart2,i_tend2,&
        window_type,compute_adjoint,&
        adj1,adj2,num)
    !! CC traveltime double difference

    use constants
    implicit none

    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d1,d2,s1,s2
    real(kind=CUSTOM_REAL), intent(in) :: deltat
    integer, intent(in) :: i_tstart1,i_tend1,i_tstart2,i_tend2
    integer, intent(in) :: npts,window_type
    logical, intent(in) :: compute_adjoint
    real(kind=CUSTOM_REAL) :: cc_max_syn,cc_max_obs
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj1,adj2

    ! index
    integer :: i

    ! window
    integer :: nlen1,nlen2,nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d1_tw,d2_tw,s1_tw,s2_tw
    ! cc 
    integer :: ishift_obs,ishift_syn
    real(kind=CUSTOM_REAL) :: tshift_obs,tshift_syn
    real(kind=CUSTOM_REAL) :: dlnA_obs,dlnA_syn
    real(kind=CUSTOM_REAL) :: ddtshift_cc,ddlnA_cc
    ! adjoint
    real(kind=CUSTOM_REAL) :: Mtr
    real(kind=CUSTOM_REAL), dimension(npts) :: s1_tw_cc,s2_tw_cc
    real(kind=CUSTOM_REAL), dimension(npts) :: s1_tw_vel,s2_tw_vel,s1_tw_cc_vel,s2_tw_cc_vel
    real(kind=CUSTOM_REAL), dimension(npts) :: adj1_tw,adj2_tw

    !! window
    call cc_window(d1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,d1_tw)
    call cc_window(s1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,s1_tw)
    call cc_window(d2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,d2_tw)
    call cc_window(s2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,s2_tw)
    if(nlen1<1 .or. nlen1>npts) print*,'check nlen1 ',nlen1
    if(nlen2<1 .or. nlen2>npts) print*,'check nlen2 ',nlen2
    nlen = max(nlen1,nlen2)

    !! DD cc-misfit
    call xcorr_calc(d1_tw,d2_tw,npts,1,nlen,ishift_obs,dlnA_obs,cc_max_obs) ! T(d1-d2)
    tshift_obs= ishift_obs*deltat
    call xcorr_calc(s1_tw,s2_tw,npts,1,nlen,ishift_syn,dlnA_syn,cc_max_syn) ! T(s1-s2)
    tshift_syn= ishift_syn*deltat
    !! double-difference cc-measurement 
    ddtshift_cc = tshift_syn - tshift_obs
    ddlnA_cc = dlnA_syn - dlnA_obs
    write(IOUT,*) ddtshift_cc
    num=1

    if( DISPLAY_DETAILS) then
        print*
        print*, 'time-domain winodw'
        print*, 'time window boundaries for d1/s1: ',i_tstart1,i_tend1
        print*, 'time window length for d1/s1 : ', nlen1
        print*, 'time window boundaries for d2/s2: ',i_tstart2,i_tend2
        print*, 'time window length for d2/s2 : ', nlen2
        print*, 'cc ishift/tsfhit/dlnA (d1-d2): ', ishift_obs,tshift_obs,dlnA_obs
        print*, 'cc ishift/tshift/dlnA (s1-s2): ', ishift_syn,tshift_syn,dlnA_syn
        print*, 'cc double-difference ddtshift/ddlnA of (s1-s2)-(d1-d2): ', ddtshift_cc,ddlnA_cc
        print*, 'cc_max_obs, cc_max_syn : ',cc_max_obs, cc_max_syn 
        print*
        open(1,file=trim(output_dir)//'/dat_syn_win',status='unknown')
        open(2,file=trim(output_dir)//'/dat_syn_ref_win',status='unknown')
        do  i = 1,nlen1
        write(1,'(I5,2e15.5)') i, d1_tw(i),s1_tw(i)
        enddo
        do i =1,nlen2
        write(2,'(I5,2e15.5)') i, d2_tw(i),s2_tw(i)
        enddo
        close(1)
        close(2)
    endif

    !!DD cc-adjoint
    if(COMPUTE_ADJOINT) then
        ! initialization 
        adj1_tw(:) = 0.0
        adj2_tw(:) = 0.0
        adj1(1:npts) = 0.0 
        adj2(1:npts) = 0.0

        ! cc-shift s2
        call cc_window(s2,npts,window_type,i_tstart2,i_tend2,ishift_syn,0.d0,nlen2,s2_tw_cc)
        ! inverse cc-shift s1
        call cc_window(s1,npts,window_type,i_tstart1,i_tend1,-ishift_syn,0.d0,nlen1,s1_tw_cc)
        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/syn1_cc',status='unknown')
            open(2,file=trim(output_dir)//'/syn2_cc',status='unknown')
            do  i = 1,nlen
            write(1,'(I5,3e15.5)') i,s2_tw(i),s1_tw(i),s1_tw_cc(i)
            write(2,'(I5,3e15.5)') i,s1_tw(i),s2_tw(i),s2_tw_cc(i)
            enddo
            close(1)
            close(2)
        endif

        ! computer velocity 
        call compute_vel(s1_tw,npts,deltat,nlen,s1_tw_vel)
        ! call compute_vel(s2_tw,npts,deltat,nlen,s2_tw_vel)
        call compute_vel(s1_tw_cc,npts,deltat,nlen,s1_tw_cc_vel)
        call compute_vel(s2_tw_cc,npts,deltat,nlen,s2_tw_cc_vel)

        ! constant on the bottom 
        Mtr=-sum(s1_tw_vel(1:nlen)*s2_tw_cc_vel(1:nlen))*deltat

        ! adjoint source
        adj1_tw(1:nlen)= +ddtshift_cc * s2_tw_cc_vel(1:nlen)/Mtr
        adj2_tw(1:nlen)= -ddtshift_cc * s1_tw_cc_vel(1:nlen)/Mtr

        ! reverse window and taper again 
        call cc_window_inverse(adj1_tw,npts,window_type,i_tstart1,i_tend1,0,0.d0,adj1)
        call cc_window_inverse(adj2_tw,npts,window_type,i_tstart2,i_tend2,0,0.d0,adj2)

        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/adj_win',status='unknown')
            open(2,file=trim(output_dir)//'/adj_ref_win',status='unknown')
            do  i =  i_tstart1,i_tend1
            write(1,*) i,adj1(i)
            enddo
            do  i =  i_tstart2,i_tend2
            write(2,*) i,adj2(i)
            enddo
            close(1)
            close(2)
        endif

    endif

end subroutine CC_misfit_DD
!-----------------------------------------------------------------------
subroutine WD_misfit_DD(d1,d2,s1,s2,npts,deltat,&
        i_tstart1,i_tend1,i_tstart2,i_tend2,&
        window_type,compute_adjoint,&
        adj1,adj2,num)
    !! waveform difference between d and s

    use constants
    implicit none

    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d1,d2,s1,s2
    real(kind=CUSTOM_REAL), intent(in) :: deltat
    integer, intent(in) :: i_tstart1,i_tend1,i_tstart2,i_tend2
    integer, intent(in) :: npts,window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj1,adj2

    ! index
    integer :: i

    ! window
    integer :: nlen1,nlen2,nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d1_tw,d2_tw,s1_tw,s2_tw
    ! adjoint
    real(kind=CUSTOM_REAL), dimension(npts) :: adj1_tw,adj2_tw

    !! window
    call cc_window(d1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,d1_tw)
    call cc_window(s1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,s1_tw)
    call cc_window(d2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,d2_tw)
    call cc_window(s2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,s2_tw)
    if(nlen1<1 .or. nlen1>npts) print*,'check nlen1 ',nlen1
    if(nlen2<1 .or. nlen2>npts) print*,'check nlen2 ',nlen2
    nlen = max(nlen1,nlen2)
    !! DD wd-misfit
    !! double-difference wd-measurement 
   ! misfit_output = sqrt(sum(((s1_tw(1:nlen)-s2_tw(1:nlen)) - (d1_tw(1:nlen)-d2_tw(1:nlen)))**2*deltat))
   ! const = sum(d_tw(1:nlen)**2)*deltat
    do i=1,nlen
    write(IOUT,*) ((s1_tw(i)-s2_tw(i)) - (d1_tw(i)-d2_tw(i)))*sqrt(deltat)
    enddo
    num=nlen

    if( DISPLAY_DETAILS) then
        print*
        print*, 'time-domain winodw'
        print*, 'time window boundaries for d1/s1: ',i_tstart1,i_tend1
        print*, 'time window length for d1/s1 : ', nlen1
        print*, 'time window boundaries for d2/s2: ',i_tstart2,i_tend2
        print*, 'time window length for d2/s2 : ', nlen2
    endif

    !!DD WD adjoint
    if(COMPUTE_ADJOINT) then
        ! initialization 
        adj1_tw(:) = 0.0
        adj2_tw(:) = 0.0
        adj1(1:npts) = 0.0
        adj2(1:npts) = 0.0

        ! adjoint source
        adj1_tw(1:nlen)=  (s1_tw(1:nlen)-s2_tw(1:nlen)) -(d1_tw(1:nlen)-d2_tw(1:nlen))
        adj2_tw(1:nlen)=  - adj1_tw(1:nlen)

        ! reverse window and taper again 
        call cc_window_inverse(adj1_tw,npts,window_type,i_tstart1,i_tend1,0,0.d0,adj1)
        call cc_window_inverse(adj2_tw,npts,window_type,i_tstart2,i_tend2,0,0.d0,adj2)

    endif

end subroutine WD_misfit_DD
!----------------------------------------------------------------------
subroutine IP_misfit_DD(d1,d2,s1,s2,npts,deltat,&
        i_tstart1,i_tend1,i_tstart2,i_tend2,&
        window_type,compute_adjoint,&
        adj1,adj2,num)
    !! Instantaneous phase double-difference

    use constants
    use m_hilbert_transform
    implicit none

    ! inputs & outputs 
    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d1,d2,s1,s2
    real(kind=CUSTOM_REAL), intent(in) :: deltat
    integer, intent(in) :: i_tstart1,i_tend1,i_tstart2,i_tend2
    integer, intent(in) :: npts,window_type
    logical, intent(in) :: compute_adjoint
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj1,adj2

    ! index
    integer :: i

    ! window
    integer :: nlen1,nlen2,nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d1_tw,d2_tw,s1_tw,s2_tw
    ! adjoint
    real(kind=CUSTOM_REAL), dimension(npts) :: adj1_tw,adj2_tw

    ! for hilbert transformation
    real(kind=CUSTOM_REAL) :: wtr_d1, wtr_s1, wtr_d2, wtr_s2
    real(kind=CUSTOM_REAL), dimension(npts) :: E_d1,E_s1,E_d2,E_s2
    real(kind=CUSTOM_REAL), dimension(npts) :: E_ratio,hilbt_ratio
    real(kind=CUSTOM_REAL), dimension(npts) :: hilbt_d1, hilbt_s1,hilbt_d2, hilbt_s2
    real(kind=CUSTOM_REAL), dimension(npts) :: real_ddiff, imag_ddiff

    !! window
    call cc_window(d1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,d1_tw)
    call cc_window(s1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,s1_tw)
    call cc_window(d2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,d2_tw)
    call cc_window(s2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,s2_tw)
    if(nlen1<1 .or. nlen1>npts) print*,'check nlen1 ',nlen1
    if(nlen2<1 .or. nlen2>npts) print*,'check nlen2 ',nlen2
    nlen = max(nlen1,nlen2)

    ! initialization 
    real_ddiff(:) = 0.0
    imag_ddiff(:) = 0.0
    E_d1(:) = 0.0
    E_s1(:) = 0.0
    E_d2(:) = 0.0
    E_s2(:) = 0.0
    hilbt_d1(:)=0.0
    hilbt_s1(:)=0.0
    hilbt_d2(:)=0.0
    hilbt_s2(:)=0.0

    !! hilbert for obs1
    hilbt_d1(1:nlen)=d1_tw(1:nlen)
    call hilbert(hilbt_d1,nlen)
    E_d1(1:nlen)=sqrt(hilbt_d1(1:nlen)**2+d1_tw(1:nlen)**2)

    !! hilbert for syn1
    hilbt_s1(1:nlen)=s1_tw(1:nlen)
    call hilbert(hilbt_s1,nlen)
    E_s1(1:nlen)=sqrt(hilbt_s1(1:nlen)**2+s1_tw(1:nlen)**2)

    !! hilbert for obs2
    hilbt_d2(1:nlen)=d2_tw(1:nlen)
    call hilbert(hilbt_d2,nlen)
    E_d2(1:nlen)=sqrt(hilbt_d2(1:nlen)**2+d2_tw(1:nlen)**2)

    !! hilbert for syn2
    hilbt_s2(1:nlen)=s2_tw(1:nlen)
    call hilbert(hilbt_s2,nlen)
    E_s2(1:nlen)=sqrt(hilbt_s2(1:nlen)**2+s2_tw(1:nlen)**2)

    !! removing amplitude info 
    wtr_d1=wtr_env*maxval(E_d1)
    wtr_s1=wtr_env*maxval(E_s1)
    wtr_d2=wtr_env*maxval(E_d2)
    wtr_s2=wtr_env*maxval(E_s2)


    !! double diff for real & imag part
    real_ddiff = (s1_tw(1:nlen)/(E_s1(1:nlen)+wtr_s1) - s2_tw(1:nlen)/(E_s2(1:nlen)+wtr_s2)) &
        - (d1_tw(1:nlen)/(E_d1(1:nlen)+wtr_d1) - d2_tw(1:nlen)/(E_d2(1:nlen)+wtr_d2)) 
    imag_ddiff = (hilbt_s1(1:nlen)/(E_s1(1:nlen)+wtr_s1) - hilbt_s2(1:nlen)/(E_s2(1:nlen)+wtr_s2)) &
        - (hilbt_d1(1:nlen)/(E_d1(1:nlen)+wtr_d1) - hilbt_d2(1:nlen)/(E_d2(1:nlen)+wtr_d2))
    !misfit_output = sqrt(sum(real_ddiff**2*deltat+imag_ddiff**2*deltat))
    do i=1,nlen
    write(IOUT,*) real_ddiff(i)*sqrt(deltat)
    write(IOUT,*) imag_ddiff(i)*sqrt(deltat)
    enddo
    num=nlen*2

    !! DD Instantaneous phase adjoint
    if(COMPUTE_ADJOINT) then
        ! initialization 
        adj1_tw(:) = 0.0
        adj2_tw(:) = 0.0
        adj1(1:npts) = 0.0
        adj2(1:npts) = 0.0
        !! adjoint source1
        E_ratio(:) = 0.0
        hilbt_ratio (:) = 0.0
        E_ratio = (real_ddiff * hilbt_s1**2 - imag_ddiff*s1_tw*hilbt_s1)/(E_s1+wtr_s1)**3
        hilbt_ratio = (real_ddiff*s1_tw*hilbt_s1-imag_ddiff*s1_tw**2)/(E_s1+wtr_s1)**3
        ! hilbert transform for hilbt_ratio
        call hilbert(hilbt_ratio,nlen)
        ! adjoint source
        adj1_tw(1:nlen)=E_ratio(1:nlen) + hilbt_ratio

        !! adjoint source2
        E_ratio(:) = 0.0
        hilbt_ratio (:) = 0.0
        E_ratio = -(real_ddiff * hilbt_s2**2 - imag_ddiff*s2_tw*hilbt_s2)/(E_s2+wtr_s2)**3
        hilbt_ratio = -(real_ddiff*s2_tw*hilbt_s2-imag_ddiff*s2_tw**2)/(E_s2+wtr_s2)**3
        ! hilbert transform for hilbt_ratio
        call hilbert(hilbt_ratio,nlen)
        ! adjoint source
        adj2_tw(1:nlen)=E_ratio(1:nlen) + hilbt_ratio

        ! reverse window and taper again 
        call cc_window_inverse(adj1_tw,npts,window_type,i_tstart1,i_tend1,0,0.d0,adj1)
        call cc_window_inverse(adj2_tw,npts,window_type,i_tstart2,i_tend2,0,0.d0,adj2)
    endif

end subroutine IP_misfit_DD
!----------------------------------------------------------------------
subroutine MT_misfit_DD(d1,d2,s1,s2,npts,deltat,f0,&
        i_tstart1,i_tend1,i_tstart2,i_tend2,&
        window_type,misfit_type,compute_adjoint,&
        adj1,adj2,num)
    !! multitaper double-difference adjoint 
    use constants
    implicit none

    ! inputs & outputs 
    real(kind=CUSTOM_REAL), dimension(*), intent(in) :: d1,d2,s1,s2
    real(kind=CUSTOM_REAL), intent(in) :: deltat,f0
    integer, intent(in) :: i_tstart1, i_tend1,i_tstart2,i_tend2
    integer, intent(in) :: npts,window_type
    character(len=2), intent(in) :: misfit_type
    logical, intent(in) :: compute_adjoint
    real(kind=CUSTOM_REAL) :: cc_max_syn,cc_max_obs
    integer, intent(out) :: num
    real(kind=CUSTOM_REAL), dimension(*),intent(out),optional :: adj1,adj2

    ! index
    integer :: i,j

    ! window
    integer :: nlen1,nlen2,nlen
    real(kind=CUSTOM_REAL), dimension(npts) :: d1_tw,d2_tw,s1_tw,s2_tw
    ! cc 
    integer :: ishift_obs,ishift_syn
    real(kind=CUSTOM_REAL) :: tshift_obs,tshift_syn
    real(kind=CUSTOM_REAL) :: dlnA_obs,dlnA_syn
    real(kind=CUSTOM_REAL) :: ddtshift_cc,ddlnA_cc
    real(kind=CUSTOM_REAL) :: err_dt_cc_obs=1.0,err_dt_cc_syn=1.0
    real(kind=CUSTOM_REAL) :: err_dlnA_cc_obs=1.0,err_dlnA_cc_syn=1.0
    real(kind=CUSTOM_REAL), dimension(npts) :: d2_tw_cc,s2_tw_cc

    ! FFT parameters
    real(kind=CUSTOM_REAL), dimension(NPT) :: wvec,fvec
    real(kind=CUSTOM_REAL) :: df,df_new,dw

    ! mt 
    integer :: i_fstart1, i_fend1,i_fstart2, i_fend2,i_fstart, i_fend
    !  real(kind=CUSTOM_REAL), dimension(NPT) :: eigens, ey2
    !  real(kind=CUSTOM_REAL), dimension(:,:),allocatable :: tas
    real(kind=CUSTOM_REAL), dimension(NPT) :: dtau_w_obs,dtau_w_syn
    real(kind=CUSTOM_REAL), dimension(NPT) :: dlnA_w_obs, dlnA_w_syn
    real(kind=CUSTOM_REAL), dimension(NPT) :: ddtau_w, ddlnA_w
    real(kind=CUSTOM_REAL), dimension(NPT) :: err_dtau_mt_obs,err_dtau_mt_syn
    real(kind=CUSTOM_REAL), dimension(NPT) :: err_dlnA_mt_obs, err_dlnA_mt_syn
    complex*16, dimension(NPT) :: trans_func_obs,trans_func_syn
    ! variance 
    !real(kind=CUSTOM_REAL), dimension(NPT) :: var_trans_obs, var_trans_syn

    ! adjoint
    real(kind=CUSTOM_REAL), dimension(npts) :: fp1_tw,fp2_tw,fq1_tw,fq2_tw

    !! window
    call cc_window(d1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,d1_tw)
    call cc_window(s1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,s1_tw)
    call cc_window(d2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,d2_tw)
    call cc_window(s2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,s2_tw)
    if(nlen1<1 .or. nlen1>npts) print*,'check nlen1 ',nlen1
    if(nlen2<1 .or. nlen2>npts) print*,'check nlen2 ',nlen2
    nlen =max(nlen1,nlen2)

    !! cc correction
    call xcorr_calc(d1_tw,d2_tw,npts,1,nlen,ishift_obs,dlnA_obs,cc_max_obs)
    tshift_obs= ishift_obs*deltat 
    call xcorr_calc(s1_tw,s2_tw,npts,1,nlen,ishift_syn,dlnA_syn,cc_max_syn) 
    tshift_syn= ishift_syn*deltat
    !! double-difference cc-measurement 
    ddtshift_cc = tshift_syn - tshift_obs
    ddlnA_cc = dlnA_syn - dlnA_obs

    if(USE_ERROR_CC) then
        !! cc_error 
        call cc_error(d1_tw,d2_tw,npts,deltat,nlen,ishift_obs,dlnA_obs,err_dt_cc_obs,err_dlnA_cc_obs)
        call cc_error(s1_tw,s2_tw,npts,deltat,nlen,ishift_syn,dlnA_syn,err_dt_cc_syn,err_dlnA_cc_syn)
    endif

    ! correction for d2 using positive cc
    ! fixed window for d1, correct the window for d2
    dlnA_obs = 0.0
    dlnA_syn = 0.0
    call cc_window(d2,npts,window_type,i_tstart2,i_tend2,ishift_obs,dlnA_obs,nlen2,d2_tw_cc)
    call cc_window(s2,npts,window_type,i_tstart2,i_tend2,ishift_syn,dlnA_syn,nlen2,s2_tw_cc)
    if( DISPLAY_DETAILS) then
        print*
        print*, 'time-domain winodw'
        print*, 'time window boundaries for d1/s1: ',i_tstart1,i_tend1
        print*, 'time window length for d1/s1 : ', nlen1
        print*, 'time window boundaries for d2/s2: ',i_tstart2,i_tend2
        print*, 'time window length for d2/s2 : ', nlen2
        print*, 'combined window length nlen = ',nlen
        print*, 'cc ishift/tshift/dlnA of (d1-d2): ', ishift_obs,tshift_obs,dlnA_obs
        print*, 'cc ishift/tshift/dlnA of (s1-s2): ', ishift_syn,tshift_syn,dlnA_syn
        print*, 'cc double-difference ddtshift/ddlnA of (s1-s2)-(d1-d2): ' &
            ,ddtshift_cc, ddlnA_cc
        print* 
        open(1,file=trim(output_dir)//'/dat_datcc',status='unknown')
        open(2,file=trim(output_dir)//'/syn_syncc',status='unknown')
        do  i = 1,nlen
        write(1,'(I5,3e15.5)') i, d1_tw(i),d2_tw(i),d2_tw_cc(i)
        write(2,'(I5,3e15.5)') i, s1_tw(i),s2_tw(i),s2_tw_cc(i)
        enddo
        close(1)
        close(2)
    endif

    !! DD multitaper-misfit

    !-----------------------------------------------------------------------------
    !  set up FFT for the frequency domain
    !----------------------------------------------------------------------------- 
    df = 1./(NPT*deltat)
    dw = TWOPI * df
    ! calculate frequency spacing of sampling points
    df_new = 1.0 / (nlen*deltat)
    ! assemble omega vector (NPT is the FFT length)
    wvec(:) = 0.
    do j = 1,NPT
    if(j > NPT/2+1) then
        wvec(j) = dw*(j-NPT-1)   ! negative frequencies in second half
    else
        wvec(j) = dw*(j-1)       ! positive frequencies in first half
    endif
    enddo
    fvec = wvec / TWOPI

    !!   find the relaible frequency limit
    call frequency_limit(s1_tw,nlen,deltat,i_fstart1,i_fend1)
    call frequency_limit(s2_tw,nlen,deltat,i_fstart2,i_fend2)
    i_fend = min(i_fend1,i_fend2,floor(1.0/(2*deltat)/df)+1,floor(f0*2.5/df)+1)
    i_fstart = max(i_fstart1,i_fstart2, ceiling(3.0/(nlen*deltat)/df)+1,ceiling(f0/2.5/df)+1)

    if( DISPLAY_DETAILS) then
        print*,  'df/dw/df_new :', df,dw,df_new  
        print*
        print*, 'find the spectral boundaries for reliable measurement'
        print*, 'min, max frequency limit for 1 : ', fvec(i_fstart2),fvec(i_fend1)
        print*, 'min, max frequency limit for 2 : ', fvec(i_fstart2),fvec(i_fend2)
        print*, 'effective bandwidth (Hz) : ',fvec(i_fstart),fvec(i_fend),fvec(i_fend)-fvec(i_fstart)
        print*, 'half time-bandwidth product : ', NW
        print*, 'number of tapers : ',ntaper
        print*, 'resolution of multitaper (Hz) : ', NW/(nlen*deltat)
        print*, 'number of segments of frequency bandwidth : ', ceiling((fvec(i_fend)-fvec(i_fstart))/(NW/(nlen*deltat)))
        print*
    endif

    !! mt phase and ampplitude measurement 
    call mt_measure(d1_tw,d2_tw_cc,npts,deltat,nlen,tshift_obs,dlnA_obs,i_fstart,i_fend,&
        wvec,&
        !mtaper,NW,&
    trans_func_obs,dtau_w_obs,dlnA_w_obs,err_dtau_mt_obs,err_dlnA_mt_obs)
    call mt_measure(s1_tw,s2_tw_cc,npts,deltat,nlen,tshift_syn,dlnA_syn,i_fstart,i_fend,&
        wvec,&
        !mtaper,NW,&
    trans_func_syn,dtau_w_syn,dlnA_w_syn,err_dtau_mt_syn,err_dlnA_mt_syn)
    ! double-difference measurement 
    ddtau_w = dtau_w_syn-dtau_w_obs
    ddlnA_w = dlnA_w_syn-dlnA_w_obs
    ! MT misfit
    !misfit_output = sqrt(sum((ddtau_w(i_fstart:i_fend))**2*dw)) * cc_max_obs
    if(misfit_type=='MT') then
        ! MT misfit
        do i=i_fstart,i_fend
        write(IOUT,*) ddtau_w(i)*sqrt(dw)
        enddo
    elseif(misfit_type=='MA') then
        ! MA misfit
        do i=i_fstart,i_fend
        write(IOUT,*) ddlnA_w(i)*sqrt(dw)
        enddo
    endif
    num=i_fend-i_fstart+1

    if(DISPLAY_DETAILS) then
        !! write into file 
        open(1,file=trim(output_dir)//'/trans_func_obs',status='unknown')
        open(2,file=trim(output_dir)//'/trans_func_syn',status='unknown')
        open(3,file=trim(output_dir)//'/ddtau_mtm',status='unknown')
        open(4,file=trim(output_dir)//'/ddlnA_mtm',status='unknown')
        open(5,file=trim(output_dir)//'/err_dtau_dlnA_mtm',status='unknown')
        do  i = i_fstart,i_fend
        write(1,'(f15.5,e15.5)') fvec(i),abs(trans_func_obs(i))
        write(2,'(f15.5,e15.5)') fvec(i),abs(trans_func_syn(i))
        write(3,'(f15.5,2e15.5)') fvec(i),ddtau_w(i),ddtshift_cc
        write(4,'(f15.5,2e15.5)') fvec(i),ddlnA_w(i),ddlnA_cc
        write(5,'(f15.5,2e15.5)') fvec(i),err_dtau_mt_obs(i)*err_dtau_mt_syn(i), &
            err_dlnA_mt_obs(i)*err_dlnA_mt_syn(i)
        enddo
        close(1)
        close(2)
        close(3)
        close(4)
        close(5)
    endif

    !!DD cc-adjoint
    if(COMPUTE_ADJOINT) then
        ! initialization 
        adj1(1:npts) = 0.0
        adj2(1:npts) = 0.0

        call mtm_DD_adj(s1_tw,s2_tw_cc,NPTS,deltat,nlen,df,i_fstart,i_fend,ddtau_w,ddlnA_w,&
            err_dt_cc_obs,err_dt_cc_syn,err_dlnA_cc_obs,err_dlnA_cc_syn, &
            err_dtau_mt_obs,err_dtau_mt_syn,err_dlnA_mt_obs,err_dlnA_mt_syn, &
            !ntaper,NW,&
        fp1_tw,fp2_tw,fq1_tw,fq2_tw)
        ! adjoint source
        fp1_tw(1:nlen)= fp1_tw(1:nlen) * cc_max_obs *cc_max_obs
        fp2_tw(1:nlen)= fp2_tw(1:nlen) * cc_max_obs *cc_max_obs
        fq1_tw(1:nlen)= fq1_tw(1:nlen) * cc_max_obs *cc_max_obs
        fq2_tw(1:nlen)= fq2_tw(1:nlen) * cc_max_obs *cc_max_obs

        ! reverse window and taper again 
        if(misfit_type=='MT') then
        call cc_window_inverse(fp1_tw,npts,window_type,i_tstart1,i_tend1,0,0.d0,adj1)
        call cc_window_inverse(fp2_tw,npts,window_type,i_tstart2,i_tend2,ishift_syn,0.d0,adj2)
        elseif(misfit_type=='MA') then
        call cc_window_inverse(fq1_tw,npts,window_type,i_tstart1,i_tend1,0,0.d0,adj1)
        call cc_window_inverse(fq2_tw,npts,window_type,i_tstart2,i_tend2,ishift_syn,0.d0,adj2)
        endif

        if( DISPLAY_DETAILS) then
            open(1,file=trim(output_dir)//'/adj_win',status='unknown')
            open(2,file=trim(output_dir)//'/adj_ref_win',status='unknown')
            do  i =  i_tstart1,i_tend1
            write(1,*) i,adj1(i)
            enddo
            do  i =  i_tstart2,i_tend2
            write(2,*) i,adj2(i)
            enddo
            close(1)
            close(2)
        endif

    endif ! compute_adjoint 

    !  deallocate(tas)

end subroutine MT_misfit_DD
!-----------------------------------------------------------------------
