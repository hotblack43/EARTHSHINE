PRO genPSF,ncol,nrow,PSF,plate_factor
; plate:factor is in arseconds per pixel
file='smooth_psf.dat'
data=get_data(file)
rad=reform(data(0,*))
prof=reform(data(1,*))
PSF=dindgen(ncol,nrow)*0.0d0
midx=ncol/2
midy=nrow/2
 XR = indgen(Ncol)
 YC = indgen(Nrow)
 X = double(XR # (YC*0 + 1))       
 Y = double((XR*0 + 1) # YC)      
rr=sqrt((x-midx)^2+(y-midy)^2)
psf=INTERPOL(prof,rad,rr*plate_factor)
psf=shift(psf,midx,midy)
return
end
