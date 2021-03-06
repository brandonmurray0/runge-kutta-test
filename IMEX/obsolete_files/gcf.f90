      SUBROUTINE gcf(gammcf,a,x,gln)

      implicit none
      
      integer,  parameter        ::  wp=8

      integer,    parameter      ::  itkax=100
      real(wp),   parameter      ::  eps=3.e-7
      real(wp),   parameter      ::  FPMIN=1e-30

      real(wp),   intent(  out)  ::  gammcf
      real(wp),   intent(in   )  ::  a,x
      real(wp),   intent(  out)  ::  gln

      integer                    ::  i
      real(wp)                   ::  an,b,c,d,del,h,gammln

!     USES gammln

      gln=gammln(a)
      b=x+1. -a 
      c=1. /FPMIN 
      d=1./b
      h=d
      do i=1, itkax 
      an=-i*(i-a)
      b=b+2.
      d=an*d+b
      if(abs(d).lt.FPMIN)d=FPMIN
      c=b+an/c
      if(abs(c).lt.FPMIN)c=FPMIN
      d=1./d
      del=d*c
      h=h*del
      if(abs(del-1.).lt.EPS)goto 1
      enddo
      pause 'a too large, ITMAX too small in gcf'
    1 gammcf=exp(-x+a*log(x)-gln)*h
      return
      end
