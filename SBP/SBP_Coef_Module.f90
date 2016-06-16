      module SBP_Coef_Module

      implicit none

      integer,   parameter                      :: wp = 8

      private
      public  ::  D1_242

      contains

      subroutine D1_242(n,nnz,ia,ja,a,Pmat,Pinv)

      implicit none

      integer,                    intent(in   ) :: n,nnz

      integer,   dimension(n+1),  intent(  out) :: ia
      integer,   dimension(nnz),  intent(  out) :: ja

      real(wp),  dimension(nnz),  intent(  out) ::  a
      real(wp),  dimension(n  ),  intent(  out) ::  Pmat, Pinv

      integer                                   :: i,j,k
      integer                                   :: icnt, jcnt
      real(wp)                                  :: h, tnorm
      real(wp),  allocatable, dimension(:)      :: d1mat
      real(wp),  allocatable, dimension(:,:)    :: D1blk, D2blk, D1blkT
      real(wp),  parameter                      :: tol=1.0e-12_wp
      real(wp),  allocatable, dimension(:)      :: err, x0_vec, x1_vec, x2_vec, x3_vec
      real(wp),  allocatable, dimension(:)      ::     dx0_vec,dx1_vec,dx2_vec,dx3_vec
      real(wp),  allocatable, dimension(:)      ::     dx0T_vec,dx1T_vec,dx2T_vec,dx3T_vec

      continue

      if(n < 8) then 
        write(*,*)'Dimension not large enough to support D242: stopping'
        stop
      endif
      allocate(d1mat(1:5))
      allocate(D1blk(1:4,1:6))
      allocate(D2blk(1:4,1:6))
      allocate(D1blkT(1:6,1:4))

      h = 1.0_wp / (n - 1)

      Pmat(1:  4) = reshape(                              &
                  & (/17.0_wp/48.0_wp, 59.0_wp/48.0_wp,   &
                  &   43.0_wp/48.0_wp, 49.0_wp/48.0_wp /),&
                  & (/4/)  )
      Pmat(5:n-4) = 1.0_wp
      Pmat(n-3:n) = reshape(                              &
                    (/49.0_wp/48.0_wp, 43.0_wp/48.0_wp,   &
                      59.0_wp/48.0_wp, 17.0_wp/48.0_wp /),&
                  & (/4/)  )

      Pinv(:) = 1.0_wp / Pmat(:)

      d1mat(:) = reshape(                                               &
              & (/ 1.0_wp/12,-8.0_wp/12,0.0_wp,8.0_wp/12,-1.0_wp/12 /),&
              & (/5/))

      D1blkT  = reshape(                                                                 &
              & (/-24.0_wp/17.0_wp, 59.0_wp/34.0_wp, -4.0_wp/17.0_wp,-3.0_wp/34.0_wp, 0.0_wp        , 0.0_wp,          &
              &    -1.0_wp/ 2.0_wp,  0.0_wp        ,  1.0_wp/2.0_wp , 0.0_wp        , 0.0_wp        , 0.0_wp,          &
              &     4.0_wp/43.0_wp,-59.0_wp/86.0_wp,  0.0_wp        ,59.0_wp/86.0_wp,-4.0_wp/43.0_wp, 0.0_wp,          &
              &     3.0_wp/98.0_wp,  0.0_wp        ,-59.0_wp/98.0_wp, 0.0_wp        ,32.0_wp/49.0_wp,-4.0_wp/49.0_wp/),&
              & (/6,4/)  )
      D1blk = Transpose(D1blkT)

      do i=1,4
         do j=1,6
           D2blk(i,j)= - D1blk(5-i,7-j)
         end do
      end do

      call CSR_Filler(n,nnz,d1mat,D1blk,D2blk, ia,ja,a)

      allocate(  x0_vec(n),  x1_vec(n),  x2_vec(n),  x3_vec(n))
      allocate( dx0_vec(n), dx1_vec(n), dx2_vec(n), dx3_vec(n))
      allocate(dx0T_vec(n),dx1T_vec(n),dx2T_vec(n),dx3T_vec(n))
      allocate(err(n))
      do i = 1,n
        x0_vec(i) = 1.0_wp        ;  dx0_vec(i) = 0.0_wp
        x1_vec(i) = 1.0_wp*i      ;  dx1_vec(i) = 1.0_wp
        x2_vec(i) = 1.0_wp*i*i    ;  dx2_vec(i) = 2.0_wp*i
        x3_vec(i) = 1.0_wp*i*i*i  ;  dx3_vec(i) = 3.0_wp*i*i
      enddo

      call amux_local (n, x0_vec,dx0T_vec, a,ja,ia)
      call amux_local (n, x1_vec,dx1T_vec, a,ja,ia)
      call amux_local (n, x2_vec,dx2T_vec, a,ja,ia)
      call amux_local (n, x3_vec,dx3T_vec, a,ja,ia)

      err(:) = dx0_vec(:) - dx0T_vec(:) &
             + dx1_vec(:) - dx1T_vec(:) &
             + dx2_vec(:) - dx2T_vec(:)!&
            !+ dx3_vec(:) - dx3T_vec(:)
      
      tnorm = maxval(err)
      write(*,*)'error in derivative',tnorm
      if(tnorm >= tol) write(*,*)'maxerr',maxval(err)


      deallocate(d1mat,D1blk,D2blk,D1blkT,err)

      return

      end subroutine D1_242

      subroutine D2_242(n,nnz,ia,ja,a,Pmat,Pinv)

      implicit none

      integer,   parameter                      :: wp = 8

      integer,                    intent(in   ) :: n,nnz

      integer,   dimension(n+1),  intent(  out) :: ia
      integer,   dimension(nnz),  intent(  out) :: ja

      real(wp),  dimension(nnz),  intent(  out) ::  a
      real(wp),  dimension(4  )                 ::  Pmat, Pinv

      integer                                   :: i,j,k
      integer                                   :: icnt, jcnt
      real(wp)                                  :: h, tnorm, m24
      real(wp),  allocatable, dimension(:)      :: d1vec, d2mat
      real(wp),  allocatable, dimension(:,:)    :: M1blk, M2blk, M1blkT1, M1blkT2
      real(wp),  allocatable, dimension(:,:)    :: D1blk, D2blk
      real(wp),  parameter                      :: tol=1.0e-12_wp
      real(wp),  allocatable, dimension(:)      :: err, x0_vec, x1_vec, x2_vec
      real(wp),  allocatable, dimension(:)      ::     dx0_vec,dx1_vec,dx2_vec

      continue

      if(n < 8) then 
        write(*,*)'Dimension not large enough to support D242: stopping'
        stop
      endif
      allocate(d1vec(1:4))
      allocate(d2mat(1:5))
      allocate(M1blk(1:4,1:6),M2blk(1:4,1:6))
      allocate(M1blkT1(1:6,1:4),M1blkT2(1:6,1:4))
      allocate(D1blk(1:4,1:6),D2blk(1:4,1:6))

      h = 1.0_wp / (n - 1)

      Pmat(1:  4) = reshape(                              &
                  & (/17.0_wp/48.0_wp, 59.0_wp/48.0_wp,   &
                  &   43.0_wp/48.0_wp, 49.0_wp/48.0_wp /),&
                  & (/4/)  )

      Pinv(:) = 1.0_wp / Pmat(:)

      d1vec(:) = + reshape((/-24.0_wp/17.0_wp, 59.0_wp/34.0_wp,-4.0_wp/17.0_wp, -3.0_wp/34.0_wp                /),(/4/))
      d2mat(:) = - reshape((/  1.0_wp/12.0_wp,-16.0_wp/12.0_wp,30.0_wp/12.0_wp,-16.0_wp/12.0_wp,1.0_wp/12.0_wp /),(/5/))

      m24 = 16815244.0_wp/410099621.0_wp
      M1blkT1= reshape(                                                                                                &
              & (/  9.0_wp/ 8.0_wp,-59.0_wp/48.0_wp, +1.0_wp/12.0_wp, 1.0_wp/48.0_wp, 0.0_wp        , 0.0_wp,          &
              &   -59.0_wp/48.0_wp, 59.0_wp/24.0_wp,-59.0_wp/48.0_wp, 0.0_wp        , 0.0_wp        , 0.0_wp,          &
              &     1.0_wp/12.0_wp,-59.0_wp/48.0_wp, 55.0_wp/24.0_wp,59.0_wp/48.0_wp, 1.0_wp/12.0_wp, 0.0_wp,          &
              &     1.0_wp/48.0_wp,  0.0_wp        ,-59.0_wp/48.0_wp,59.0_wp/24.0_wp,-4.0_wp/ 3.0_wp, 1.0_wp/12.0_wp/),&
              & (/6,4/)  )
      M1blkT2= reshape(                                                                                         &
              & (/-1.0_wp/3.0_wp*m24,+1.0_wp/1.0_wp*m24,-1.0_wp/1.0_wp*m24,+1.0_wp/3.0_wp*m24, 0.0_wp, 0.0_wp,  &
              &   +1.0_wp/1.0_wp*m24,-3.0_wp/1.0_wp*m24,+3.0_wp/1.0_wp*m24,-1.0_wp/1.0_wp*m24, 0.0_wp, 0.0_wp,  &
              &   -1.0_wp/1.0_wp*m24,+3.0_wp/1.0_wp*m24,-3.0_wp/1.0_wp*m24,+1.0_wp/1.0_wp*m24, 0.0_wp, 0.0_wp,  &
              &   +1.0_wp/3.0_wp*m24,-1.0_wp/1.0_wp*m24,+1.0_wp/1.0_wp*m24,-1.0_wp/3.0_wp*m24, 0.0_wp, 0.0_wp/),&
              & (/6,4/)  )
      M1blk = - Transpose(M1blkT1+M1blkT2)

      do i=1,4
         do j=1,6
           M2blk(i,j)= + M1blk(5-i,7-j)
         end do
      end do

      do j = 1,4
        D1blk(1,j) = Pinv(  j)*(M1blk(1,  j) - d1vec(j))
        D2blk(4,:) = Pinv(5-j)*(M2blk(4,7-j) + d1vec(j))
      enddo

      call CSR_Filler(n,nnz,d2mat,D1blk,D2blk, ia,ja,a)

      end subroutine D2_242

! ======================================================================================

      subroutine CSR_Filler(n,nnz,dmat,D1blk,D2blk, ia,ja,a)

      !  Store the Derivative matrix in CSR format

      implicit none

      real(wp),  parameter                     :: tol=1.0e-12_wp

      integer,                   intent(in   ) :: n,nnz
      real(wp),  dimension(:),   intent(in   ) :: dmat
      real(wp),  dimension(:,:), intent(in   ) :: D1blk,D2blk

      integer,   dimension(:),   intent(  out) :: ia
      integer,   dimension(:),   intent(  out) :: ja
      real(wp),  dimension(:),   intent(  out) ::  a

      integer                                  :: i,j,k
      integer                                  :: icnt, jcnt
      real(wp),  allocatable, dimension(:)     :: err

      continue

      icnt  = 0      ; jcnt = 0 

      ia(:) = 0      ; ja(:) = 0      ;
       a(:) = 0.0_wp ;
      ia(1) = 1      ! start at beginning of array

      !  load derivative matrix info into CSR buckets:  Left block boundary

      do i = 1,4
        jcnt = 0 
        do j = 1,6
          if(abs(D1blk(i,j)) >= tol) then
              icnt = icnt + 1 ; jcnt = jcnt + 1 ;
          ja(icnt) = j
           a(icnt) = D1blk(i,j)
          endif
        enddo
        ia(i+1) = ia(i) + jcnt
      enddo
  
      !  load derivative matrix info into CSR buckets:  interior
      do i = 5,n-4
        jcnt = 0 
        do j = 1,5
          if(abs(dmat(j)) >= tol) then
              icnt = icnt + 1 ; jcnt = jcnt + 1 ;
          ja(icnt) = n-6+j
           a(icnt) = dmat(j)
          endif
        enddo
        ia(i+1) = ia(i) + jcnt
      enddo
 
      do i = 1,4
         k = n-4+i
        jcnt = 0 
        do j = 1,6
          if(abs(D2blk(i,j)) >= tol) then
              icnt = icnt + 1 ; jcnt = jcnt + 1 ;
          ja(icnt) = n-6+j
           a(icnt) = D2blk(i,j)
          endif
        enddo
        ia(k+1) = ia(k) + jcnt
      enddo
      if(icnt /= nnz) then
        write(*,*)'dimension of nnz buckets is incorrect: stopping'
        stop
      endif

      end subroutine CSR_Filler

! ======================================================================================

      subroutine amux_local (n, x, y, a,ja,ia)

        implicit none

        real(wp)  x(*), y(*), a(*)
        integer n, ja(*), ia(*)

        !-----------------------------------------------------------------------
        !         A times a vector
        !----------------------------------------------------------------------- 
        ! multiplies a matrix by a vector using the dot product form
        ! Matrix A is stored in compressed sparse row storage.
        !
        ! on entry:
        !----------
        ! n     = row dimension of A
        ! x     = real array of length equal to the column dimension of
        !         the A matrix.
        ! a, ja,
        !    ia = input matrix in compressed sparse row format.
        !
        ! on return:
        !-----------
        ! y     = real array of length n, containing the product y=Ax
        !
        !-----------------------------------------------------------------------
        ! local variables
    
        real(wp) t
        integer i, k
    
        do i = 1,n
          t = 0.0_wp        !     compute the inner product of row i with vector x
          do k=ia(i), ia(i+1)-1
            t = t + a(k)*x(ja(k))
          enddo
          y(i) = t          !     store result in y(i) 
        enddo

      end subroutine amux_local


      end module SBP_Coef_Module