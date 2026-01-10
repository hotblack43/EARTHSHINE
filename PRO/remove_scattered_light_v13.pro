PRO get_ideal_image,input_image,ideal_image
; Will generate an 'ideal image' from an observed
; image by cutting away low pixels
common ideal,cutoff
ideal_image=(input_image gt cutoff*max(input_image))*input_image
return
end

PRO remove_scattered_light_forward_modelling,observed_image,cleaned_image,inside,outside
common moonres,im1,im2,im3
common uselater,im4,difference
common fitedresults,P
common type,typeflag
common describstr,exp_str
common paths,path
common POWELL,yes_POWELL
; take the image observed_image and generate a correction for the scattered light
; place the corrected image in cleaned_image
;----------------------------------------------------
l=size(observed_image,/dimensions)
; Define the fractional tolerance:
ftol = 1.0e-8
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
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  P = [trial_sigma,factor,bias] ; Gaussian case
if (STRUPCASE(typeflag) eq "KING") then P=[height,power,bias]	; King profile case
if (STRUPCASE(typeflag) eq "CIE") then P=[height,scale,bias]	; CIE profile case

; Define the starting directional vectors in column format:
xi = TRANSPOSE([[1.,0.,0.],[0.,1.,0.],[0.,0.,1.]])

   ; Minimize the function:
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  begin
	POWELL, P, xi, ftol, fmin, 'moonresidual_Gaussian',/double,itmax=20
endif
if (STRUPCASE(typeflag) eq "KING") then  begin
if (yes_POWELL eq 1) then	POWELL, P, xi, ftol, fmin, 'moonresidual_King',/double
	DFPMIN, P, ftol, Fmin, 'moonresidual_King', 'moonresidual_King_derivative_2' , $
	 /DOUBLE,iter=iter,stepmax=1000.
	print,'Performed ',iter,' iterations.'
endif
if (STRUPCASE(typeflag) eq "CIE") then  begin
	POWELL, P, xi, ftol, fmin, 'moonresidual_CIE',/double,itmax=20
endif
	writefits,path+'Last_subtracted_image_'+exp_str+'.fit',im4
	writefits,path+'Last_subtracted_image_long'+exp_str+'.fit',long(im4)
; Print the solution point:
PRINT, 'Solution point: ', P
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  openw,83,path+'bestfit_Gaussian.dat'
if (STRUPCASE(typeflag) eq "KING") then  openw,83,path+'bestfit_King.dat'
if (STRUPCASE(typeflag) eq "CIE") then  openw,83,path+'bestfit_CIE.dat'
printf,83,abs(p)
close,83
print,'Best fit saved'
cleaned_image=difference
return
end

PRO fold_image_with_pdf,imin,l,folded_image,pdf
folded_image=fft(fft(imin,-1,/double)*fft(pdf,-1,/double),1,/double)
folded_image=sqrt(folded_image*conj(folded_image))
folded_image=double(folded_image)
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
MKHDR, header, cleaned_image
MKHDR, header2, difference
MKHDR, header3, im4
sxaddpar, header, 'Sigma', p(0), 'Convolved Gaussian cleanup'
sxaddpar, header, 'Factor', p(1), 'Convolved Gaussian cleanup'
sxaddpar, header3, 'Sigma', p(0), 'Convolved Gaussian cleanup'
sxaddpar, header3, 'Factor', p(1), 'Convolved Gaussian cleanup'

endif
if (STRUPCASE(typeflag) eq "KING" and strupcase(method_str) ne 'LINEAR') then begin
; King profile case
MKHDR, header, cleaned_image
MKHDR, header2, difference
MKHDR, header3, im4
sxaddpar, header, 'Height', p(0), 'Convolved King Profile cleanup'
sxaddpar, header, 'Power', p(1), 'Convolved King Profile cleanup'
sxaddpar, header3, 'Height', p(0), 'Convolved King Profile cleanup'
sxaddpar, header3, 'Power', p(1), 'Convolved King Profile cleanup'
endif
if (STRUPCASE(typeflag) eq "CIE" and strupcase(method_str) ne 'LINEAR') then begin
; King profile case
MKHDR, header, cleaned_image
MKHDR, header2, difference
MKHDR, header3, im4
sxaddpar, header, 'Height', p(0), 'Convolved CIE Profile cleanup'
sxaddpar, header, 'Power', p(1), 'Convolved CIE Profile cleanup'
sxaddpar, header3, 'Height', p(0), 'Convolved CIE Profile cleanup'
sxaddpar, header3, 'Power', p(1), 'Convolved CIE Profile cleanup'
endif
if (strupcase(method_str) eq 'LINEAR') then begin
	MKHDR, header, cleaned_image
	MKHDR, header2, difference
		sxaddpar, header, '', 0, 'BBSOs linear sky extrapolation used'
endif
;
;WRITEFITS, strcompress(path+'Corrected_image_'+exp_str+'.fit',/remove_all), cleaned_image,header
;WRITEFITS, strcompress(path+'residuals_image.fit',/remove_all), difference,header2
WRITEFITS, path+'Corrected_image_'+exp_str+'.fit', cleaned_image,header
WRITEFITS, path+'Corrected_image__long_'+exp_str+'.fit', long(cleaned_image),header
WRITEFITS, path+'residuals_image.fit', difference,header2
WRITEFITS, path+'last_subtracted_model.fit', im4,header3
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


PRO get_pdf_King,l,pdf,power
pdf=dblarr(l(0),l(1))
pp=(power)
half_i=l(0)/2.
half_j=l(1)/2.
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		deltax=(i-half_i)
		deltay=(j-half_j)
		radius=sqrt(deltax^2+deltay^2)
		if (radius gt 1.0) then pdf(i,j)=1./radius^pp else pdf(i,j)=1.0d0
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
power=(power)
return
end

PRO get_pdf_Gaussian,l,pdf,sigma
pdf=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2=(i-l(0)/2)^2+(j-l(1)/2.)^2
		pdf(i,j)=exp(-r2/abs(sigma))
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
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


FUNCTION moonresidual_Gaussian, X
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
scale=x(0)
factor=abs(x(1))
bias=x(2)
ideal=im1
observed_image=im2
outside=im3
; Step 2 Generate a current guess for the PDF
get_pdf_Gaussian,l,pdf,scale
; Step 3 Fold the ideal image with the PDF
fold_image_with_pdf,ideal,l,trial_image,pdf
; Step 4 Subtract the folded image from observed_image
im4=(trial_image)*abs(factor)+bias
difference=observed_image-im4
err= total((difference*outside)^2,/double)
print,'RMSE/pix=',sqrt(err/n_elements(where(outside ne 0))),' scale=',scale,' factor=',factor,' bias=',bias
dummy=difference*outside
plot,dummy(*,l(1)/2.),charsize=2
return, err
END

FUNCTION calculate_THINGb,l,scale,type
; special function to calculate derivatives
thing=dblarr(l(0),l(1))
pp=(scale)
half_i=l(0)/2.
half_j=l(1)/2.
if (type eq 1) then begin
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		deltax=(i-half_i)
		deltay=(j-half_j)
		radius=sqrt(deltax^2+deltay^2)
		thing(i,j)=1./radius^pp
	endfor
endfor
idx=where(finite(thing) ne 1)
thing(idx)=0.0d0
endif ; end of type=1
if (type eq 2) then begin
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		deltax=(i-half_i)
		deltay=(j-half_j)
		radius=sqrt(deltax^2+deltay^2)
		thing(i,j)=alog(radius)/radius^pp
	endfor
endfor
idx=where(finite(thing) ne 1)
thing(idx)=0.0d0
endif ; end of type=2
return, THING
end

FUNCTION calculate_THING,l,scale
; special function to calculate derivative of PDF wrwt. 'scale'
thing=dblarr(l(0),l(1))
pp=(scale)
half_i=l(0)/2.
half_j=l(1)/2.
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		deltax=abs(i-half_i)
		deltay=abs(j-half_j)
		thing(i,j)=-(deltay^pp*alog(deltay)+deltax^pp*alog(deltax))/(deltax^pp+deltay^pp)^2
	endfor
endfor
idx=where(finite(thing) ne 1)
thing(idx)=0.0d0
return, THING
end

FUNCTION moonresidual_King_derivative_1,X
; calculates the derivate assuming the pdf goes as 1/(deltax^p+deltay^p)
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
factor=(x(0))
scale=(x(1))
bias=x(2)
ideal=im1
observed_image=im2
outside=im3
; Step 2 Generate a current guess for the PDF
get_pdf_King,l,pdf,scale
; Step 3 Fold the ideal image with the PDF
fold_image_with_pdf,ideal,l,trial_image,pdf
; Step 4 Subtract the folded image from observed_image
im4=(trial_image)*(factor)+bias
difference=observed_image-im4
; set up the three derivatives
idx_outside_circle=where(outside ne 0)
derrdpar0=-2.0d0*total(trial_image(idx_outside_circle)*difference(idx_outside_circle),/double)
THING=calculate_THING(l,scale)
derrdpar1=-2.0d0*factor*total(THING(idx_outside_circle)*difference(idx_outside_circle),/double)
derrdpar2=-2.0d0*total(difference(idx_outside_circle),/double)
print,derrdpar0,derrdpar1,derrdpar2
return, [derrdpar0,derrdpar1,derrdpar2]
END

FUNCTION moonresidual_King_derivative_2,X
; calculates the derivate assuming the pdf goes as 1/(radius^p)
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
factor=(x(0))
scale=(x(1))
bias=x(2)
ideal=im1
observed_image=im2
outside=im3
; Step 2 Generate a current guess for the PDF
get_pdf_King,l,pdf,scale
; Step 3 Fold the ideal image with the PDF
fold_image_with_pdf,ideal,l,trial_image,pdf
; Step 4 Subtract the folded image from observed_image
im4=(trial_image)*(factor)+bias
difference=observed_image-im4
; set up the three derivatives
idx_outside_circle=where(outside ne 0)
THING1=calculate_THINGb(l,scale,1)
derrdpar0=-2.0d0*total(THING1*difference(idx_outside_circle),/double)
THING2=calculate_THINGb(l,scale,2)
derrdpar1=+2.0d0*factor*total(THING2*difference(idx_outside_circle),/double)
derrdpar2=-2.0d0*total(difference(idx_outside_circle),/double)
print,derrdpar0,derrdpar1,derrdpar2
return, [derrdpar0,derrdpar1,derrdpar2]
END


FUNCTION moonresidual_KING, X
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
factor=(x(0))
power=x(1)
bias=x(2)
ideal=im1
observed_image=im2
outside=im3
; Step 2 Generate a current guess for the PDF
get_pdf_King,l,pdf,power
; Step 3 Fold the ideal image with the PDF
fold_image_with_pdf,ideal,l,trial_image,pdf
; Step 4 Subtract the folded image from observed_image
im4=(trial_image)*(factor)+bias
difference=observed_image-im4
;err= total((difference*observed_image*outside)^2,/double)
err= total((difference*outside)^2,/double)
print,'RMSE/pix=',sqrt(err/n_elements(where(outside ne 0))),' power=',power,' factor=',factor,' bias=',bias
dummy=difference*outside
plot,dummy(*,l(1)/2.),charsize=2
return, err
END

FUNCTION moonresidual_CIE, X
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
factor=(x(0))
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
im4=(trial_image)*(factor)+bias
difference=observed_image-im4
err= total((difference*outside)^2,/double)
print,'RMSE/pix=',sqrt(err/n_elements(where(outside ne 0))),' scale=',scale,' factor=',factor,' bias=',bias
dummy=difference*outside
plot,dummy(*,l(1)/2.),charsize=2
return, err
END

PRO fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
; Fits a circle that passes through the three designated coordinates
a=[[x1,y1,1.0],[x2,y2,1.0],[x3,y3,1.0]]
d=[[x1*x1+y1*y1,y1,1.0],[x2*x2+y2*y2,y2,1.0],[x3*x3+y3*y3,y3,1.0]]
e=[[x1*x1+y1*y1,x1,1.0],[x2*x2+y2*y2,x2,1.0],[x3*x3+y3*y3,x3,1.0]]
f=[[x1*x1+y1*y1,x1,y1],[x2*x2+y2*y2,x2,y2],[x3*x3+y3*y3,x3,y3]]
a=determ(a,/check,/double)
d=-determ(d,/check,/double)
e=determ(e,/check,/double)
f=-determ(f,/check,/double)
;
x0=-d/2./a
y0=-e/2./a
radius=sqrt((d*d+e*e)/4./a/a-f/a)
return
end

PRO get_circle,l,coords,circle,radius,maxval
circle=dblarr(l)*0.0
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

PRO find_circle_inside_outside,radius,CENTER,inside,outside,l,idx_inside,idx_outside
inside=intarr(l)
outside=intarr(l)
radius2=radius^2
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2= (i-CENTER(0))^2+(j-CENTER(1))^2
		if (r2 gt radius2 and r2 lt 1.5*radius2) then outside(i,j)=1 ELSE inside(i,j)=1
	endfor
endfor
idx_inside=where(inside eq 1)
idx_outside=where(outside eq 1)
return
end

PRO get_observed_image,observed_image
common moonres,im1,im2,im3
common ideal,cutoff
;im1=readfits('ideal_starting_image.fit')
;observed_image=readfits('simulated_observed_image.fit')
observed_image=double(readfits('sydney_2x2.fit'))
get_ideal_image,observed_image,im1
l=size(observed_image,/dimensions)
contour,alog(im1),/isotropic,nlevels=101
if (file_test('moon_circle_data.dat') ne 1) then begin
cursor,x1,y1
wait,0.2
cursor,x2,y2
wait,0.2
cursor,x3,y3
wait,0.2
openw,45,'moon_circle_data.dat'
printf,45,x1,y1
printf,45,x2,y2
printf,45,x3,y3
close,45
endif
if (file_test('moon_circle_data.dat') eq 1) then begin
openr,45,'moon_circle_data.dat'
readf,45,x1,y1
readf,45,x2,y2
readf,45,x3,y3
close,45
endif
;x1=147.0 & y1=255.0
;x2=275.0 & y2=182.0
;x3=144.0 & y3=148.0
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
print,'Fitcircle found:',x0,y0,radius
get_lun,unit
openw,unit,'Circle.dat'
printf,unit,x0,y0,radius
close,unit
free_lun,unit
moon_coords=[x0,y0]
get_circle,l,moon_coords,circle,radius,max(im1)
;----------------------------------------------------------
; Build a composite image of Moon and circle
tvscl,alog(im1+circle)
print,'Inspect image, then press key (any key) to proceed.'
dummy=get_kbrd()
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
common POWELL,yes_POWELL
common ideal,cutoff
;----------------------------------------------------------
; select the operating system

path='./'	; i.e. Unix at work
path='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\'	; Windows at home
;----------------------------------------------------------
; Select the type of imposed profile
typeflag='CIE'
typeflag='GAUSSIAN'
typeflag='KING'
;----------------------------------------------------------
; select the type of scattered-light removal
method_str='linear'
method_str='forward'
; select whether initial optimization by POWELL is required
yes_POWELL=1
 ;----------------------------------------------------------
; Set a descriptive experiment string
;other_str='sydney'
other_str='IDEALIZED'
exp_str=strcompress(typeflag+method_str+other_str,/remove_all)
;----------------------------------------------------------
; set the visualization level
viz=0
; set the cutoff level in generating 'ideal' from 'observed'
cutoff=0.05
;----------------------------------------------------------
; load the 'observed' image
get_observed_image,observed_image
;----------------------------------------------------------
; try to remove the scattered light from "observed_image" using BBSOs linear method
if (strupcase(method_str) eq 'LINEAR') then remove_scattered_light_linear_method,observed_image,cleaned_image,inside,outside
;----------------------------------------------------------
; try to remove the scattered light from "observed_image" using forward modelling
if (strupcase(method_str) eq 'FORWARD') then remove_scattered_light_forward_modelling,observed_image,cleaned_image,inside,outside
;--------------------------------------------------------------------------
; Post-processing
go_postpp,im1,dummy,im4,observed_image,cleaned_image,difference
end


