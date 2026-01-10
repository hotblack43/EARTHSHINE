      program justconvolve_scwc 
c Code to convolve an imput image with a PSF with alfa given by the user.
c This version scales the PSF outside some radius as well as the core
c
* g77 justconvolve_scwc.f -lcfitsio -lfftw3 -o justconvolve_scwc
c Peter likes:
c or ifort justconvolve_scwc.f -O3 -lcfitsio -lfftw3 -o justconvolve_scwc
* gfortran justconvolve_scwc.f -O3 -lfftw3 -L /home/thejll/Downloads/cfitsio/lib/ -lcfitsio -o justconvolve_scwc



      implicit none

      integer nx, ny, nxb, nyb, N
      parameter (nx=512, ny=512)
      parameter (nxb=3*512, nyb=3*512)
      
      character*250 alphastr1,corfstr,nframestr,dummystr
      character*250 rlimitstr
      character*250 infile, outfile, bigfile, psffile
      character*250 pedstr
      double complex in1(nxb,nyb),in2(nxb,nyb)
      double complex out1(nxb,nyb),out2(nxb,nyb)
      integer*8 plan_backward
      integer*8 plan_forward
      integer i,j,iframe,strlen
      integer narg, iarg
      integer seed
      integer status
      real normfac1,normfac2
      real alpha1
      real*8 rlimit,corefac
      real array4(nx,ny)
      real array(nx,ny),array2(nx,ny),array3(nx,ny)
      real brray(nxb,nyb),brray2(nxb,nyb),brray3(nxb,nyb)
      real c(0:4)
      real fac, r, rl, sum, t0, t1, tslide0, tslide1
      real gran, hslice(nx), nframe
      real t2, t3, t4, t5, sum1, sum2, zmax
      real value

      include 'fftw3.f'

* initialise seed in the Poisson generator
      seed = 1832723
      call zufalli(seed)

* get arguments from the command line

      narg = iargc()
      if (narg.ne.5) then
      write(6,*)'usage : '
      write(6,*)'justconvolve_scwc infil outfile alfa corefactor rlimit'
      write(6,*)'e.g. justconvolve_scwc ide030.fits out.fits 1.8 2.0 9'
        write(6,*)'to convolve with alfa=1.8 outside radius 9 (pixels).'
        write(6,*)'and scale core inside radius 9 with corefcator'
         call exit
      end if

      call getarg(1,infile)
      call getarg(2,outfile)
      call getarg(3,alphastr1)
      call getarg(4,corfstr)
      call getarg(5,rlimitstr)
      write(6,'(a)') infile
      write(6,'(a)') outfile
      write(dummystr,'(a)') alphastr1
      read(dummystr,*) alpha1
      write(dummystr,'(a)') corfstr
      read(dummystr,*) corefac
      write(dummystr,'(a)') rlimitstr
      read(dummystr,*) rlimit

c     write(6,*) 'Dimensions are ',nx, ny

* read the synthetic moon 
      call read_fits_2D_image(infile,array2,nx,ny,status)

* move into center of an array three times bigger
c setting it to the value found in the 1,1 corner of the original image
      value=0.0
      value=array2(1,1)
c     do i = 1, nxb
c        do j = 1, nyb
c           brray(i,j) = value
c        end do
c     end do
      brray = value
      do i = 1, nx
         do j = 1, ny
            brray(i+nx,j+nx) = array2(i,j)
         end do
      end do

* create the smoothing kernel

! fit to psfprofile.46.dat for log(r) < 0.5
      c(0) =  -0.3933615    ! +/-  3.7634037E-02
      c(1) =   -1.328291    ! +/-  0.2168711    
      c(2) =   -2.673426    ! +/-  0.6366262    
! fit for log(r) >= 0.5
      c(3) =  -0.9203336    ! +/-  1.3536011E-04
      c(4) =   -1.601890    ! +/-  6.9708112E-05

      sum = 0.0
c  radius of 'kink' in psf
c     rlimit=30.	
      normfac1=(10.0**(c(3) + c(4)*log10(rlimit)))
      do i = 1, nxb
         do j = 1, nyb
            r = sqrt((nxb/2.0-i)**2 + (nyb/2.0-j)**2)
            if (r.gt.0.1) then 
               rl = log10(r)
               if (rl.lt.0.5)
     >              fac = c(0) + c(1)*rl + c(2)*rl**2 + c(3)*rl**3
               if (rl.ge.0.5) 
     >              fac = c(3) + c(4)*rl
            else
               fac = 0.0
            end if
            brray2(i,j) = 10.0**fac 
          if (r.le.rlimit) brray2(i,j) = brray2(i,j)*corefac
          if (r.gt.rlimit) brray2(i,j) = 
     >             normfac1*(brray2(i,j)/normfac1)**alpha1
            sum = sum + brray2(i,j)
         end do
      end do

* and normalise the kernel
      do i = 1, nxb
        do j = 1, nyb
           brray2(i,j) = brray2(i,j)/sum/nxb/nyb 
c          brray2(i,j) = brray2(i,j)/sum/nx/ny 
       end do
      end do
      
      write(6,*) "PSF created"
      psffile="PSF_testing.fits"
      call write_fits_2D_image(psffile,brray2,nxb,nyb,status)
      write(6,*) "PSF saved"

      call timing(t0)

* copy input 2-d real array to double precision complex array
c     write(6,*) "Copying to complex array ",nx,ny
      do i = 1, nxb
         do j = 1, nyb
            in1(i,j) = brray(i,j)
            in2(i,j) = brray2(i,j)
         end do
      end do

      call timing(t1)

*  Make a plan for the FFT, and forward transform the data.
c     write(6,*) "Forward transforms"
      call dfftw_plan_dft_2d (plan_forward,nxb,nyb,in1,out1,
     &     FFTW_FORWARD, FFTW_ESTIMATE )
      call dfftw_execute (plan_forward)
      call dfftw_destroy_plan(plan_forward)

      call dfftw_plan_dft_2d (plan_forward,nxb,nyb,in2,out2,
     &     FFTW_FORWARD, FFTW_ESTIMATE )
      call dfftw_execute (plan_forward)
      call dfftw_destroy_plan(plan_forward)

      call timing(t2)

* multiply the two arrays together for the smooth
c     write(6,*) "Fourier convolution"
      do i = 1, nxb
         do j = 1, nyb
            out1(i,j) = out1(i,j)*out2(i,j)
         end do
      end do

      call timing(t3)

* transform the result backward
c     write(6,*) "Backward transforms"
      call dfftw_plan_dft_2d (plan_backward,nxb,nyb,out1,in1,
     &     FFTW_BACKWARD, FFTW_ESTIMATE )
      call dfftw_execute (plan_backward)
      call dfftw_destroy_plan(plan_backward)

      call timing(t4)

* copy output 2-d complex array to a real array
      do i = 1, nxb
         do j = 1, nyb
            brray3(i,j) = real(in1(i,j))
         end do
      end do

      call timing(t5)

      call timing(tslide0)

* slide quadrants to the correct places.
* slide upper right quad to lower left
      do i = 1, nxb/2
         do j = 1, nyb/2
            brray2(i,j) = brray3(nxb/2+i,nyb/2+j)
         end do
      end do
* slide upper left to lower right
      do i = nxb/2+1, nxb
         do j = 1, nyb/2
            brray2(i,j) = brray3(i-nxb/2,nyb/2+j)
         end do
      end do
* slide lower left to upper right
      do i = nxb/2+1, nxb
         do j = nyb/2+1, nyb
            brray2(i,j) = brray3(i-nxb/2,j-nyb/2)
         end do
      end do
* slide lower right to upper left
      do i = 1, nxb/2
         do j = nyb/2+1, nyb
            brray2(i,j) = brray3(nxb/2+i,j-nyb/2)
         end do
      end do

      call timing(tslide1)
c     write(6,*) 'Quadrant flip time in ms = ',(tslide1-tslide0)*1000.0

* move into center of an array three times smaller
      do i = 1, nx
         do j = 1, nx
            array2(i,j) = brray2(i+nx+1-2,j+nx+1-2)
         end do
      end do


c     write(6,*) 'copy to complex in ms = ',(t1-t0)*1000.0
c     write(6,*) 'forward FFTs in ms = ',(t2-t1)*1000.0
c     write(6,*) 'multiplication in ms = ',(t3-t2)*1000.0
c     write(6,*) 'backward FFT in ms = ',(t4-t3)*1000.0
c     write(6,*) 'CPU wall time in ms = ',(t5-t0)*1000.0

* write out the result as a fits file
      call write_fits_2D_image(outfile,array2,nx,ny,status)

      call exit

 999  write(6,*) "Error reading smoothing radius"

      end


* -------------------  subroutines ------------------------------

      subroutine timing(time)
      real time
      call system('date --rfc-3339=ns | cut -c18-29 > timing.temp')
      open(54,file='timing.temp',status='unknown')
      read(54,*) time
      close(54)
      return
      end

      subroutine gsmooth(array,array2,nx,ny)

      implicit none
      real array(nx,ny),array2(nx,ny),array3(nx,ny)
      integer nx, ny
      integer i,j
      double complex in1(nx,ny),in2(nx,ny)
      double complex out1(nx,ny),out2(nx,ny)
      integer*8 plan_backward
      integer*8 plan_forward

      include 'fftw3.f'

c     write(6,*) 'gsmooth'

* copy input 2-d real array to double precision complex array
c     write(6,*) "Copying to complex array ",nx,ny
      do i = 1, nx
         do j = 1, ny
            in1(i,j) = array(i,j)
            in2(i,j) = array2(i,j)
         end do
      end do

*  Make a plan for the FFT, and forward transform the data.
c     write(6,*) "Forward transforms"
      call dfftw_plan_dft_2d (plan_forward,nx,ny,in1,out1,
     &     FFTW_FORWARD, FFTW_ESTIMATE )
      call dfftw_execute (plan_forward)
      call dfftw_destroy_plan(plan_forward)

      call dfftw_plan_dft_2d (plan_forward,nx,ny,in2,out2,
     &     FFTW_FORWARD, FFTW_ESTIMATE )
      call dfftw_execute (plan_forward)
      call dfftw_destroy_plan(plan_forward)

* multiply the two arrays together for the smooth
c     write(6,*) "Fourier convolution"
      do i = 1, nx
         do j = 1, ny
            out1(i,j) = out1(i,j)*out2(i,j)
         end do
      end do

* transform the result backward
c     write(6,*) "Backward transforms"
      call dfftw_plan_dft_2d (plan_backward,nx,ny,out1,in1,
     &     FFTW_BACKWARD, FFTW_ESTIMATE )
      call dfftw_execute (plan_backward)
      call dfftw_destroy_plan(plan_backward)

* copy output 2-d complex array to a real array
      do i = 1, nx
         do j = 1, ny
            array3(i,j) = real(in1(i,j))
         end do
      end do

* slide quadrants to the correct places.
* slide upper right quad to lower left
      do i = 1, nx/2
         do j = 1, ny/2
            array2(i,j) = array3(nx/2+i,ny/2+j)
         end do
      end do
* slide upper left to lower right
      do i = nx/2+1, nx
         do j = 1, ny/2
            array2(i,j) = array3(i-nx/2,ny/2+j)
         end do
      end do
* slide lower left to upper right
      do i = nx/2+1, nx
         do j = ny/2+1, ny
            array2(i,j) = array3(i-nx/2,j-ny/2)
         end do
      end do
* slide lower right to upper left
      do i = 1, nx/2
         do j = ny/2+1, ny
            array2(i,j) = array3(nx/2+i,j-ny/2)
         end do
      end do

      return
      end


      integer function strlen(str)
      character*(*) str

      i = len(str)
      do while (str(i:i).eq.' ')
        i = i - 1
        if (i.eq.0) goto 10
      end do
      strlen = i
      return
 10   strlen = 0
      return
      end


c0000000000000000000000000000000000000000000000000000000000000000000000000000
      subroutine read_fits_2D_image(filename,array,nx,ny,status)

C     Read a FITS image -- assumed real, 2-D

      integer status,unit,readwrite,blocksize,naxes(3),nfound
      integer group,firstpix,npixels,strlen
      integer nullval
      logical anyf
      character filename*250
      real      array(nx,ny)

 1    status=0

C     Get an unused Logical Unit Number to use to open the FITS file
 2    call ftgiou(unit,status)

C     open the FITS file 
c     write(6,'(a,a)') ' Reading in ',filename(1:strlen(filename))
      readwrite=0
 3    call ftopen(unit,filename,readwrite,blocksize,status)
      if (status.ne.0) call print_fits_error(status)

C     determine the size of the image
 4    call ftgknj(unit,'NAXIS',1,2,naxes,nfound,status)

C     check that it found both NAXIS1 and NAXIS2 keywords
 5    if (nfound .ne. 2)then
          print *,'READIMAGE failed to read the NAXISn keywords.'
          return
       end if

C     initialize variables
      npixels=naxes(1)*naxes(2)
      group=1
      firstpix=1
      nullval=-999

      call ftg2de(unit,group,nullval,naxes(1),naxes(1),naxes(2),
     >     array,anyf,status)

C     close the file and free the unit number
 7    call ftclos(unit, status)
      call ftfiou(unit, status)

C     check for any error, and if so print out error messages
 8    if (status .gt. 0)call print_fits_error(status)
      end



c0000000000000000000000000000000000000000000000000000000000000000000000000000

      subroutine delete_fits_file(filename,status)

C     A simple little routine to delete a FITS file

      integer status,unit,blocksize
      character*(*) filename

C     simply return if status is greater than zero
      if (status .gt. 0)return

C     Get an unused Logical Unit Number to use to open the FITS file
 1    call ftgiou(unit,status)

C     try to open the file, to see if it exists
 2    call ftopen(unit,filename,1,blocksize,status)
c      if (status.ne.0) call print_fits_error(status)

      if (status .eq. 0)then
C         file was opened;  so now delete it 
 3        call ftdelt(unit,status)
      else if (status .eq. 103)then
C         file doesn't exist, so just reset status to zero and clear errors
          status=0
 4        call ftcmsg
      else
C         there was some other error opening the file; delete the file anyway
          status=0
 5        call ftcmsg
          call ftdelt(unit,status)
      end if

C     free the unit number for later reuse
 6    call ftfiou(unit, status)
      end

c0000000000000000000000000000000000000000000000000000000000000000000000000000

      subroutine print_fits_error(status)

C     Print out the FITSIO error messages to the user

      integer status
      character errtext*30,errmessage*250

C     check if status is OK (no error); if so, simply return
      if (status .le. 0)return

C     get the text string which describes the error
 1    call ftgerr(status,errtext)
      print *,'FITSIO Error Status =',status,': ',errtext

C     read and print out all the error messages on the FITSIO stack
 2    call ftgmsg(errmessage)
      do while (errmessage .ne. ' ')
          print *,errmessage
          call ftgmsg(errmessage)
      end do
      stop
      end

c0000000000000000000000000000000000000000000000000000000000000000000000000000
     
      subroutine size_fits_2D_image(filename,nx,ny,status)

C     get size of a FITS image -- assumed real, 2-D

      integer status,unit,readwrite,blocksize,naxes(3),nfound
      integer group,firstpix,npixels,strlen
      integer nullval
      logical anyf
      character filename*250

 1    status=0

C     Get an unused Logical Unit Number to use to open the FITS file
 2    call ftgiou(unit,status)

C     open the FITS file 
c     write(6,'(a,a)') ' Opening ',filename(1:strlen(filename))
      readwrite=0
 3    call ftopen(unit,filename,readwrite,blocksize,status)
      if (status.ne.0) call print_fits_error(status)

C     determine the size of the image
 4    call ftgknj(unit,'NAXIS',1,2,naxes,nfound,status)

C     check that it found both NAXIS1 and NAXIS2 keywords
 5    if (nfound .ne. 2)then
         print *,'READIMAGE failed to read the NAXISn keywords.'
         return
      end if
       
      nx = naxes(1)
      ny = naxes(2)

C     close the file and free the unit number
 7    call ftclos(unit, status)
      call ftfiou(unit, status)

C     check for any error, and if so print out error messages
 8    if (status .gt. 0)call print_fits_error(status)
      end

c0000000000000000000000000000000000000000000000000000000000000000000000000000


      real function sind(x)
      real x,pi
      pi = 3.1415927
      sind = sin(x*pi/180.0)
      return
      end

      real function cosd(x)
      real x,pi
      pi = 3.1415927
      cosd = cos(x*pi/180.0)
      return
      end



c0000000000000000000000000000000000000000000000000000000000000000000000000000
      subroutine write_fits_2D_image(filename,array,nx,ny,status)

C     Create a FITS a 2-D image

      integer status,unit,blocksize,bitpix,naxis,naxes(3)
      integer group,fpixel,strlen
      real    array(nx,ny)
      character filename*250
      logical simple,extend

 1    status=0

c      write(6,*) 'del old file'
C     Delete the file if it already exists, so we can then recreate it
 2    call delete_fits_file(filename,status)

c      write(6,*) ' get log unit'
C     Get an unused Logical Unit Number to use to open the FITS file
 3    call ftgiou(unit,status)

      write(6,*) strlen(filename)
      write(6,'(a,a250)') 'justconvolve_scwc is Writing out ',
     &filename(1:strlen(filename))

c      write(6,*) 'call ftinit for ',filename(1:30)
C     create the new empty FITS file
      blocksize=1
 4    call ftinit(unit,filename,blocksize,status)

      simple=.true.
      bitpix=-32
      naxis=2
      naxes(1)=nx
      naxes(2)=ny
      extend=.true.

c      write(6,*) ' write reqd header words'
C     write the required header keywords
 5    call ftphpr(unit,simple,bitpix,naxis,naxes,0,1,extend,status)

C     write the array to the FITS file
      group=1
      fpixel=nx
c      write(6,*) ' dump 2d array'
      call ftp2de(unit,group,fpixel,nx,ny,array,status)

c      write(6,*) ' close and deassign lus '
C     close the file and free the unit number
 8    call ftclos(unit, status)
      call ftfiou(unit, status)

c     check for any error, and if so print out error messages
 9    if (status .gt. 0)call print_fits_error(status)
c      write(6,*) 'status = ',status
      end


* -----------  other subroutines -----------------------------------------

      function rannum(xl,xu)
*     return uniformly distributed random number in [xl,xu]
      real*4    xu,xl,x
      integer seed /239243/

      

      x = ran0(seed)
      rannum = (xu-xl)*x+xl
      return
      end

      function gran(xm,xs)
* return gaussian distributed number with mean xm, sigma xs
      real*4    xm,xs
      data iset/0/
      save
      if (iset.eq.0) then
 1       v1 = rannum(-1.0,1.0)
         v2 = rannum(-1.0,1.0)
         r = v1**2+v2**2
         if (r.ge.1.0) goto 1
         fac = sqrt(-2.0*log(r)/r)
         gset = v1*fac
         gran = v2*fac
         iset = 1
      else
         gran = gset
         iset = 0
      end if
      gran = gran*xs+xm
      return
      end

      function ran0(idum)
      integer idum,ia,im,iq,ir,mask
      real ran0,am
      parameter (ia=16807,im=2147483647, am=1./im,
     >     iq=127773, ir=2836, mask=123459876)

*     numrec 2nd edition ran0 random number generator

      integer k
      idum = ieor(idum,mask)
      k = idum/iq
      idum = ia*(idum-k*iq) - ir*k
      if (idum.lt.0) idum = idum + im
      ran0 = am*idum
      idum = ieor(idum,mask)
      return
      end


*** -------------------------- subroutines ------------------------------

        subroutine least(n,x,y,iflag,sig,nxy,coeff,sd,iplot,bo)

* this calls a NUMREC routine to calculate an nth order polynomial fit
* weighted by the sig array (IN THE Y DIRECTION)
* the fit is done twice in x-y then y-x and averaged

        external    apoly
        character*5 str
        real        chi2,res,sd,sd2
        integer     mfit, nxy, n, lista(5), iflag(1)
        real        x(1), y(1), sig(1), coeff(5), covar(5,5)
        logical     bo

        if (nxy.lt.n+1) then
          write(6,'('' There are not enough data in the arrays'')')
          return
        end if

        if (n.eq.0) then
          ymean = 0.0
          ym2   = 0.0
          do i = 1, nxy
            ymean = ymean + y(i)
            ym2    = ym2 + y(i)**2
          end do
          ym2 = sqrt( (ym2 - ymean*ymean/nxy)/(nxy-1) )
          ymean = ymean/nxy
          write(6,*) 'mean  = ',ymean
          write(6,*) 'sigma = ',ym2
          mfit = 1
          coeff(1) = ymean
          goto 18
        end if

        mfit = n + 1
        do 5 i = 1, mfit
          lista(i) = i
 5      continue

        do i = 1, nxy
          sig(i) = 1.0
          if (iflag(i).eq.0) sig(i) = 100000.
        end do

        call lfit(x,y,sig,nxy,coeff,mfit,lista,
     >    mfit,covar,5,chi2,apoly)
        a1 = coeff(2)
        b1 = coeff(1)

* do the inverse fit and average the result

        if (bo) then
          write(6,*) 'Doing inverse fit'
          call lfit(y,x,sig,nxy,coeff,mfit,lista,
     >      mfit,covar,5,chi2,apoly)
          a2 = coeff(2)
          b2 = coeff(1)
          coeff(1) = (b1-b2/a2)/2.0
          coeff(2) = (a1+1.0/a2)/2.0
        end if

        do 15 i = 1, mfit
          str(1:5) = 'A( )='
          write(str(3:3),'(i1)') i-1
c          write(6,*) str,coeff(i)
 15     continue

        sd  = 0.0
        sd2 = 0.0
        ncnt = 0
        do 17 i = 1, nxy
          xpos = x(i)
          ypos = coeff(1)
          do 16 j = 2, mfit
            ypos = ypos + coeff(j)*xpos**(j-1)
 16       continue
          if (iflag(i).eq.1) then
            ncnt = ncnt + 1
            res = y(i) - ypos
            sd  = sd + res
            sd2 = sd2 + res*res
          end if
 17     end do
        if (ncnt.gt.1) then
          sd2 = sqrt( (sd2 - sd*sd/ncnt)/(ncnt-1) )
          write(6,*) 'standev = ',sd2,' for ',ncnt,' points'
          sd = sd2
        end if

        if (iplot.eq.0) return

 18     xl = x(1)
        xh = x(1)
        yl = y(1)
        yh = y(1)

        do 20 i = 1, nxy
          if (x(i).lt.xl) xl = x(i)
          if (x(i).gt.xh) xh = x(i)
          if (y(i).lt.yl) yl = y(i)
          if (y(i).gt.yh) yh = y(i)
 20     continue

        xl = xl-0.1*(xh-xl)
        xh = xh+0.1*(xh-xl)
        yl = yl-0.1*(yh-yl)
        yh = yh+0.1*(yh-yl)

        xpos = xl
        ypos = coeff(1)
        do 21 j = 2, mfit
          ypos = ypos + coeff(j)*xpos**(j-1)
 21     continue
c        call pgmove(xpos,ypos)

        do 30 i = 1, 200
          xpos = xl + i*(xh-xl)/200.0
          ypos = coeff(1)
          do 25 j = 2, mfit
            ypos = ypos + coeff(j)*xpos**(j-1)
 25       continue
          if (mfit.eq.0) ypos = coeff(1)
          if (ypos.lt.yh.and.ypos.gt.yl) then
c            call pgdraw(xpos,ypos)
          end if
c          call pgmove(xpos,ypos)

 30     continue

        return
        end


        subroutine apoly(x,afunc,na)
        real afunc(na)

        afunc(1) = 1.0
        do 10 i = 2, na
          afunc(i) = afunc(i-1)*x
 10     continue

        return
        end



        SUBROUTINE LFIT(X,Y,SIG,NDATA,A,MA,LISTA,MFIT,COVAR,NCVM,
     >  CHISQ,FUNCS)
        PARAMETER (MMAX=50)
        DIMENSION X(NDATA),Y(NDATA),SIG(NDATA),A(MA),LISTA(MA),
     *          COVAR(NCVM,NCVM),BETA(MMAX),AFUNC(MMAX)
        KK=MFIT+1
        DO J=1,MA
                IHIT=0
                DO K=1,MFIT
                        IF (LISTA(K).EQ.J) IHIT=IHIT+1
                ENDDO
                IF (IHIT.EQ.0) THEN
                        LISTA(KK)=J
                        KK=KK+1
                ELSE IF (IHIT.GT.1) THEN
c     PAUSE 'Improper set in LISTA'
                   write(6,*) 'Improper set in LISTA'
                   call exit 
                ENDIF
        ENDDO
        IF (KK.NE.(MA+1)) then
           write(6,*) 'Improper set in LISTA'
           call exit
        endif
        DO J=1,MFIT
                DO K=1,MFIT
                        COVAR(J,K)=0.
                ENDDO
                BETA(J)=0.
        ENDDO
        DO I=1,NDATA
                CALL FUNCS(X(I),AFUNC,MA)
                YM=Y(I)
                IF(MFIT.LT.MA) THEN
                        DO J=MFIT+1,MA
                                YM=YM-A(LISTA(J))*AFUNC(LISTA(J))
                        ENDDO
                ENDIF
                SIG2I=1./SIG(I)**2
                DO J=1,MFIT
                    WT=AFUNC(LISTA(J))*SIG2I
                    DO K=1,J
                      COVAR(J,K)=COVAR(J,K)+WT*AFUNC(LISTA(K))
                    ENDDO
                    BETA(J)=BETA(J)+YM*WT
                ENDDO
        ENDDO
        IF (MFIT.GT.1) THEN
                DO J=2,MFIT
                        DO K=1,J-1
                                COVAR(K,J)=COVAR(J,K)
                        ENDDO
                ENDDO
        ENDIF
        CALL GAUSSJ(COVAR,MFIT,NCVM,BETA,1,1)
        DO J=1,MFIT
                A(LISTA(J))=BETA(J)
        ENDDO
        CHISQ=0.
        DO I=1,NDATA
                CALL FUNCS(X(I),AFUNC,MA)
                SUM=0.
                DO J=1,MA
                        SUM=SUM+A(J)*AFUNC(J)
                ENDDO
                CHISQ=CHISQ+((Y(I)-SUM)/SIG(I))**2
        ENDDO
        CALL COVSRT(COVAR,NCVM,MA,LISTA,MFIT)
        RETURN
        END



        SUBROUTINE GAUSSJ(A,N,NP,B,M,MP)
        PARAMETER (NMAX=50)
        DIMENSION A(NP,NP),B(NP,MP),IPIV(NMAX),
     >    INDXR(NMAX),INDXC(NMAX)
        DO J=1,N
                IPIV(J)=0
        ENDDO
        DO I=1,N
              BIG=0.
              DO J=1,N
                    IF(IPIV(J).NE.1)THEN
                         DO K=1,N
                              IF (IPIV(K).EQ.0) THEN
                                      IF (ABS(A(J,K)).GE.BIG)THEN
                                              BIG=ABS(A(J,K))
                                              IROW=J
                                              ICOL=K
                                       ENDIF
                               ELSE IF (IPIV(K).GT.1) THEN
                                  write(6,*) 'Singular matrix'
                                  call exit
                               ENDIF
                         ENDDO
                    ENDIF
              ENDDO
                IPIV(ICOL)=IPIV(ICOL)+1
                IF (IROW.NE.ICOL) THEN
                        DO L=1,N
                                DUM=A(IROW,L)
                                A(IROW,L)=A(ICOL,L)
                                A(ICOL,L)=DUM
                        ENDDO
                        DO L=1,M
                                DUM=B(IROW,L)
                                B(IROW,L)=B(ICOL,L)
                                B(ICOL,L)=DUM
                        ENDDO
                ENDIF
                INDXR(I)=IROW
                INDXC(I)=ICOL
                IF (A(ICOL,ICOL).EQ.0.) then
                   write(6,*) 'Singular matrix.'
                   call exit
                endif
                PIVINV=1./A(ICOL,ICOL)
                A(ICOL,ICOL)=1.
                DO L=1,N
                        A(ICOL,L)=A(ICOL,L)*PIVINV
                ENDDO
                DO L=1,M
                        B(ICOL,L)=B(ICOL,L)*PIVINV
                ENDDO
                DO LL=1,N
                        IF(LL.NE.ICOL)THEN
                                DUM=A(LL,ICOL)
                                A(LL,ICOL)=0.
                                DO L=1,N
                                   A(LL,L)=A(LL,L)-A(ICOL,L)*DUM
                                ENDDO
                                DO L=1,M
                                   B(LL,L)=B(LL,L)-B(ICOL,L)*DUM
                                ENDDO
                        ENDIF
                ENDDO
        ENDDO
        DO L=N,1,-1
                IF(INDXR(L).NE.INDXC(L))THEN
                        DO K=1,N
                                DUM=A(K,INDXR(L))
                                A(K,INDXR(L))=A(K,INDXC(L))
                                A(K,INDXC(L))=DUM
                        ENDDO
                ENDIF
        ENDDO
        RETURN
        END


        SUBROUTINE COVSRT(COVAR,NCVM,MA,LISTA,MFIT)
        DIMENSION COVAR(NCVM,NCVM),LISTA(MFIT)
        DO J=1,MA-1
                DO I=J+1,MA
                        COVAR(I,J)=0.
                ENDDO
        ENDDO
        DO I=1,MFIT-1
                DO J=I+1,MFIT
                        IF(LISTA(J).GT.LISTA(I)) THEN
                           COVAR(LISTA(J),LISTA(I))=COVAR(I,J)
                        ELSE
                           COVAR(LISTA(I),LISTA(J))=COVAR(I,J)
                        ENDIF
                ENDDO
        ENDDO
        SWAP=COVAR(1,1)
        DO J=1,MA
                COVAR(1,J)=COVAR(J,J)
                COVAR(J,J)=0.
        ENDDO
        COVAR(LISTA(1),LISTA(1))=SWAP
        DO J=2,MFIT
                COVAR(LISTA(J),LISTA(J))=COVAR(1,J)
        ENDDO
        DO J=2,MA
                DO I=1,J-1
                        COVAR(I,J)=COVAR(J,I)
                ENDDO
        ENDDO
        RETURN
        END





* ------------------------------------------------------------------


      real function fact(i)
* factorial of i (i.e. i!)
      factorial = 1.0
      do j = 1, i
         factorial = factorial*float(j)
      end do
      fact = factorial
      return
      end


* ------------------------------------------------------------------

c ------------------------------- zufall.f package -----------------------

      subroutine zufall(n,a)
      implicit none
c
c portable lagged Fibonacci series uniform random number
c generator with "lags" -273 und -607:
c
c       t    = u(i-273)+buff(i-607)  (floating pt.)
c       u(i) = t - float(int(t))
c
c W.P. Petersen, IPS, ETH Zuerich, 19 Mar. 92
c
      double precision a(*)
      double precision buff(607)
      double precision t
      integer i,k,ptr,VL,k273,k607
      integer buffsz,nn,n,left,q,qq
      integer aptr,aptr0,bptr
c
      common /klotz0/buff,ptr
      data buffsz/607/
c
      aptr = 0
      nn   = n
c
1     continue
c
      if(nn .le. 0) return
c
c factor nn = q*607 + r
c
      q    = (nn-1)/607
      left = buffsz - ptr
c
      if(q .le. 1) then
c
c only one or fewer full segments
c
         if(nn .lt. left) then
            do 2 i=1,nn
               a(i+aptr) = buff(ptr+i)
2           continue
            ptr  = ptr + nn
            return
         else
            do 3 i=1,left
               a(i+aptr) = buff(ptr+i)
3           continue
            ptr  = 0
            aptr = aptr + left
            nn   = nn - left
c  buff -> buff case
            VL   = 273
            k273 = 334
            k607 = 0
            do 4 k=1,3
cdir$ ivdep
*vdir nodep
*VOCL LOOP, TEMP(t), NOVREC(buff)
               do 5 i=1,VL
                  t            = buff(k273+i) + buff(k607+i)
                  buff(k607+i) = t - float(int(t))
5              continue
               k607 = k607 + VL
               k273 = k273 + VL
               VL   = 167
               if(k.eq.1) k273 = 0
4           continue
c
            goto 1
         endif
      else
c
c more than 1 full segment
c 
          do 6 i=1,left
             a(i+aptr) = buff(ptr+i)
6         continue
          nn   = nn - left
          ptr  = 0
          aptr = aptr+left
c 
c buff -> a(aptr0)
c 
          VL   = 273
          k273 = 334
          k607 = 0
          do 7 k=1,3
             if(k.eq.1)then
*VOCL LOOP, TEMP(t)
                do 8 i=1,VL
                   t         = buff(k273+i) + buff(k607+i)
                   a(aptr+i) = t - float(int(t))
8               continue
                k273 = aptr
                k607 = k607 + VL
                aptr = aptr + VL
                VL   = 167
             else
cdir$ ivdep
*vdir nodep
*VOCL LOOP, TEMP(t)
                do 9 i=1,VL
                   t         = a(k273+i) + buff(k607+i)
                   a(aptr+i) = t - float(int(t))
9               continue
                k607 = k607 + VL
                k273 = k273 + VL
                aptr = aptr + VL
             endif
7         continue
          nn = nn - 607
c
c a(aptr-607) -> a(aptr) for last of the q-1 segments
c
          aptr0 = aptr - 607
          VL    = 607
c
*vdir novector
          do 10 qq=1,q-2
             k273 = 334 + aptr0
cdir$ ivdep
*vdir nodep
*VOCL LOOP, TEMP(t), NOVREC(a)
             do 11 i=1,VL
                t         = a(k273+i) + a(aptr0+i)
                a(aptr+i) = t - float(int(t))
11           continue
             nn    = nn - 607
             aptr  = aptr + VL
             aptr0 = aptr0 + VL
10        continue
c
c a(aptr0) -> buff, last segment before residual
c
          VL   = 273
          k273 = 334 + aptr0
          k607 = aptr0
          bptr = 0
          do 12 k=1,3
             if(k.eq.1) then
*VOCL LOOP, TEMP(t)
                do 13 i=1,VL
                   t            = a(k273+i) + a(k607+i)
                   buff(bptr+i) = t - float(int(t))
13              continue
                k273 = 0
                k607 = k607 + VL
                bptr = bptr + VL
                VL   = 167
             else
cdir$ ivdep
*vdir nodep
*VOCL LOOP, TEMP(t), NOVREC(buff)
                do 14 i=1,VL
                   t            = buff(k273+i) + a(k607+i)
                   buff(bptr+i) = t - float(int(t))
14              continue
                k607 = k607 + VL
                k273 = k273 + VL
                bptr = bptr + VL
             endif
12        continue
          goto 1
      endif
      end
c
      subroutine zufalli(seed)
      implicit none
c
c  generates initial seed buffer by linear congruential
c  method. Taken from Marsaglia, FSU report FSU-SCRI-87-50
c  variable seed should be 0 < seed <31328
c
      integer seed
      integer ptr
      double precision s,t
      double precision buff(607)
      integer ij,kl,i,ii,j,jj,k,l,m
      common /klotz0/buff,ptr
      data ij/1802/,kl/9373/
c
      if(seed.ne.0) ij = seed
c
      i = mod(ij/177,177) + 2
      j = mod(ij,177) + 2
      k = mod(kl/169,178) + 1
      l = mod(kl,169)
      do 1 ii=1,607
         s = 0.0
         t = 0.5
         do 2 jj=1,24
            m = mod(mod(i*j,179)*k,179)
            i = j
            j = k
            k = m
            l = mod(53*l+1,169)
            if(mod(l*m,64).ge.32) s = s+t
            t = .5*t
2        continue
         buff(ii) = s
1     continue
      return
      end
c
      subroutine zufallsv(svblk)
      implicit none
c
c  saves common blocks klotz0, containing seeds and 
c  pointer to position in seed block. IMPORTANT: svblk must be
c  dimensioned at least 608 in driver. The entire contents
c  of klotz0 (pointer in buff, and buff) must be saved.
c
      double precision buff(607)
      integer ptr,i
      double precision svblk(*)
      common /klotz0/buff,ptr
c
      svblk(1) = ptr
      do 1 i=1,607
         svblk(i+1) = buff(i)
1     continue
c
      return
      end
      subroutine zufallrs(svblk)
      implicit none
c
c  restores common block klotz0, containing seeds and pointer
c  to position in seed block. IMPORTANT: svblk must be
c  dimensioned at least 608 in driver. The entire contents
c  of klotz0 must be restored.
c
      double precision buff(607)
      integer i,ptr
      double precision svblk(*)
      common /klotz0/buff,ptr
c
      ptr = svblk(1)
      do 1 i=1,607
         buff(i) = svblk(i+1)
1     continue
c
      return
      end

      subroutine normalen(n,x)
      implicit none
c
c Box-Muller method for Gaussian random numbers
c
      double precision x(*)
      double precision xbuff(1024)
      integer i,ptr,xptr,first
      integer buffsz,nn,n,left 
      common /klotz1/xbuff,first,xptr
      data buffsz/1024/
c
      nn   = n
      if(nn .le. 0) return
      if(first.eq.0)then
         call normal00
         first = 1
      endif
      ptr = 0
c
1     continue
      left = buffsz - xptr
      if(nn .lt. left) then
         do 2 i=1,nn
            x(i+ptr) = xbuff(xptr+i)
2        continue
         xptr = xptr + nn
         return
      else
         do 3 i=1,left
            x(i+ptr) = xbuff(xptr+i)
3        continue
         xptr = 0
         ptr  = ptr+left
         nn   = nn - left
         call normal00
         goto 1
      endif
      end
      subroutine normal00
      implicit none
      double precision pi,twopi
      parameter(pi=3.141592653589793)
      double precision xbuff(1024),r1,r2,t1,t2
      integer first,xptr,i
      common /klotz1/xbuff,first,xptr
c
      twopi = 2.*pi
      call zufall(1024,xbuff)
*VOCL LOOP, TEMP(r1,r2,t1,t2), NOVREC(xbuff)
      do 1 i=1,1024,2
         r1         = twopi*xbuff(i)
         t1         = cos(r1)
         t2         = sin(r1)
         r2         = sqrt(-2.*log(1.-xbuff(i+1)))
         xbuff(i)   = t1*r2
         xbuff(i+1) = t2*r2
1     continue
c
      return
      end
      subroutine normalsv(svbox)
      implicit none
c
c  saves common block klotz0 containing buffers
c  and pointers. IMPORTANT: svbox must be dimensioned at 
c  least 1634 in driver. The entire contents of blocks 
c  klotz0 (via zufallsv) and klotz1 must be saved.
c
      double precision buff(607)
      integer i,k,ptr
      double precision xbuff(1024)
      integer xptr,first
      double precision svbox(*)
      common /klotz0/buff,ptr
      common /klotz1/xbuff,first,xptr
c
      if(first.eq.0)then
         print *,' ERROR in normalsv, save of unitialized block'
      endif
c
c  save zufall block klotz0
c
      call zufallsv(svbox)
c
      svbox(609) = first
      svbox(610) = xptr
      k = 610
      do 1 i=1,1024
         svbox(i+k) = xbuff(i)
1     continue
c
      return
      end
      subroutine normalrs(svbox)
      implicit none
c
c  restores common blocks klotz0, klotz1 containing buffers
c  and pointers. IMPORTANT: svbox must be dimensioned at 
c  least 1634 in driver. The entire contents
c  of klotz0 and klotz1 must be restored.
c
      double precision buff(607)
      integer ptr
      double precision xbuff(1024)
      integer i,k,xptr,first
      double precision svbox(*)
      common /klotz0/buff,ptr
      common /klotz1/xbuff,first,xptr
c
c restore zufall blocks klotz0 and klotz1
c
      call zufallrs(svbox)
      first = svbox(609)
      if(first.eq.0)then
         print *,' ERROR in normalsv, restoration of unitialized block'
      endif
      xptr  = svbox(610)
      k = 610
      do 1 i=1,1024
         xbuff(i) = svbox(i+k)
1     continue
c
      return
      end

      subroutine fische(n,mu,p)
      implicit none
      integer p(*)
      integer indx(1024)
      integer n,i,ii,jj,k,left,nl0,nsegs,p0
      double precision u(1024),q(1024)
      double precision q0,pmu,mu
c
c Poisson generator for distribution function of p's:
c
c    q(mu,p) = exp(-mu) mu**p/p!
c
c initialize arrays, pointers
c
      if (n.le.0) return
c
      pmu = exp(-mu)
      p0  = 0
c
      nsegs = (n-1)/1024 
      left  = n - nsegs*1024
      nsegs = nsegs + 1
      nl0   = left
c
      do 2 k = 1,nsegs
c
         do 3 i=1,left
            indx(i)    = i
            p(p0+i)    = 0
            q(i)       = 1.0
3        continue
c
c Begin iterative loop on segment of p's
c
1        continue
c
c Get the needed uniforms
c
         call zufall(left,u)
c
         jj = 0
c
cdir$ ivdep
*vdir nodep
*VOCL LOOP, TEMP(ii,q0), NOVREC(indx,p,q)
         do 4 i=1,left
            ii    = indx(i)
            q0    = q(ii)*u(i)
            q(ii) = q0
            if( q0.gt.pmu ) then
               jj       = jj + 1
               indx(jj) = ii
               p(p0+ii) = p(p0+ii) + 1
            endif
4        continue
c
c any left in this segment?
c
         left = jj
         if(left.gt.0)then
            goto 1
         endif
c
         p0    = p0 + nl0
         nl0   = 1024
         left  = 1024
c
2     continue
c
      return
      end
c
      block data
      implicit none
c
c globally accessable, compile-time initialized data
c
      integer ptr,xptr,first
      double precision buff(607),xbuff(1024)
      common /klotz0/buff,ptr
      common /klotz1/xbuff,first,xptr
      data ptr/0/,xptr/0/,first/0/
      end


