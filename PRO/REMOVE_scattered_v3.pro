PRO get_bestguess,A,bestguess
common imageandmask,im,source,mask
common stuff,factor,image_scale
common counter,icount,keep
common unmaskedscattered,unmaskedscattered
; will calculate the best guess for the scattering from best estimate of A
l=size(source,/dimensions)
bestguess=source*0.0d0
fac=image_scale*image_scale
for icol_guess=0,l(0)-1,1 do begin
for irow_guess=0,l(1)-1,1 do begin
for icol_source=0,l(0)-1,1 do begin
for irow_source=0,l(1)-1,1 do begin
radius2=sqrt(((icol_guess-icol_source)^2+(irow_guess-irow_source)^2))
contrib=A(1)+A(2)*source(icol_source,irow_source)*exp(double(-0.5*(radius/A(0))^2))
bestguess(icol_guess,irow_guess)=bestguess(icol_guess,irow_guess) + contrib
endfor
endfor
endfor
endfor
return
end

PRO modify_mask,mask
l=size(mask,/dimensions)
factor=3.01
n=l(0)*l(1)
kdx=randomu(seed,n*factor)*n
mask(kdx)=0
help,kdx
return
end


FUNCTION get_source,im
common stuff,factor,image_scale
source=double(im)
idx=where(source lt 0.20*max(source))
source(idx)=0.0d0
contour,source,/cell_fill,nlevels=41,xstyle=1,ystyle=1,title='Source after zeroing some..'
print,'Touch a key to proceed...'
a=get_kbrd(1)
return,source
end


PRO get_mask,im,mask
common stuff,factor,image_scale
common moonstuff,x0,y0,radius,safetyfactor
l=size(im,/dimensions)
mask=im*0

for icol=0,l(0)-1,1 do begin
for irow=0,l(1)-1,1 do begin
r=sqrt((icol-x0)^2+(irow-y0)^2)
if (r gt radius*safetyfactor) then mask(icol,irow)=1
endfor
endfor
; Take out half the frame
;mask(l(0)/2.:l(0)-1,*)=0
;................................
print,'Pixels in mask eq 1:',n_elements(where(mask eq 1))
!P.MULTI=[0,1,2]
surface,mask,xstyle=1,ystyle=1,title='Mask after zeroing some..'
surface,mask*im,xstyle=1,ystyle=1,title='Mask*image..'
print,'Touch a key to proceed...'
a=get_kbrd(1)
modify_mask,mask
print,'Pixels in mask eq 1:',n_elements(where(mask eq 1))
surface,mask,xstyle=1,ystyle=1,title='Mask after zeroing some..'
print,'Touch a key to proceed...'
a=get_kbrd(1)
return
end


PRO get_currentguess,A,currentguess
common imageandmask,im,source,mask
common stuff,factor,image_scale
common counter,icount,keep
common unmaskedscattered,unmaskedscattered
; will set up the current guess for the scattered light, given the source
; image, and a vector of parameters for the scattering function
l=size(source,/dimensions)
currentguess=source*0.0d0
for icol_guess=0,l(0)-1,1 do begin
for irow_guess=0,l(1)-1,1 do begin
if (mask(icol_guess,irow_guess) ne 0) then begin
	for icol_source=0,l(0)-1,1 do begin
	for irow_source=0,l(1)-1,1 do begin
if (source(icol_source,irow_source) ne 0) then begin
		radius=sqrt(((icol_guess-icol_source)^2+(irow_guess-irow_source)^2))
;		contrib=A(0)+A(1)*source(icol_source,irow_source)*exp(double(-0.5*(radius/A(2))^2))
contrib=A(1)+A(2)*source(icol_source,irow_source)*exp(double(-0.5*(radius/A(0))^2))
		currentguess(icol_guess,irow_guess)=currentguess(icol_guess,irow_guess) + contrib
endif
	endfor
	endfor
endif
endfor
endfor
icount=314
print,max(currentguess),min(currentguess)
surface,currentguess,charsize=2,title='Best guess for scattered light'
return
end


FUNCTION powfunc, A
common imageandmask,im,source,mask
common currgues,currentguess
common stuff2,bestSTD
l=size(im,/dimensions)
get_currentguess,A,currentguess
idx=where(mask eq 1)
value=total((im(idx)-currentguess(idx))^2)
print,'Powfunc:',A,value
residual=im-currentguess
idx=where(mask ne 1)
jdx=where(mask eq 1)
residual(idx)=0.0
;contour,residual,/cell_fill,nlevels=41,xstyle=1,ystyle=1
surface,residual,xstyle=1,ystyle=1,charsize=2,title='Residuals'
print,'Residuals min,max,STD,best STD:',min(residual(jdx)),max(residual(jdx)),stddev(residual(jdx)),bestSTD
if stddev(residual(jdx)) lt bestSTD then begin
	bestSTD=stddev(residual(jdx))
	openw,45,'best_fit.dat'
	printf,45,a
	close,45
endif
   RETURN, value
END

PRO model_scattered,source,im,scattered,factor
common currgues,currentguess
; will estimate the field of scattered light in an image
; 'source' is the image that is having its photons scattered
; 'im' is the image in which the scattering is to be estimated
; 'scattered' is the resulting estimate for some areas of im
P=[0.00370647, 5.02240e-05,     10.2542]
P=[ 4.04368,   0.0536824,     3.27998]
P=[-2.94874,   0.0537937,   0.0781335]
xi = TRANSPOSE([[1.0, 0.0, 0.0],[0.0, 1.0, 0.0],[0.0, 0.0, 1.0]])
ftol=1.0d-9
POWELL, P, xi, ftol, fmin, 'powfunc',itmax=25
print,'xi:',xi
scattered=currentguess
return
end


PRO divide_by_flat,image
left_flat=readfits('Left_side_flat.FIT')
image(0:650,*)=image(0:650,*)/left_flat(0:650,*)
right_flat=readfits('Right_side_flat.FIT')
image(651:1391,*)=image(651:1391,*)/right_flat(651:1391,*)
return
end

PRO remove_bias,image
bias=readfits('Bias_frame.FIT')
image=image-bias
print,'Removed bias'
return
end

PRO getimage,file,im,header
im=readfits(file,header)*1.0d0
return
end

;============================================
common stuff,factor,image_scale
common imageandmask,im,source,mask
common counter,icount,keep
common stuff2,bestSTD
common unmaskedscattered,unmaskedscattered
common moonstuff,x0,y0,radius,safetyfactor
;............................
x0=78.75
y0=84.5816
radius=54.7875
safetyfactor=1.08
bestSTD=9e20
icount=0
; get image to correct for scattered light
file='sydney_2x2.fit'
getimage,file,im,header
;remove_bias,im
;divide_by_flat,im
; choose subimage
image_scale=1.0
; rescale image if you want..
l=size(im,/dimensions)
print,l
factor=1
print,'Rescaling to ...',l/factor
im=rebin(im,l/factor)
contour,im,/cell_fill,xstyle=1,ystyle=1,nlevels=41,title='Im after rescaling'
print,'Touch a key to proceed...'
a=get_kbrd(1)
; set the mask to be corrected inside
get_mask,im,mask
; set the image which acts as source of scattered photons
source=get_source(im)	; this may be original image, or part of it..
model_scattered,source,im,scattered,factor
a=get_data('best_fit.dat')
get_bestguess,A,unmaskedscattered
contour,im-unmaskedscattered,/cell_fill,nlevels=41
end
