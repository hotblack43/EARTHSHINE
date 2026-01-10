PRO get_images,im,img
im=readfits('C:\Documents and Settings\Daddyo\Skrivebord\ASTRO\ANDREW\sydney_2x2.fit')
l=size(im,/dimensions)
ll=min([l(0),l(1)])
im=im(0:ll-1,0:ll-1)
; guess the real source
idx=where(im lt 0.03*max(im))
img=im
img(idx)=0.0d0
img=img/total(img)*total(im)
return
end


; Code to deconvolvce an 'observed' image so that the 'source' and 'psf' are recovered

get_images,observed,guessed_source
FFT_obs=FFT(observed,-1,/double)
niter=10
; guess the source
source=guessed_source
!P.MULTI=[0,1,3]
for iter=0,niter-1,1 do begin
   plot,source(*,75)
   contour,/cell_fill,source,title=string(iter),/isotropic
   FFT_PSF=FFT_obs/FFT(source,-1,/double)
   PSF=FFT(FFT_PSF,1,/double)
   PSF=sqrt(double(PSF*conj(PSF)))
   idx=where(PSF lt 0.008*max(PSF))
   PSF(idx)=0.0
   surface,double(psf)
   FFT_PSF=FFT(PSF,-1,/double)
   newsource=FFT(FFT_obs/FFT_PSF,1,/double)
   source=sqrt(double(newsource*conj(newsource)))
print,mean(psf),mean(source)
   ; a=get_kbrd()
endfor
end