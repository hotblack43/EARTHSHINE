
PRO fold_image_with_pdf,imin,l,folded_image,pdf
common haveIdonethis,iflag,imagefft
if (iflag ne 314) then begin
	imagefft=fft(imin,-1,/double)
	iflag=314
endif
folded_image=fft(imagefft*fft(pdf,-1,/double),1,/double)
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



PRO generate_two_arrays,ncols,nrows,row,col
row=transpose(indgen(nrows))
for i=0,ncols-2,1 do row=[row,transpose(indgen(nrows))]
col=indgen(ncols)
for i=0,nrows-2,1 do col=[[col],[indgen(ncols)]]
return
end

PRO get_pdf_King,l,pdf,power
; first set up the arrays that indicate column and row numbers
common radius,radius
ncols=l(0)
nrows=l(1)
generate_two_arrays,ncols,nrows,row,col
;
pp=power
;
half_i=l(0)/2.
half_j=l(1)/2.
;
deltax=col-half_i
deltay=row-half_j
radius=sqrt(deltax^2+deltay^2)
pdf=dblarr(l(0),l(1))*0.0d0+1.0d0
idx=where(radius gt 1.0)
pdf(idx)=1./radius(idx)^pp
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2.,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
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
get_photometric_ratio,difference,ratio3
print,'In the corrected image the BS/ES ratio is     :',ratio3
printf,58,ratio3
err= total((difference*outside)^2,/double)
print,'MSE/pix=',(err/n_elements(where(outside ne 0))),' scale=',scale,' factor=',factor,' bias=',bias
dummy=difference*outside
plot,dummy(*,l(1)/2.),charsize=2
return, err
END

FUNCTION calculate_THINGb,l,scale,type
; special function to calculate derivatives
common radius,radius
;thing=dblarr(l(0),l(1))
pp=(scale)
if (type eq 1) then begin
	thing=1.0d0/radius^pp
	idx=where(finite(thing) ne 1)
	if (idx(0) ne -1) then thing(idx)=0.0d0
endif ; end of type=1
if (type eq 2) then begin
	thing=alog(radius)/radius^pp
	idx=where(finite(thing) ne 1)
	if (idx(0) ne -1) then thing(idx)=0.0d0
endif ; end of type=2
return, THING
end



FUNCTION moonresidual_King_derivative_2,X
; calculates the derivate assuming the pdf goes as 1/(radius^p)
common moonres,im1,im2,im3
common uselater,im4,difference
l=size(im1,/dimensions)
factor=x(0)
scale=x(1)
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
get_photometric_ratio,difference,ratio3
print,'In the corrected image the BS/ES ratio is     :',ratio3
printf,58,ratio3
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
power=abs(x(1))
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
get_photometric_ratio,difference,ratio3
print,'In the corrected image the BS/ES ratio is     :',ratio3
printf,58,ratio3
err= total((difference*outside)^2,/double)
print,'MSE/pix=',(err/n_elements(where(outside ne 0))),' power=',power,' factor=',factor,' bias=',bias
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
get_photometric_ratio,difference,ratio3
print,'In the corrected image the BS/ES ratio is     :',ratio3
printf,58,ratio3
err= total((difference*outside)^2,/double)
print,'MSE/pix=',(err/n_elements(where(outside ne 0))),' scale=',scale,' factor=',factor,' bias=',bias
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
common lineandpoint,line,point1
inside=intarr(l)
outside=intarr(l)
radius2=radius^2
;..........
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2= (i-CENTER(0))^2+(j-CENTER(1))^2
		if (r2 gt radius2 and test_if_same_side(line,point1,[i,j,0]) eq 1) then outside(i,j)=1 ELSE inside(i,j)=1
		;if (r2 gt radius2) then outside(i,j)=1 ELSE inside(i,j)=1
	endfor
endfor
idx_inside=where(inside eq 1)
idx_outside=where(outside eq 1)
return
end

PRO get_photometric_ratio,image,ratio
common boxes,x1,y1,x2,y2,x3,x4
patch1=mean(image(x1:x2,y1:y2))
patch2=mean(image(x3:x4,y1:y2))
ratio=patch2/patch1
return
end

PRO get_observed_image,observed_image,ideal_image_name,observed_image_name
common moonres,im1,im2,im3
common ideal,cutoff
common circleSTUFF,circle,radius,moon_coords
; Read in the designated 'observed' image
observed_image=readfits(observed_image_name)
; either generate the 'ideal' image from the observed one...
get_ideal_image,observed_image,im1
; or read it in froma  file .. NOT BOTH!!!!!
;im1=readfits(ideal_image_name)
l=size(observed_image,/dimensions)
contour,alog(im1),/isotropic,nlevels=101
if (file_test('moon_circle_data.dat') ne 1) then begin
cursor,x1a,y1a
wait,0.2
cursor,x2a,y2a
wait,0.2
cursor,x3a,y3a
wait,0.2
openw,45,'moon_circle_data.dat'
printf,45,x1a,y1a
printf,45,x2a,y2a
printf,45,x3a,y3a
close,45
endif
if (file_test('moon_circle_data.dat') eq 1) then begin
openr,45,'moon_circle_data.dat'
readf,45,x1a,y1a
readf,45,x2a,y2a
readf,45,x3a,y3a
close,45
endif
fitcircle3points,x1a,y1a,x2a,y2a,x3a,y3a,x0,y0,radius
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
;........... get some photometry from ideal and observed image:
get_photometric_ratio,observed_image,ratio2
print,'In the observed image the BS/ES ratio is:',ratio2
printf,58,ratio2
get_photometric_ratio,im1,ratio1
print,'In the ideal image the BS/ES ratio is     :',ratio1
printf,58,ratio1
;..........................................................................
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
common haveIdonethis,iflag,imagefft
common boxes,x1,y1,x2,y2,x3,x4
common lineandpoint,line,point1
iflag=0
;----------------------------------------------------------
; Set up the coordinates of the photometric boxes on the ES and BS
; x1=135 &x2=158 & x3=230 &x4=255 &y1=187 & y2=211 ; suitable for 400x400 image
; x1=32 &x2=67 & x3=100 &x4=125 &y1=65 & y2=100 ; suitable for sydney_2x2.fit
x1=164 & x2=171 & x3=844 & x4=851 & y1=465 & y2=485 ; suitable for centered 1025x1025 image
;----------------------------------------------------------
; To enable fitting in just some part of the image, a 'line' through the image
; and a point in the image are set up - other pixels are then tested
; against the line and the point to see if the pixels are on the same side
; of the line as the point, if they are that pixel is allowed for minimising on
line=[-10,0,-10,100]	; is defined by the x,y coords of two points on the line
point1=[10,10]
;----------------------------------------------------------
; select the operating system
path='./'	; i.e. Unix at work
path='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\'	; Windows at home
;----------------------------------------------------------
; Select the type of imposed profile
typeflag='GAUSSIAN'

typeflag='CIE'
typeflag='KING'
;----------------------------------------------------------
; select the type of scattered-light removal
method_str='forward'
method_str='linear'
; select whether initial optimization by POWELL is required
yes_POWELL=1	; applies to FORWARD method only, ignored otherwise
 ;----------------------------------------------------------
; Set a descriptive experiment string
;other_str='sydney'
other_str='IDEALIZED'
exp_str=strcompress(typeflag+method_str+other_str,/remove_all)
;----------------------------------------------------------
; set the visualization level
viz=0
;----------------------------------------------------------
; load the ideal image
files=file_search('H:\aaRAW\ideal_*.fit',count=nfiles)
; read PDF parameters
		openr,83,path+'bestfit_'+typeflag+'.dat'
		readf,83,height,scale,bias	; CIE profile case
		print,'Read from bestfit_'+typeflag+'.dat'
		close,83
for ifile=0,nfiles-1,1 do begin
ideal=readfits(files(ifile))
l=size(ideal,/dimensions)

; Step 2 Generate a current guess for the PDF
get_pdf_CIE,l,pdf,scale
; Step 3 Fold the ideal image with the PDF to generate the observed image
	fold_image_with_pdf,ideal,l,observed_image,pdf
	observed_image=observed_image*1e6*500.
	number=strmid(files(ifile),24,4)
	outname=strcompress('H:\Processed\'+typeflag+'_'+number+'.fit',/remove_all)
	writefits,outname,observed_image
	print,files(ifile),outname
endfor ; end of loop over images
end


