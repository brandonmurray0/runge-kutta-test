!-------------------------------------------------------------
      subroutine RHS(varlen,iprob,uvec,res,dt,               &
                    &  ep,sigma,rho,beta)

      implicit none 

      integer,    parameter           :: wp = 8 

      real(wp),                      intent(in   )  :: sigma
      real(wp),                      intent(in   )  :: rho
      real(wp),                      intent(in   )  :: beta

      integer,                       intent(in   )  :: varlen
      integer,                       intent(in   )  :: iprob
      real(wp),                      intent(in   )  :: dt,ep
      real(wp),   dimension(varlen), intent(in   )  :: uvec

      real(wp),   dimension(varlen), intent(  out)  :: res

      if    (iprob == 1)then
        res(1) = dt*uvec(2)
        res(2) = dt*((1.0_wp-uvec(1)*uvec(1))*uvec(2) - uvec(1))/ep
      elseif(iprob == 2)then
        res(1) = dt*(-uvec(2))
        res(2) = dt*( uvec(1) + (sin(uvec(1)) - uvec(2))/ep)
      elseif(iprob == 3)then
        res(1) = dt*(-(1.0_wp/ep+2.0_wp)*uvec(1) + (1.0_wp/ep)*uvec(2)*uvec(2))
        res(2) = dt*(uvec(1) - uvec(2) - uvec(2)*uvec(2) )
      elseif(iprob == 4)then
        res(1) = dt*(uvec(1) + uvec(2)/ep)
        res(2) = dt*(        - uvec(2)/ep)
      elseif(iprob == 5)then
        res(1) = dt*sigma*(uvec(2)-uvec(1))/ep
        res(2) = dt*(-uvec(1)*uvec(3)+rho*uvec(1)-uvec(2))
        res(3) = dt*(+uvec(1)*uvec(2)-beta*uvec(3))
      endif

      return
      end
