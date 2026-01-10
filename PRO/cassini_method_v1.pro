PRO goconvolve,IM,PSF,RES
; forward convolve IM with PSF and return in RES
 RES=fft(fft(im,-1,/double)*fft(psf,-1,/double),1,/double)
 res=double(sqrt(res*conj(res)))
 return
 end
 
 PRO godeconvolve,IM,PSF,RES,eps
; DEconvolve IM with PSF and return in RES
 RES=fft(fft(im,-1,/double)/(eps+fft(psf,-1,/double)),1,/double)
 res=double(sqrt(res*conj(res)))
 return
 end
 
 ;---------------------------------------------------------------------------------------------
 ; Tries to iteratively deconvolve an image using the procedure in "ISS_calibration_PSS.pdf"
 ; Version 1: Is manual in the assignment of eps,pow and reslimit
 ;---------------------------------------------------------------------------------------------
 ; get the observed image IM
 cube=readfits('/data/pth/CUBESnew/cube_MkIV_onealfa_2456047.9008578_B_.fits')
 IM=reform(cube(*,*,0))
 ; generate the first trial PSF
 PSF=readfits('PSF.fit')
 eps=0.14d0
 pow=3.1d0
 reslimit=1.55d0
 correctionfactor=findgen(512,512)*0+1.0
 niter=1
 for iter=0,niter-1,1 do begin
     PSF=PSF^pow
     PSF=PSF/total(PSF,/double)*512.*512.
     ; deconvolve observed image with trial PSF
     godeconvolve,IM,PSF,deconvolved,eps
     ; set low pixels to zero
     idx=where(deconvolved lt reslimit)
     deconvolved(idx)=0.0
     ; renormalize to same total as before
     deconvolved=deconvolved/total(deconvolved,/double)*total(im,/double)
     ;convolve that with trial PSF, get res2
     goconvolve,deconvolved,PSF,deconvolved2
     ; form ratio of deconvolved2/im
     ratio=deconvolved2/im
     ; learn from that
     !P.MULTI=[0,1,4]
     !P.CHARSIZE=1.6
     jdx=where(im eq max(im))
     coords=array_indices(im,jdx)
     irow=coords(1)
     plot,xstyle=3,avg(im(*,irow-5:irow+5),1),/ylog,ytitle='Observed',yrange=[0.01,1e5]
     oplot,[!X.crange],[reslimit,reslimit],linestyle=2
     plot,xstyle=3,avg(deconvolved(*,irow-5:irow+5),1),/ylog,ytitle='Obs deconvolved',yrange=[0.01,1e5]
     plot,xstyle=3,avg(im(*,irow-5:irow+5),1),/ylog,ytitle='Observed and in red Obs decon, reconvolved',yrange=[0.01,1e5]
     oplot,deconvolved2(*,irow),color=fsc_color('red')
     plot,ystyle=3,xstyle=3,ratio(*,irow),/ylog,ytitle='Ratio of 1 and 3',yrange=[0.5,2]
     oplot,[!X.crange],[1,1],linestyle=2
endfor
 writefits,'observed.fits',im
 writefits,'deconvolved.fits',deconvolved
 writefits,'both.fits',[im,deconvolved]
 print,'eps:pow,reslimit: ',eps,pow,reslimit,' in cassini v1'
 end
