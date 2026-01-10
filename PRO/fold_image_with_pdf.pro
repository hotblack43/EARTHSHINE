PRO fold_image_with_PSF,imin_ORG,l,folded_image,PSF_ORG,pinheight,plate_factor
; PAD THE IMIN AND THE psf TO AVOID LEAKAGE
z=imin_org*0.0
top=[z,z,z]
bottom=top
middle=[z,imin_org,z]
imin=[[top],[middle],[bottom]]
;
nx=3*l(0)
ny=3*l(1)
genPSF,nx,ny,PSF,plate_factor,pinheight

folded_image=fft(fft(imin,-1,/double)*fft(PSF,-1,/double),1,/double)
folded_image=sqrt(folded_image*conj(folded_image))
folded_image=double(folded_image)
folded_image=folded_image/total(folded_image)*total(imin)
; pick out the middle ninth
out1=folded_image[l(0):2*l(0)-1,*]
out=out1(*,l(1):2*l(1)-1)
folded_image=out
return
end

PRO genPSF,ncol,nrow,PSF,plate_factor,pinheight
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
psf(0,0)=pinheight
psf=psf/total(psf)
return
end

obsim=readfits('observed.fit')
tstr='ROLO 2709'
tstr='Andrews'
id=['HAPKE','LAMBERT']
for iid=0,1,1 do begin
namstr=id(iid)
imin=readfits(namstr+'_fitted.fit')
l=size(imin,/dimensions)
ncol=l(0)
nrow=l(1)
;imin=rebin(imin,l/2)
plate_factor=1800./437.	; arc seconds per pixel plate scale
plate_factor=1800./108.	; arc seconds per pixel plate scale
print,'Plate scale is:',plate_factor
pinheight=210.0
genPSF,ncol,nrow,PSF,plate_factor,pinheight
fold_image_with_PSF,imin,l,folded_image,PSF,pinheight,plate_factor
;
!P.MULTI=[0,2,3]
contour,obsim,title=tstr,/cell_fill,/isotropic,nlevels=101,xstyle=1,ystyle=1
tstr=namstr+'model folded with Vega PSF'
contour,folded_image,title=tstr,/cell_fill,/isotropic,nlevels=101,xstyle=1,ystyle=1
plot,obsim(*,l(1)/2.),/ylog,xtitle='Columns',xstyle=1
oplot,folded_image(*,l(1)/2.),color=fsc_color('red')
plot,obsim(*,l(1)/2.),xtitle='Columns',xstyle=1
oplot,folded_image(*,l(1)/2.),color=fsc_color('red')
plot,obsim(l(1)/2.,*),/ylog,xtitle='Rows',xstyle=1
oplot,folded_image(l(1)/2.,*),color=fsc_color('red')
plot,obsim(l(1)/2.,*),xtitle='Rows',xstyle=1
oplot,folded_image(l(1)/2.,*),color=fsc_color('red')
endfor
end
