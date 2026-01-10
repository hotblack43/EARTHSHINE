 PRO goconvolve,IM,PSF,RES
 ; forward convolve IM with PSF and return in RES
 RES=fft(fft(im,-1,/double)*fft(psf,-1,/double),1,/double)
 res=double(sqrt(res*conj(res)))
 return
 end
 
 PRO godeconvolve,IM,PSF,RES,eps
 ; DEconvolve IM with PSF and return in RES
 RES=fft(fft(im,-1,/double)/(abs(eps)+(fft(psf,-1,/double))),1,/double)
 res=double(sqrt(res*conj(res)))
 return
 end
 
 FUNCTION linefit, X, P
 common stuff,mask,PSF_in,IM_in,deconvolved,reconvolved,y0,use1,use2,w
 PSF=PSF_in
 IM=IM_in
 ; X is X, P is the set of parameters
 eps=p(0)
 pow=p(1)
 noiselev=p(2)
 ;
 print,'p: ',p
 PSF=PSF^pow
 PSF=PSF/total(PSF,/double)*512.0d0*512.0d0
 ; deconvolve observed image with trial PSF
 godeconvolve,IM,PSF,deconvolved,eps
;; set low pixels to zero
;idx=where(deconvolved lt noiselev)
;deconvolved(idx)=0.0d0
; apply mask to get rid of sky
 deconvolved=deconvolved*mask
writefits,'deconsettozero.fits',deconvolved
 ; renormalize to same total as before
 deconvolved=deconvolved/total(deconvolved,/double)*total(im,/double)
writefits,'deconsettozero_andnormalized.fits',deconvolved
 ;convolve that with trial PSF, get reconvolved
 goconvolve,deconvolved,PSF,reconvolved
; snip out the piece to compare to
 value=avg(reconvolved(use1:use2,y0-w:y0+w),1,/NaN)
;..................................
 plot,xstyle=3,im(*,y0),/ylog,ytitle='Observed',yrange=[0.01,1e5]
 oplot,[!X.crange],[noiselev,noiselev],linestyle=2
;...
 plot,xstyle=3,deconvolved(*,y0),/ylog,ytitle='Obs deconvolved',yrange=[0.01,1e5]
;...
 plot,xstyle=3,im(*,y0),/ylog,ytitle='Observed and in red Obs decon, reconvolved',yrange=[0.01,1e5]
 oplot,reconvolved(*,y0),color=fsc_color('red')
;...
 plot,xstyle=3,value,ytitle='Target to fit (yellow) and model'
 line=avg(im(use1:use2,y0-w:y0+w),1,/NaN)
 oplot,line,color=fsc_color('yellow')
;...
 print,'RMSE: ',sqrt(total((value-line)^2,/double))
;..................................
 return,value
 end
 
 PRO gofindbest,p
 common stuff,mask,PSF,IM,deconvolved,reconvolved,y0,use1,use2,w
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, limited:[0,0], limits:[0.D,0],step:1d-3}, 3)
 parinfo[0].fixed = 0
 parinfo[1].fixed = 0
 parinfo[2].fixed = 1
 ; eps
 parinfo[0].limited(0) = 1
 parinfo[0].limits(0)  = 0.0
 parinfo[0].limited(1) = 0
 parinfo[0].limits(1)  = 5.46
 ; pow
 parinfo[1].limited(0) = 0
 parinfo[1].limits(0)  = 2.1
 parinfo[1].limited(1) = 0
 parinfo[1].limits(1)  = 4.3
 ; noiselev
 parinfo[2].limited(0) = 1
 parinfo[2].limits(0)  = 1.9
 parinfo[2].limited(1) = 0
 parinfo[2].limits(1)  = 1.9
 ;
 parinfo[*].value = p
 ;
 maxiter=1000
 w=7
 use1=100
 use2=200
 y=avg(im(use1:use2,y0-w:y0+w),1,/NaN)
 x=y*0.0
 erry=sqrt(y)/6.
 parms = MPFITFUN('linefit', X, Y, erry, p,  $
                   PARINFO=parinfo, PERROR=sigs,maxiter=maxiter,niter=niter)
 print,'niter,maxiter=',niter,maxiter
 eps=parms(0)
 pow=parms(1)
 noiselev=parms(2)
 print,'Solution:'
 print,'eps:     ',eps,' +/- ',sigs(0)
 print,'pow:     ',pow,' +/- ',sigs(1)
 print,'noiselev:',noiselev,' +/- ',sigs(2)
 return
 end
 ;---------------------------------------------------------------------------------------------
 ; Tries to iteratively deconvolve an image using the procedure in "ISS_calibration_PSS.pdf"
 ; Finds best values for eps,pow and noiselev by MPFIT
 ;---------------------------------------------------------------------------------------------
 common stuff,mask,PSF,IM,deconvolved,reconvolved,y0,use1,use2,w
 ; get the observed image IM
 cube=double(readfits('/media/thejll/OLDHD/CUBES/cube_MkIV_onealfa_2456047.9008578_B_.fits'))
 ideal=reform(cube(*,*,4))
 mask=ideal gt 0
;mask(350:511,*)=1
oldmask=mask
 ; Create the shape operator:
S = REPLICATE(1, 3, 3)
; "grow" operator:
mask = dilate(mask, S)
 IM=reform(cube(*,*,0))+0.009
 klx=where(im eq max(im))
 coords=array_indices(im,klx)
 y0=coords(1)
 print,'y0: ',y0
 ; generate the first trial PSF
 PSF=double(readfits('PSF.fit'))
 ;PSF=readfits('voigt_psf_512.fits')
 !P.MULTI=[0,1,4]
 !P.CHARSIZE=1.6
;eps=p(0)
;pow=p(1)
;noiselev=p(2)
 p=[0.001051154,      2.9405506,     1.97197229]
 gofindbest,p
 ; learn from that
 writefits,'observed.fits',im
 writefits,'deconvolved.fits',deconvolved
 writefits,'both.fits',[im,deconvolved]
 end
