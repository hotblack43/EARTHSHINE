FUNCTION get_source,im
common stuff,factor,image_scale
source=double(im)
source(0:(800-240)/factor,*)=0.0d0
idx=where(source gt 0.95*max(source))
source(idx)=0.0d0
contour,source,/cell_fill,nlevels=41,xstyle=1,ystyle=1,title='Source after zeroing some..'
print,'Touch a key to proceed...'
a=get_kbrd()
return,source
end


PRO get_mask,im,mask
common stuff,factor,image_scale
mask=im*0
l=size(im,/dimensions)
dims=(436./factor)^2
sims=(589.-240)/factor
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
	radius=(i+(240-810.)/factor)^2+(j-515./factor)^2
	if (radius ge dims and i lt sims) then mask(i,j)=1
endfor
endfor
return
end


PRO get_currentguess,source,A,currentguess
common stuff,factor,image_scale
common counter,icount,keep
; will set up the current guess for the scattered light, given the source 
; image, and a vector of parameters for the scattering function
l=size(source,/dimensions)
currentguess=source*0.0d0
for icol_guess=0,l(0)-1,1 do begin
for irow_guess=0,l(1)-1,1 do begin
for icol_source=0,l(0)-1,1 do begin
for irow_source=0,l(1)-1,1 do begin

radius=sqrt((icol_guess-icol_source)^2+(irow_guess-irow_source)^2)*image_scale
contrib=A(0)+A(1)*source(icol_source,irow_source)*exp(-0.5*(radius/A(2))^2)
currentguess(icol_guess,irow_guess)=currentguess(icol_guess,irow_guess) + contrib

endfor
endfor
endfor
endfor
icount=314
print,max(currentguess),min(currentguess)
return
end


FUNCTION powfunc, A  
common imageandmask,im,source,mask
common currgues,currentguess
common stuff2,bestSTD
l=size(im,/dimensions)
get_currentguess,source,A,currentguess
idx=where(mask eq 1)
value=total((im(idx)-currentguess(idx))^2)
print,'Powfunc:',A,value
residual=im-currentguess
idx=where(mask ne 1)
jdx=where(mask eq 1)
residual(idx)=0.0
contour,residual,/cell_fill,nlevels=41,xstyle=1,ystyle=1
print,'Residuals min,max,STD,best STD:',min(residual(jdx)),max(residual(jdx)),stddev(residual(jdx)),bestSTD
if stddev(residual(jdx)) lt bestSTD then bestSTD=stddev(residual(jdx))
   RETURN, value
END

PRO model_scattered,source,im,scattered
common currgues,currentguess
; will estimate the field of scattered light in an image
; 'source' is the image that is having its photons scattered
; 'im' is the image in which the scattering is to be estimated
; 'scattered' is the resulting estimate for some areas of im
P=[6.35292,    0.340600,    0.410059]
P=[9.77838,     9.66062,    0.187965]
P=[11.3479,    0.132668,    0.416030]
p=[10.9242,    0.132668,    0.416030]
P=[4.18618,   0.0291455,    0.820159]
P=[4.70606,   0.0280629,    0.818310]
xi = TRANSPOSE([[1.0, 0.0, 0.0],[0.0, 1.0, 0.0],[0.0, 0.0, 1.0]])
ftol=1.0d-9
POWELL, P, xi, ftol, fmin, 'powfunc'
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
bestSTD=9e20
icount=0
; get image to correct for scattered light
file='May27/obsrun1/IMG164.FIT'
getimage,file,im,header
remove_bias,im
divide_by_flat,im
; choose subimage
im=im(240:240+2^10-1,0:2^10-1)
image_scale=2.10526	; arcsec/pixel
; rescale image if you want..
l=size(im,/dimensions)
print,l
factor=32
print,'Rescaling to ...',l/factor
im=rebin(im,l/factor)
contour,im,/cell_fill,xstyle=1,ystyle=1,nlevels=41,title='Im after rescaling'
print,'Touch a key to proceed...'
a=get_kbrd()
image_scale=2.10526/float(factor)	; arcsec/pixel
; set the mask to be corrected inside
get_mask,im,mask
; set the image which acts as source of scattered photons
source=get_source(im)	; this may be original image, or part of it..
model_scattered,source,im,scattered
contour,im-scattered,/cell_fill,nlevels=41
end
