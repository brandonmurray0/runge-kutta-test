      subroutine INIT(uvec,uexact,dt,iDT,tfinal,ep,nvecLen,iprob,sigma,rho,beta)

      implicit none

      integer,  parameter                           :: wp=8

      integer,  parameter                           :: is=9
      integer,  parameter                           :: ivarlen=4
 
      real(wp),  dimension(ivarlen),         intent(  out) :: uvec
      real(wp),  dimension(ivarlen),         intent(  out) :: uexact
      real(wp),                              intent(  out) :: dt
      integer,                               intent(in   ) :: iDT
      real(wp),                              intent(  out) :: tfinal
      real(wp),                              intent(in   ) :: ep
      integer,                               intent(  out) :: nveclen
      integer,                               intent(in   ) :: iprob
      real(wp),                              intent(  out) :: sigma
      real(wp),                              intent(  out) :: rho
      real(wp),                              intent(  out) :: beta

      real(wp),  dimension(81,ivarlen)                     :: ExactTot
      real(wp)                                             :: pi,diff,uo,vo
      real(wp)                                             :: tmpm,tmp,tmpP
      integer                                              :: i

        if(iprob.eq.1)then                 !  van der Pol (Hairer II  pp 403)
!    vanderPol has 8 decades with 10 levels of epsilon per decade plus 1st pt of 9th decade
 
         open(unit=39,file='exact.vanderpol.data')

          rewind(39)
          do i=1,81
            read(39,*)ExactTot(i,1),ExactTot(i,2)
            ExactTot(i,3) = 1.0_wp/10**((i-1)/(10.0_wp))                  !  used for 81 values of ep
          enddo

          do i=1,81
            diff = abs(ExactTot(i,3) - ep)
            if(diff.le.1.0e-10_wp)then
              uexact(1) = ExactTot(i,1)
              uexact(2) = ExactTot(i,2)
              go to 1 
            endif
          enddo
   1      continue

          dt = 0.5_wp/10**((iDT-1)/20.0_wp)
          nvecLen = 2
          tfinal = 0.5_wp

          uvec(1) = 2.0_wp
          uvec(2) = -0.6666654321121172_wp

        elseif(iprob.eq.2)then                     !  Pureshi and Russo 
 
          open(unit=39,file='exact.pureschi.1.data')
!         open(unit=39,file='exact.pureschi.2.data')


          rewind(39)
          do i=1,81
            read(39,*)ExactTot(i,1),ExactTot(i,2)
            ExactTot(i,3) = 1.0_wp/10**((i-1)/(10.0_wp))                  !  used for 81 values of ep
          enddo

          do i=1,81
            diff = abs(ExactTot(i,3) - ep)
            if(diff.le.1.0e-10_wp)then
              uexact(1) = ExactTot(i,1)
              uexact(2) = ExactTot(i,2)
              go to 2
            endif
          enddo
   2      continue

          dt = 0.5_wp/10**((iDT-1)/20._wp)
          nvecLen = 2
          tfinal = 5.0_wp

          pi = acos(-1.0_wp)

!  IC: problem 1   :  equilibrium IC
          uvec(1) = pi/2.0_wp
          uvec(2) = sin(pi/2.0_wp)
!  IC: problem 2   :  non-equilibrium IC
!         uvec(1) = pi/2.
!         uvec(2) = 1./2.

        elseif(iprob.eq.3)then                   ! Dekker 7.5.2 pp. 215 (Kaps problem   : Index 1)
 
          dt = 0.5_wp/10**((iDT-1)/20.0_wp)
          nvecLen = 2

          tfinal = 1.0_wp
          tmp = exp(-tfinal)
          uexact(1) = tmp*tmp
          uexact(2) = tmp

!  IC: problem 1   :  equilibrium IC
          uvec(1) = 1.0_wp
          uvec(2) = 1.0_wp
!  IC: problem 2   :  non-equilibrium IC
!         uvec(1) = ?
!         uvec(2) = ?

        elseif(iprob.eq.4)then          ! Dekker 7.5.1 pp. 214 (Kreiss' problem: Index 2)
 
          dt = 0.25_wp/10**((iDT-1)/20.0_wp)
          nvecLen = 2

          tfinal = 1.0_wp
          tmpP = exp(+tfinal   )
          tmpM = exp(-tfinal/ep)
          tmp = exp(tfinal)
          uo = 1.0_wp
          vo = 1.0_wp
          uexact(1) = uo*tmpP + vo*(tmpP - tmpM)/(1.0_wp + ep)
          uexact(2) = vo*tmpM

!  IC: problem 1   :  equilibrium IC
          uvec(1) = uo
          uvec(2) = vo
!  IC: problem 2   :  non-equilibrium IC
!         uvec(1) = ?
!         uvec(2) = ?

        elseif(iprob.eq.5)then                 !Lorenz
          sigma=10.0_wp
          rho=28.0_wp
          beta=8.0_wp/3.0_wp

          dt = 0.5_wp/10**((iDT-1)/20.0_wp)
          nveclen = 3 

          tfinal = 1.0_wp !!arbitrary

          open(unit=39,file='exact.lorenz.data')

          rewind(39)
          do i=1,81
            read(39,*)ExactTot(i,1),ExactTot(i,2),ExactTot(i,3)
            ExactTot(i,4) = 1.0_wp/10**((i-1)/(10.0_wp))                  !  used for 81 values of ep
          enddo

          do i=1,81
            diff = abs(ExactTot(i,4) - ep)
            if(diff.le.1.0e-10_wp)then
              uexact(1) = ExactTot(i,1)
              uexact(2) = ExactTot(i,2)
              uexact(3) = ExactTot(i,3)
              go to 5 
            endif
          enddo
   5      continue

!  IC: problem 1 : Lorenz(1963)
          uvec(1) = 0.0_wp
          uvec(2) = 1.0_wp
          uvec(3) = 0.0_wp

        endif

      return
      end
