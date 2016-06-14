      subroutine RHS(uvec,resI,resE,dt,ep,iprob,sigma,rho,beta)

      implicit none

      integer,   parameter                            :: wp=8

      integer,   parameter                            :: is=9
      integer,   parameter                            :: ivarlen=4

      real(wp),                        intent(in   )  :: sigma
      real(wp),                        intent(in   )  :: rho
      real(wp),                        intent(in   )  :: beta

      real(wp),  dimension(ivarlen),    intent(in   ) :: uvec
      real(wp),  dimension(ivarlen),    intent(  out) :: resE,resI
      real(wp),                        intent(in   )  :: dt
      real(wp),                        intent(in   )  :: ep
      integer,                         intent(in   )  :: iprob

      
      if    (iprob.eq.1)then
        resE(1) = dt*uvec(2)
        resE(2) = 0.0_wp
        resI(1) = 0.0_wp
        resI(2) = dt*((1-uvec(1)*uvec(1))*uvec(2) - uvec(1))/ep
      elseif(iprob.eq.2)then
        resI(1) = dt*(-uvec(2))
        resI(2) = dt*( uvec(1) + (sin(uvec(1)) - uvec(2))/ep)
      elseif(iprob.eq.3)then
        resI(1) = dt*(-(1./ep+2.)*uvec(1) + (1./ep)*uvec(2)*uvec(2))
        resI(2) = dt*(uvec(1) - uvec(2) - uvec(2)*uvec(2) )
      elseif(iprob.eq.4)then
        resI(1) = dt*(uvec(1) + uvec(2)/ep)
        resI(2) = dt*(        - uvec(2))
      elseif(iprob.eq.5)then
        resI(1)=dt*sigma*(uvec(2)-uvec(1))/ep
        resI(2)=dt*(-uvec(1)*uvec(3)+rho*uvec(1)-uvec(2))
        resI(3)=dt*(uvec(1)*uvec(2)-beta*uvec(3))
      endif

      return
      end
