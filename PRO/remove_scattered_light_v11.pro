PRO remove_scattered_light_forward_modelling,observed_image,clean_image,inside,outside
common moonres,im1,im2,im3
common uselater,im4,difference
common fitedresults,P
common type,typeflag
common describstr,exp_str
common paths,path
; take the image observed_image and generate a correction for the scattered light
; place the corrected image in clean_image
;----------------------------------------------------
l=size(observed_image,/dimensions)
; Define the fractional tolerance:
ftol = 1.0e-4
; Define the starting point:
if (file_test(path+'bestfit_King.dat') eq 0) then begin
	trial_sigma=233.5381
	factor=   8000.5381
	bias=1.0
ENDIF  ELSE BEGIN
if (STRUPCASE(typeflag) eq "GAUSSIAN") then begin
	openr,83,path+'bestfit_Gaussian.dat'
	readf,83,trial_sigma,factor,bias	; Gaussian case
	print,'Read from bestfit_Gaussian.dat'
endif
if (STRUPCASE(typeflag) eq "KING") then begin
		openr,83,path+'bestfit_King.dat'
		readf,83,height,power,bias	; King profile case
		print,'Read from bestfit_King.dat'
endif
if (STRUPCASE(typeflag) eq "CIE") then begin
		openr,83,path+'bestfit_CIE.dat'
		readf,83,height,scale,bias	; CIE profile case
		print,'Read from bestfit_CIE.dat'
endif
	close,83
ENDELSE
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  P = [trial_sigma,factor] ; Gaussian case
if (STRUPCASE(typeflag) eq "KING") then P=[height,power,bias]	; King profile case
if (STRUPCASE(typeflag) eq "CIE") then P=[height,scale,bias]	; CIE profile case

; Define the starting directional vectors in column format:
xi = TRANSPOSE([[1.,0.,0.],[0.,1.,0.],[0.,0.,1.]])

   ; Minimize the function:
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  begin
	POWELL, P, xi, ftol, fmin, 'moonresidual_Gaussian',/double,itmax=20
endif
if (STRUPCASE(typeflag) eq "KING") then  begin
	POWELL, P, xi, ftol, fmin, 'moonresidual_King',/double,itmax=20
endif
if (STRUPCASE(typeflag) eq "CIE") then  begin
	POWELL, P, xi, ftol, fmin, 'moonresidual_CIE',/double,itmax=20
endif
	writefits,strcompress(path+'Last_subtracted_image_'+exp_str+'.fit',/remove_all),im4
	writefits,strcompress(path+'Last_subtracted_image_'+exp_str+'.fit',/remove_all),long(im4)
; Print the solution point:
PRINT, 'Solution point: ', P
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  openw,83,path+'bestfit_Gaussian.dat'
if (STRUPCASE(typeflag) eq "KING") then  openw,83,path+'bestfit_King.dat'
if (STRUPCASE(typeflag) eq "CIE") then  openw,83,path+'bestfit_CIE.dat'
printf,83,p
close,83
print,'Best fit saved'
clean_image=im4
return
end

PRO fold_image_with_pdf,imin,l,observed_image,pdf
observed_image=fft(fft(imin,-1,/double)*fft(pdf,-1,/double),1,/double)
observed_image=sqrt(observed_image*conj(observed_image))
observed_image=double(observed_image)
return
end

PRO save_stuff,imin,im4,observed_image,cleaned_image,difference
common method,method_str
common fitedresults,P
common type,typeflag
common describstr,exp_str
common paths,path
; gaussian case
if (STRUPCASE(typeflag) eq "GAUSSIAN" and strupcase(method_str) ne 'LINEAR') then begin
MKHDR, header, difference
sxaddpar, header, 'Sigma', p(0), 'Convolved Gaussian cleanup'
sxaddpar, header, 'Factor', p(1), 'Convolved Gaussian cleanup'
endif
if (STRUPCASE(typeflag) eq "KING" and strupcase(method_str) ne 'LINEAR') then begin
; King profile case
MKHDR, header, difference
sxaddpar, header, 'Height', p(0), 'Convolved King Profile cleanup'
sxaddpar, header, 'Power', p(1), 'Convolved King Profile cleanup'
endif
if (STRUPCASE(typeflag) eq "CIE" and strupcase(method_str) ne 'LINEAR') then begin
; King profile case
MKHDR, header, difference
sxaddpar, header, 'Height', p(0), 'Convolved CIE Profile cleanup'
sxaddpar, header, 'Power', p(1), 'Convolved CIE Profile cleanup'
endif
if (strupcase(method_str) eq 'LINEAR') then begin
	MKHDR, header, difference
	sxaddpar, header, '', 0, 'BBSOs linear sky extrapolation used'
endif
;
WRITEFITS, strcompress(path+'Corrected_image_'+exp_str+'.fit',/remove_all), difference,header
return
end

PRO display_stuff,imin2,im4,observed_image,cleaned_image,difference
common circleSTUFF,circle,radius,moon_coords
window,1,title='Cleaned-up image'
tvscl,cleaned_image
window,2,title='Scattered light image'
tvscl,im4
window,3,title='Observed image'
tvscl,observed_image
window,4,title='Observed - Scattered'
tvscl,observed_image-im4
window,5,title='Slice in residuals'
plot,difference(*,moon_coords(1)/2.),charsize=2,yrange=[-10,30]
return
end

PRO go_postpp,imin,imin2,im4,observed_image,cleaned_image,difference
; This is a post-processing routine - it saves and displays results
; display the results
;display_stuff,imin2,im4,observed_image,cleaned_image,difference
; save results
save_stuff,imin,im4,observed_image,cleaned_image,difference
return
end

PRO get_pdf_CIE,l,pdf,scale
pdf=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r=sqrt((i-l(0)/2)^2+(j-l(1)/2.)^2)
		pdf(i,j)=exp(-abs(r/scale))
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
;surface,rebin(pdf,100,100)
return
end

FUNCTION moonresidual_CIE, X
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
factor=abs(x(0))
scale=x(1)
bias=x(2)
ideal=im1
observed_image=im2
outside=im3
; Step 2 Generate a current guess for the PDF
get_pdf_CIE,l,pdf,scale
; Step 3 Fold the ideal image with the PDF
fold_image_with_pdf,ideal,l,trial_image,pdf
; Step 4 Subtract the folded image from observed_image
im4=(trial_image)*abs(factor)+bias
difference=observed_image-im4
;err= total((difference*observed_image*outside)^2,/double)
err= total((difference*outside)^2,/double)
print,'RMSE/pix=',sqrt(err/n_elements(where(outside ne 0))),' scale=',scale,' factor=',factor,' bias=',bias
dummy=difference*outside
plot,dummy(*,l(1)/2.),charsize=2
RETURN, err
END

PRO get_observed_image,observed_image
common moonres,im1,im2,im3
im1=readfits('ideal_starting_image.fit')
observed_image=readfits('simulated_observed_image.fit')
l=size(observed_image,/dimensions)
contour,alog(im1),/isotropic
;cursor,x1,y1
;wait,0.2
;cursor,x2,y2
;wait,0.2
;cursor,x3,y3
;wait,0.2
x1=147.0 & y1=255.0
x2=275.0 & y2=182.0
x3=144.0 & y3=148.0
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
print,'Fitcircle found:',x0,y0,radius
moon_coords=[x0,y0]
get_circle,l,moon_coords,circle,radius,max(im1)
;----------------------------------------------------------
; Build a composite image of Moon and circle
imin2=im1+circle
tvscl,alog(imin2)
;stop
;----------------------------------------------------------
; find the inside and the outside of the circle around the Moon
find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
im3=outside     ; the skymask
im2=observed_image
return
end
;=================MAIN PROGRAMME==============
; This code models the scattering of light from bright pixels in an image, subtracts the model
; from the image and trie sto minimize the residuals on the part of the image outside the lunar rim.
; This version applies a CIE profile to an image with a bias, and removes it
;---------------------------------------------------------------------------------
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
common method,method_str
common describstr,exp_str
common vizualise,viz
common paths,path
common problem,if_generate_problem
;----------------------------------------------------------
;----------------------------------------------------------
; select the operating system
path=':\Documents and Settings\Peter Thejll\Desktop\ASTRO\'	; Windows at home
path='./'	; i.e. Unix at work
;----------------------------------------------------------
; Select the type of imposed profile
typeflag='GAUSSIAN'
typeflag='KING'
typeflag='CIE'
;----------------------------------------------------------
; select the type of scattered-light removal
; method_str='linear'
method_str='forward'
;----------------------------------------------------------
; Set a descriptive experiment string
;other_str='sydney'
other_str='IDEALIZED'
exp_str=strcompress(typeflag+method_str+other_str,/remove_all)
;----------------------------------------------------------
; set the visualization level
viz=0
;----------------------------------------------------------
; load the 'observed' image
get_observed_image,observed_image
;----------------------------------------------------------
; try to remove the scattered light from "observed_image" using BBSOs linear method
if (strupcase(method_str) eq 'LINEAR') then remove_scattered_light_linear_method,observed_image,clean_image,inside,outside
;----------------------------------------------------------
; try to remove the scattered light from "observed_image" using forward modelling
if (strupcase(method_str) eq 'FORWARD') then remove_scattered_light_forward_modelling,observed_image,clean_image,inside,outside
;--------------------------------------------------------------------------
; Post-processing
go_postpp,im1,imin2,im4,observed_image,clean_image,difference
end
