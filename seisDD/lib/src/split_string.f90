

subroutine split_string(instring,delimiter,outstring,nstring)

  use constants,only: MAX_STRING_LEN, MAX_KERNEL_NUM

  implicit none

  character(len=MAX_STRING_LEN),intent(in) :: instring
  character(len=MAX_STRING_LEN),intent(inout) :: outstring(MAX_KERNEL_NUM)
  integer,intent(out) :: nstring
  character,intent(in) :: delimiter 

  ! local parameters
  integer :: index,istring
  character(len=MAX_STRING_LEN) :: scan_string, remaining_string
!  character,parameter :: delimiter = ','


    ! intialization 
    scan_string = TRIM(instring)
    remaining_string=TRIM(instring)

    ! try 
    index = SCAN(scan_string,delimiter)
    istring=0
  !  print*,'scan string:',trim(scan_string)
  !  print*,'index=',index

    ! loop
    do while (len(trim(remaining_string))>0 .and. index>0)
  !  print*,'scan string:',trim(scan_string)
  !  print*,'index=',index

    istring=istring+1
    outstring(istring) = scan_string(1:index-1)
    remaining_string = scan_string(index+1:)
  !  print*,'split part:',trim(outstring(istring))
  !  print*,'remaining string:',trim(remaining_string)

  !  print*,'prepare for next split ...'
    scan_string = trim(remaining_string)
    index = SCAN(scan_string,delimiter)
    enddo

    nstring=istring+1
    ! the last string 
    outstring(nstring)= remaining_string

end subroutine split_string

