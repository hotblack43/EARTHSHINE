FUNCTION foldnFAN_FT, X, P
 common stuff,  Y, obs,im1,im2,PSForig,residuals
 alfa1=p(0)
 bwpr=p(1)
 pedestal=p(2)
 albedo=p(3)
 xshift=p(4)
 acoeff=p(5)
 lamda0=p(6)
 yshift=p(7)
 zodi=0.0d0
 SLcounts=0.0d0
 mixedimage=im1*(1.0d0-albedo)+im2*albedo
 ; identify the pixel that should have added Zodial light corrections
 idx=where(mixedimage eq 0.0)
 mixedimage(idx)=mixedimage(idx)+zodi+SLcounts
 mixedimage=mixedimage/total(mixedimage,/double)*total(obs,/double)
 mixedimage=shift_sub(mixedimage,xshift,yshift)+pedestal
 plot_io,mixedimage(*,256)
 ; set up the PSF
 PSFuse=PSForig^alfa1
 PSFuse=PSFuse/total(PSFuse,/double)
 folded=FFT(PSFuse,-1,/double)*FFT(mixedimage,-1,/double)*512.0d0*512.0d0
 value=[double(folded),imaginary(folded)]
 return,(value)
 END
 
 PRO dothefitinFTspace,parms
 common stuff,  Y, obs,im1,im2,PSForig,residuals
 
 Y=FFT(obs,-1,/double)
 Y=[double(y),imaginary(y)]
;Y=(y)
 X=Y*0.0	; X is a dummy argument
 Z=sqrt(abs(Y))+median(abs(Y))
 Z=1./Z
 alfa1=1.79d0
 bwpr=1.60d0
 pedestal=0.005d0
 albedo=0.34d0
 xshift=0.0d0
 acoeff=.06d0
 lamda0=456.0d0
 yshift=0.0d0
 zodi=0.0d0
 SLcounts=0.0d0
 p = [alfa1,bwpr,pedestal,albedo,xshift,acoeff,lamda0,yshift,zodi,SLcounts]
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, limited:[0,0], limits:[0.D,0],step:1d-6}, 10)
 parinfo[0].fixed = 0	; alfa1
 parinfo[1].fixed = 1	; bwpr
 parinfo[2].fixed = 0	; pedestal
 parinfo[3].fixed = 0	; albedo
 parinfo[4].fixed = 1	; xshift
 parinfo[5].fixed = 1	; acoeff
 parinfo[6].fixed = 1	; lamda0
 parinfo[7].fixed = 1	; yshift
 parinfo[8].fixed = 1	; ZL always fixed
 parinfo[9].fixed = 1	; SL always fixed
 ; alfa1 - the 'wing alfa'
 parinfo[0].limited(0) = 1
 parinfo[0].limits(0)  = 1.1
 parinfo[0].limited(1) = 1
 parinfo[0].limits(1)  = 3.1
 ; bwpr 
 parinfo[1].limited(0) = 1
 parinfo[1].limits(0)  = 0
 parinfo[1].limited(1) = 1
 parinfo[1].limits(1)  = 10
 ; pedestal
 parinfo[2].limited(0) = 1
 parinfo[2].limits(0)  = -200.0
 parinfo[2].limited(1) = 1
 parinfo[2].limits(1)  =900.0 
 ; albedo
 parinfo[3].limited(0) = 1
 parinfo[3].limits(0)  = 0.0
 parinfo[3].limited(1) = 1
 parinfo[3].limits(1)  = 1.0
 ; xshift
 parinfo[4].limited(0) = 1
 parinfo[4].limits(0)  = -3
 parinfo[4].limited(1) = 1
 parinfo[4].limits(1)  = 3
 ; core factor
 parinfo[5].limited(0) = 1
 parinfo[5].limits(0)  = 0.
 parinfo[5].limited(1) = 1
 parinfo[5].limits(1)  = 3
 ; lamda0 of LRO map
 parinfo[6].limited(0) = 1
 parinfo[6].limits(0)  = 302
 parinfo[6].limited(1) = 1
 parinfo[6].limits(1)  = 709
 ; y-shift
 parinfo[7].limited(0) = 1
 parinfo[7].limits(0)  = -6.
 parinfo[7].limited(1) = 1
 parinfo[7].limits(1)  = 6.
 ; zodiacal counts
 parinfo[8].limited(0) = 0. ; 1
 parinfo[8].limits(0)  = 0.
 parinfo[8].limited(1) = 0
 parinfo[8].limits(1)  = 0.
 ; starlight counts
 parinfo[9].limited(0) = 0. ; 1
 parinfo[9].limits(0)  = 0.
 parinfo[9].limited(1) = 0
 parinfo[9].limits(1)  = 0.
 ;
 parinfo[*].value = p*1.0d0
 ;
 
 parms = MPFITFUN('foldnFAN_FT', X, Y, Z, p, yfit=yfit, $
 PARINFO=parinfo,  PERROR=sigs,niter=niter,covar=covariance,weights=X*0.0+1.0)
 z=dcomplex(yfit(0:511,*),yfit(512:1023,*))
 out=float(fft(z,1,/double))
 writefits,'out.fits',out
 return
 end
 
 
 
 
 ;........................................................................................
 ; Version 1 of code that finds albedo by model-fitting
 ; in the Fourier domain
 ;........................................................................................
 common stuff,  Y, obs,im1,im2,PSForig,residuals
 im1=readfits('im1.fits')
 im2=readfits('im2.fits')
 PSForig=readfits('PSF.fit')
 obs=readfits('observed_image_JD2456061.0708271.fits')
 dothefitinFTspace,parms
 print,'Solution: ',parms
 im=readfits('out.fits')
 plot_io,obs(*,256),color=fsc_color('red'),charsize=2
 oplot,im(*,256)+445
 end
 
