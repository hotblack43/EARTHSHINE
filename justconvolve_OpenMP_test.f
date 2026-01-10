      program justconvolve_scwc
      use omp_lib
      implicit none
      include 'fftw3.f'
c     include 'omp_lib'  ! OpenMP support

      integer nx, ny, nxb, nyb, N
      parameter (nx=512, ny=512)
      parameter (nxb=3*512, nyb=3*512)

      character*250 infile, outfile, alphastr1, corfstr, rlimitstr
      double complex in1(nxb,nyb), in2(nxb,nyb)
      double complex out1(nxb,nyb), out2(nxb,nyb)
      integer*8 plan_backward, plan_forward, plan_forward2
      integer i, j, status
      real alpha1, normfac1, normfac2, corefac, rlimit
      real array2(nx,ny), brray(nxb,nyb), brray2(nxb,nyb)
      real c(0:4), r, rl, sum

      integer nthreads
      nthreads = 4  ! Set number of OpenMP threads (adjust based on your CPU)
      call omp_set_num_threads(nthreads)

* Get arguments from the command line
      if (iargc() .ne. 5) then
      write(6,*)'Usage: '
      write(6,*)'justconvolve_scwc inf outf alpha corefactor rlimit'
      write(6,*) 'e.g. justconvolve_scwc ide030.fits out.fits 1.8 2.0 9'
         call exit
      end if

      call getarg(1, infile)
      call getarg(2, outfile)
      call getarg(3, alphastr1)
      call getarg(4, corfstr)
      call getarg(5, rlimitstr)
      read(alphastr1,*) alpha1
      read(corfstr,*) corefac
      read(rlimitstr,*) rlimit

* Read the synthetic moon image
      call read_fits_2D_image(infile, array2, nx, ny, status)

* Move image into a larger buffer with padding
      brray = array2(1,1)  ! Fast initialization
      do i = 1, nx
         do j = 1, ny
            brray(i+nx,j+nx) = array2(i,j)
         end do
      end do

* Define PSF parameters
      c(0) = -0.3933615
      c(1) = -1.328291
      c(2) = -2.673426
      c(3) = -0.9203336
      c(4) = -1.601890

* Initialize sum for PSF normalization
      sum = 0.0
      normfac1 = 10.0**(c(3) + c(4)*log10(rlimit))

!$OMP PARALLEL DO PRIVATE(i, j, r, rl) REDUCTION(+:sum) SCHEDULE(DYNAMIC)
      do i = 1, nxb
         do j = 1, nyb
            r = sqrt((nxb/2.0 - i)**2 + (nyb/2.0 - j)**2)
            if (r.gt.0.1) then
               rl = log10(r)
               if (rl.lt.0.5) then
                  brray2(i,j) = 10.0**(c(0) + c(1)*rl + 
     &c(2)*rl**2 + c(3)*rl**3)
               else
                  brray2(i,j) = 10.0**(c(3) + c(4)*rl)
               end if
            else
               brray2(i,j) = 1.0
            end if
            if (r.le.rlimit) brray2(i,j) = brray2(i,j) * corefac
            if (r.gt.rlimit) brray2(i,j) = normfac1 * (brray2(i,j) 
     &/ normfac1)**alpha1
            sum = sum + brray2(i,j)
         end do
      end do
!$OMP END PARALLEL DO

* Normalize PSF
      brray2 = brray2 / (sum * nxb * nyb)

* FFT Plans with OpenMP support
      call dfftw_plan_dft_2d(plan_forward, nxb, nyb, in1, out1, 
     &FFTW_FORWARD, FFTW_MEASURE)
      call dfftw_plan_dft_2d(plan_forward2, nxb, nyb, in2, out2, 
     &FFTW_FORWARD, FFTW_MEASURE)
      call dfftw_plan_dft_2d(plan_backward, nxb, nyb, out1, in1, 
     &FFTW_BACKWARD, FFTW_MEASURE)

* Copy image & PSF to complex arrays
      in1 = brray
      in2 = brray2

* Forward FFT
      call dfftw_execute(plan_forward)
      call dfftw_execute(plan_forward2)

* Multiply in frequency domain
!$OMP PARALLEL DO PRIVATE(i, j) SCHEDULE(STATIC)
      do i = 1, nxb
         do j = 1, nyb
            out1(i,j) = out1(i,j) * out2(i,j)
         end do
      end do
!$OMP END PARALLEL DO

* Inverse FFT
      call dfftw_execute(plan_backward)

* Normalize the output
      brray = real(in1)

* Copy center back to output array
      do i = 1, nx
         do j = 1, ny
            array2(i,j) = brray(i+nx-1, j+nx-1)
         end do
      end do

* Write result to FITS
      call write_fits_2D_image(outfile, array2, nx, ny, status)

* Cleanup
      call dfftw_destroy_plan(plan_forward)
      call dfftw_destroy_plan(plan_forward2)
      call dfftw_destroy_plan(plan_backward)

      call exit
      end

