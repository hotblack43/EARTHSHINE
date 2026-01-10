FUNCTION moonresidual_King, X
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
height=x(0)
power=x(1)
ideal=im1
observed_image=im2
outside=im3
; Step 2 Generate a current guess for the PDF
get_pdf_King,l,pdf,power
; Step 3 Fold the ideal image with the PDF
trial_image=fft(fft(ideal,-1,/double)*fft(pdf,-1,/double),1,/double)
trial_image=double(sqrt(trial_image*conj(trial_image)))
;print,mean(observed_image),mean(trial_image)*height
; Step 4 Subtract the folded image from observed_image
difference=observed_image-trial_image*height
err= total(abs(difference*outside),/double)
print,err,height,power
dummy=difference*outside
plot,dummy(*,l(1)/2.),charsize=2
im4=trial_image
RETURN, err
END

FUNCTION moonresidual_Gaussian, X
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
trial_sigma=x(0)
factor=x(1)
ideal=im1
observed_image=im2
outside=im3
; Step 2 Generate a current guess for the PDF
get_pdf_Gaussian,l,pdf,trial_sigma
; Step 3 Fold the ideal image with the PDF
trial_image=fft(fft(ideal,-1,/double)*fft(pdf,-1,/double),1,/double)
trial_image=double(sqrt(trial_image*conj(trial_image)))
;print,mean(observed_image)/mean(trial_image)
; Step 4 Subtract the folded image from observed_image
difference=observed_image-trial_image*abs(factor)
err= total(abs(difference*outside),/double)
print,err,trial_sigma,factor
dummy=difference*outside
plot,dummy(*,l(1)/2.),charsize=2
im4=trial_image*abs(factor)
RETURN, err
END

PRO remove_scattered_light,observed_image,clean_image,inside,outside
common moonres,im1,im2,im3
common uselater,im4
common fitedresults,P
common type,typeflag
; take the image observed_image and generate a correction for the scattered light
; place the corrected image in clean_image
;----------------------------------------------------
l=size(observed_image,/dimensions)
; Define the fractional tolerance:
ftol = 1.0e-4
; Define the starting point:
if (file_test('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_King.dat') eq 0) then begin
	trial_sigma=233.5381
	factor=   8000.5381
ENDIF  ELSE BEGIN
if (STRUPCASE(typeflag) eq "GAUSSIAN") then begin
	openr,83,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_Gaussian.dat'
	readf,83,trial_sigma,factor	; Gaussian case
	print,'Read from bestfit_Gaussian.dat'
endif
if (STRUPCASE(typeflag) eq "KING") then begin
		openr,83,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_King.dat'
		readf,83,height,power	; King profile case
		print,'Read from bestfit_King.dat'
endif
	close,83
ENDELSE
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  P = [trial_sigma,factor] ; Gaussian case
if (STRUPCASE(typeflag) eq "KING") then P=[height,power]	; King profile case

   ; Define the starting directional vectors in column format:
   xi = TRANSPOSE([[1.,0.],[0.,1.]])

   ; Minimize the function:
 if (STRUPCASE(typeflag) eq "GAUSSIAN") then  POWELL, P, xi, ftol, fmin, 'moonresidual_Gaussian',/double,itmax=20
 if (STRUPCASE(typeflag) eq "KING") then  POWELL, P, xi, ftol, fmin, 'moonresidual_King',/double,itmax=20

   ; Print the solution point:
   PRINT, 'Solution point: ', P
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  openw,83,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_Gaussian.dat'
if (STRUPCASE(typeflag) eq "KING") then  openw,83,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_King.dat'
printf,83,p
close,83
print,'Best fit saved'
clean_image=im4
return
end

PRO find_circle_inside_outside,radius,CENTER,inside,outside,l,idx_inside,idx_outside
inside=intarr(l)
outside=intarr(l)
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2= (i-CENTER(0))^2+(j-CENTER(1))^2
		if (r2 gt radius^2) then outside(i,j)=1 ELSE inside(i,j)=1
	endfor
endfor
idx_inside=where(inside eq 1)
idx_outside=where(outside eq 1)
return
end

PRO get_pdf_Gaussian,l,pdf,sigma
pdf=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2= (i-l(0)/2)^2+(j-l(1)/2.)^2
		pdf(i,j)=exp(-r2/sigma)
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
return
end


PRO get_pdf_King,l,pdf,power
pdf=dblarr(l(0),l(1))
pp=abs(power)
half_i=l(0)/2.
half_j=l(1)/2.
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2= (abs(i-half_i))^pp+(abs(j-half_j))^pp
		if (r2 gt 1.0) then pdf(i,j)=1.0d0/r2 else pdf(i,j)=1.0d0
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
return
end


PRO get_circle,l,coords,circle,radius,maxval
circle=fltarr(l)*0.0
astep=0.1d0
x0=coords(0)
y0=coords(1)
for angle=0.0d0,360.0d0-astep,astep do begin
	x=x0+radius*cos(angle*!dtor)
	y=y0+radius*sin(angle*!dtor)
	circle(x,y)=maxval
endfor
return
end

PRO get_imin,imin,l
imin=readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_ChrisAlg_PeterStack_349_float.FIT')
l=size(imin,/dimensions)
width=20
imin=double(imin(width:l(0)-width-1,width:l(1)-width-1))
l=size(imin,/dimensions)
return
end

PRO get_observed_image,imin,l,observed_image,pdf
observed_image=fft(fft(imin,-1,/double)*fft(pdf,-1,/double),1,/double)
observed_image=sqrt(observed_image*conj(observed_image))
observed_image=double(observed_image)
return
end

PRO display_stuff,imin2,im4,observed_image,difference
window,1,title='Original image plus circle'
tvscl,imin2	; imin + a circle to show the sky
window,2,title='Scattered light image'
tvscl,im4
window,3,title='Observed image'
tvscl,observed_image
window,4,title='Observed - Scattered'
tvscl,difference
window,5,title='Slice in residuals'
plot,difference(*,220),charsize=2,yrange=[-10,30]
return
end

PRO save_stuff,im4,observed_image,difference
common fitedresults,P
common type,typeflag
; gaussian case
if (STRUPCASE(typeflag) eq "GAUSSIAN") then begin
MKHDR, header, difference
sxaddpar, header, 'Sigma', p(0), 'Convolved Gaussian cleanup'
sxaddpar, header, 'Factor', p(1), 'Convolved Gaussian cleanup'
WRITEFITS, 'Corrected_image_Gaussian.fit', difference,header
endif
if (STRUPCASE(typeflag) eq "KING") then begin
; King profile case
MKHDR, header, difference
sxaddpar, header, 'Height', p(0), 'Convolved King Profile cleanup'
sxaddpar, header, 'Power', p(1), 'Convolved King Profile cleanup'
WRITEFITS, 'Corrected_image_King.fit', difference,header
endif
return
end

;=================MAIN PROGRAMME==============
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
;----------------------------------------------------------
typeflag='GAUSSIAN'
typeflag='KING'

; Read in a moon image
get_imin,imin,l
window,1,title='Original image'
im1=imin > 10
im1(where(im1 eq 10))=0.0
;----------------------------------------------------------
; Get the circle that describes Moon/Sky
radius=109.9d0
moon_coords=[156,240]
get_circle,l,moon_coords,circle,radius,max(imin)
;----------------------------------------------------------
; Build a composite image of Moon and circle
imin2=imin+circle
tvscl,alog(imin2)
;stop
;----------------------------------------------------------
; find the inside and the outside of the circle around the Moon
find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
im1=imin	; ie the known case without sky
im3=outside	; the skymask
;----------------------------------------------------------
; Now convolve the image with the PDF
;get_observed_image,imin,l,observed_image,pdf
observed_image=imin	; for now
im2=observed_image
;----------------------------------------------------------
; try to remove the scattered light from "observed_image"
remove_scattered_light,observed_image,clean_image,inside,outside
;--------------------------------------------------------------------------
; display the results
display_stuff,imin2,im4,observed_image,difference
; save results
save_stuff,im4,observed_image,difference

end
