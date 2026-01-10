PRO example2,observed_image,inside,outside,imin2
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
;----------------------------------------------------------------------------------------------------------------------------------------------
; Example 2 - uses a synthetic image and treats itto make a pretend observed image
;
; Read in a moon image
get_imin2,imin,l
window,1,title='Original image'

;----------------------------------------------------------
; Get the right PDF in order to convolve the ideal image and get your fake oberveed image
example_power=1.9
if (STRUPCASE(typeflag) eq "KING") then get_pdf_King,l,pdf,example_power
trial_sigma=155.0d0
if (STRUPCASE(typeflag) eq "GAUSSIAN") then get_pdf_Gaussian,l,pdf,trial_sigma
;----------------------------------------------------------
; Now convolve the image with the PDF
fold_image_with_pdf,imin,l,folded_image,pdf
weight=0.03
combined_image=imin/mean(imin)*(1.0-weight)+weight*folded_image/mean(folded_image)
observed_image=combined_image/mean(combined_image)*mean(imin)
writefits,'Constructed_observed_image_ex2.fit',(observed_image)
writefits,'Constructed_observed_image_ex2_LONG.fit',long(observed_image)
;----------------------------------------------------------
; Get the circle that describes Moon/Sky
radius=101.
moon_coords=[201.,200.]
get_circle,l,moon_coords,circle,radius,max(imin)
;----------------------------------------------------------
; Build a composite image of Moon and circle
imin2=imin+circle
tvscl,alog(imin2)

;----------------------------------------------------------
; find the inside and the outside of the circle around the Moon
find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
im1=imin	; ie the known case without sky
im3=outside	; the skymask
im2=observed_image

return
end

PRO example1,observed_image,inside,outside,imin2
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
;----------------------------------------------------------------------------------------------------------------------------------------------
; Example 1 - a real image as input, and a treatment of that real image is used as the hypotheitcal 'ideal image'.
;
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
;----------------------------------------------------------
; find the inside and the outside of the circle around the Moon
find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
im1=imin	; ie the known case without sky
im3=outside	; the skymask
;----------------------------------------------------------
; Now convolve the image with the PDF
;fold_image_with_pdf,imin,l,observed_image,pdf
observed_image=imin	; for now
im2=observed_image
return
end


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
plot,dummy(*,l(1)/2.),charsize=2,xtitle='Pixel column',ytitle='Difference',title='Obs. Image - Trial image slice'
im4=trial_image
RETURN, err
END

PRO go_postpp,imin,imin2,im4,observed_image,cleaned_image,difference
; This is a post-processing routine - it saves and displays results
; display the results
display_stuff,imin2,im4,observed_image,cleaned_image,difference
; save results
save_stuff,imin,im4,observed_image,cleaned_image,difference
return
end

FUNCTION moonresidual_Gaussian, X
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
trial_sigma=abs(x(0))
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
common uselater,im4,difference
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
writefits,'Last_subtracted_image.fit',im4
writefits,'Last_subtracted_image_LONG.fit',long(im4)
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

PRO get_imin2,imin,l
imin=readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\LunarImg_0001.fts')
imin=congrid(imin,400,400)
l=size(imin,/dimensions)
writefits,'EX2_ideal_image_input_400x400.fit',imin
writefits,'EX2_ideal_image_input_400x400_LONG.fit',long(imin)
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

PRO fold_image_with_pdf,imin,l,observed_image,pdf
observed_image=fft(fft(imin,-1,/double)*fft(pdf,-1,/double),1,/double)
observed_image=sqrt(observed_image*conj(observed_image))
observed_image=double(observed_image)
return
end

PRO display_stuff,imin2,im4,observed_image,cleaned_image,difference
window,1,title='Cleaned-up image'
tvscl,cleaned_image
window,2,title='Scattered light image'
tvscl,im4
window,3,title='Observed image'
tvscl,observed_image
window,4,title='Observed - Scattered'
tvscl,difference
window,5,title='Slice in residuals'
plot,difference(*,220),charsize=2,yrange=[-10,30]
help
return
end

PRO save_stuff,imin,im4,observed_image,cleaned_image,difference
common fitedresults,P
common type,typeflag
; gaussian case
if (STRUPCASE(typeflag) eq "GAUSSIAN") then begin
MKHDR, header, difference
sxaddpar, header, 'Sigma', p(0), 'Convolved Gaussian cleanup'
sxaddpar, header, 'Factor', p(1), 'Convolved Gaussian cleanup'
WRITEFITS, 'Corrected_image_Gaussian.fit', difference,header
WRITEFITS, 'Corrected_image_Gaussian_LONG.fit', long(difference),header
endif
if (STRUPCASE(typeflag) eq "KING") then begin
; King profile case
MKHDR, header, difference
sxaddpar, header, 'Height', p(0), 'Convolved King Profile cleanup'
sxaddpar, header, 'Power', p(1), 'Convolved King Profile cleanup'
WRITEFITS, 'Corrected_image_King.fit', difference,header
WRITEFITS, 'Corrected_image_King_LONG.fit',long( difference),header
endif
return
end

;=================MAIN PROGRAMME==============
; This code models the scattering of light from bright pixels in an image, subtracts the model
; from the image and trie sto minimize the residuals on the part of the image outside the lunar rim.
; Several examples are provided for different types of experiments:
; Example 1 uses a real observed image and treats it to generate a surrogate 'ideal image' which is used
; as the image to convolve various PDFs with.
; Example 2 uses a synthetic image from eshine_15.pro as input (adds scattered light from a selected PDF) and the same
; synthetic image of the Moon to fold with various PDFs.
; Example 3 uses a real image and a synthetic image as the ideal image
;---------------------------------------------------------------------------------
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
;----------------------------------------------------------
;typeflag='GAUSSIAN'
typeflag='KING'
;----------------------------------------------------------
; Select the type of example you want:
;example1,observed_image,inside,outside,imin2	; Ex. 1 uses a real image and treats it to make a pretend ideal image
example2,observed_image,inside,outside,imin2	; Ex. 2 uses an ideal image and treats it to make a pretend observation

;----------------------------------------------------------

; try to remove the scattered light from "observed_image"
remove_scattered_light,observed_image,clean_image,inside,outside
;--------------------------------------------------------------------------
; Post-processing
go_postpp,im1,imin2,im4,observed_image,clean_image,difference
end
