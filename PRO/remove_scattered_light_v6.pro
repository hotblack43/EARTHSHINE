PRO go_clean_lunar_disc,res,theta,theta_step,clean_image,radii,angle,removed_light
; find the cone of the image that can be corrected using the coefficients in 'res'
;------------------------------------------------------
idx=where(angle gt theta and angle le theta+theta_step)
for i=0,n_elements(idx)-1,1 do begin
	correction=radii(idx(i))*res(1)+res(0)
	clean_image(idx(i))=clean_image(idx(i))-correction
	removed_light(idx(i))=correction
;	print,'Applied correction:',correction,' at radius ',radii(idx(i))
endfor
return
end


PRO go_fit_line,filename,intercept,slope,radius,res,p
; will fit a straight line to th edata in
data=get_data(filename)
number=reform(data(0,*))
theta=reform(data(1,*))
x=reform(data(2,*))
y=reform(data(3,*))
sigs=reform(data(4,*))
idx=where(x gt radius)
res=linfit(x(idx),y(idx),sigma=par_sigs,/double,yfit=yfit,measure_errors=sigs(idx),prob=p)
print,res
window,1,xsize=400,ysize=300
plot,x(idx),y(idx),psym=7,ystyle=1,title='Angle='+string(theta(0)),xtitle='Distance from Moon ctr.'
errplot,x(idx),y(idx)-sigs(idx),y(idx)+sigs(idx)
oplot,x(idx),yfit
if (p gt 0.1) then print,p,' a probable good fit'
if (p le 0.1) then print,p,' NOT a good fit'
return
end

PRO remove_scattered_light_linear_method,observed_image,clean_image,inside,outside
common moonres,im1,im2,im3
common uselater,im4,difference
common fitedresults,P
common type,typeflag
common circleSTUFF,circle,radius,moon_coords
common vizualise,viz
; BBSO - i.e. sky extrapolation - method
; take the image observed_image and generate a correction for the scattered light
; place the corrected image in clean_image
;----------------------------------------------------
clean_image=observed_image
removed_light=clean_image*0.0d0
l=size(observed_image,/dimensions)
x0=moon_coords(0)
y0=moon_coords(1)
rtod=180.0d0/!pi
; fill the fields radius and angle with the values
x=findgen(l(0))
y=findgen(l(1))
xx=rebin(x,[l(0),l(1)])
yy=transpose(rebin(y,[l(1),l(0)]))
radii=sqrt((xx-x0)^2+(yy-y0)^2)
angle=atan((yy-y0),(xx-x0))/!dtor + 180
angle=360 - reverse(angle,1)
xline=xx
yline=yy
if (viz eq 1) then begin
	window,2
	surface,radii,charsize=2
	window,3
	surface,angle,charsize=2
endif
; loopp over angle and radii
nbins=100
binsize=5.
p_lim=0.1
radbins=indgen(nbins)*binsize
theta_step=8.0
fstr='(f8.3,1x,f9.2,1x,f8.3,1x,i5,1x,i2)'
for theta=0.0d0,360.0d0-theta_step,theta_step do begin
	openw,44,'bins.dat'
	print,'Theta=',theta
	for ibin=0,nbins-2,1 do begin
		idx=where(radii ge radbins(ibin) and radii lt radbins(ibin+1) and angle ge theta and angle lt theta+theta_step)
		if (idx(0) ne -1) then begin
;			if (n_elements(idx) ge 4) then print,format=fstr,mean(radii(idx)),mean(observed_image(idx)),stddev(observed_image(idx)),n_elements(idx),(mean(radii(idx)) gt radius)
			if (n_elements(idx) ge 4) then printf,44,ibin,theta,mean(radii(idx)),mean(observed_image(idx)),stddev(observed_image(idx))
	if (viz eq 1) then begin
			window,0
 			im=observed_image
 			im(idx)=max(im)
 			contour,im,/isotropic,/cell_fill,xstyle=1,ystyle=1
	endif
		endif
	endfor	; end ibin
	close,44
	go_fit_line,'bins.dat',intercept,slope,radius,res,p
	if (p gt p_lim) then go_clean_lunar_disc,res,theta,theta_step,clean_image,radii,angle,removed_light
endfor	; end theta
im4=removed_light
difference=observed_image-removed_light
return
end

PRO example2,observed_image,inside,outside,imin2
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
common circleSTUFF,circle,radius,moon_coords
;----------------------------------------------------------------------------------------------------------------------------------------------
; Example 2 - uses a synthetic image and treats itto make a pretend observed image
;
; Read in a moon image
get_imin2,imin,l
window,1,title='Original image'

;----------------------------------------------------------
; Get the right PDF in order to convolve the ideal image and get your fake oberveed image
example_power=2.5
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
;radius=107.
;moon_coords=[200.,200.5]
contour,alog(imin),/isotropic
cursor,x1,y1
wait,0.2
cursor,x2,y2
wait,0.2
cursor,x3,y3
wait,0.2
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
moon_coords=[x0,y0]
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
im2=observed_image

return
end

PRO example1,observed_image,inside,outside,imin2
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
common circleSTUFF,circle,radius,moon_coords
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
radius=110.9d0
moon_coords=[176,260]
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
im4=trial_image*height
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

PRO remove_scattered_light_forward_modelling,observed_image,clean_image,inside,outside
common moonres,im1,im2,im3
common uselater,im4,difference
common fitedresults,P
common type,typeflag
common describstr,exp_str
; take the image observed_image and generate a correction for the scattered light
; place the corrected image in clean_image
;----------------------------------------------------
l=size(observed_image,/dimensions)
; Define the fractional tolerance:
ftol = 1.0e-4
; Define the starting point:
;if (file_test('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_King.dat') eq 0) then begin
if (file_test('bestfit_King.dat') eq 0) then begin
	trial_sigma=233.5381
	factor=   8000.5381
ENDIF  ELSE BEGIN
if (STRUPCASE(typeflag) eq "GAUSSIAN") then begin
	openr,83,'bestfit_Gaussian.dat'
	;openr,83,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_Gaussian.dat'
	readf,83,trial_sigma,factor	; Gaussian case
	print,'Read from bestfit_Gaussian.dat'
endif
if (STRUPCASE(typeflag) eq "KING") then begin
		;openr,83,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_King.dat'
		openr,83,'bestfit_King.dat'
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
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  begin
	POWELL, P, xi, ftol, fmin, 'moonresidual_Gaussian',/double,itmax=20
endif
if (STRUPCASE(typeflag) eq "KING") then  begin
	POWELL, P, xi, ftol, fmin, 'moonresidual_King',/double,itmax=20
endif
	writefits,strcompress('Last_subtracted_image_'+exp_str+'.fit',/remove_all),im4
	writefits,strcompress('Last_subtracted_image_'+exp_str+'.fit',/remove_all),long(im4)
; Print the solution point:
PRINT, 'Solution point: ', P
if (STRUPCASE(typeflag) eq "GAUSSIAN") then  openw,83,'bestfit_Gaussian.dat'
;if (STRUPCASE(typeflag) eq "GAUSSIAN") then  openw,83,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_Gaussian.dat'
if (STRUPCASE(typeflag) eq "KING") then  openw,83,'bestfit_King.dat'
;if (STRUPCASE(typeflag) eq "KING") then  openw,83,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\bestfit_King.dat'
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
;imin=readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\LunarImg_0001.fts')
imin=readfits('LunarImg_0001.fts')
;imin=readfits('ANDREW/DATA/moon20060731.00000168.FIT')
imin=congrid(imin,400,400)
l=size(imin,/dimensions)
writefits,'EX2_ideal_image_input_400x400.fit',imin
writefits,'EX2_ideal_image_input_400x400_LONG.fit',long(imin)
return
end

PRO get_imin,imin,l
;imin=readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_ChrisAlg_PeterStack_349_float.FIT')
;l=size(imin,/dimensions)
;width=20
;imin=double(imin(width:l(0)-width-1,width:l(1)-width-1))
imin=readfits('ANDREW/stacked_new_349_float.FIT')
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
common circleSTUFF,circle,radius,moon_coords
window,1,title='Cleaned-up image'
tvscl,cleaned_image
window,2,title='Scattered light image'
tvscl,im4
window,3,title='Observed image'
tvscl,observed_image
window,4,title='Observed - Scattered'
tvscl,difference
window,5,title='Slice in residuals'
plot,difference(*,moon_coords(1)/2.),charsize=2,yrange=[-10,30]
return
end

PRO save_stuff,imin,im4,observed_image,cleaned_image,difference
common method,method_str
common fitedresults,P
common type,typeflag
common describstr,exp_str
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
if (strupcase(method_str) eq 'LINEAR') then begin
	MKHDR, header, difference
	sxaddpar, header, '', 0, 'BBSOs linear sky extrapolation used'
endif
;
WRITEFITS, strcompress('Corrected_image_'+exp_str+'.fit',/remove_all), difference,header
WRITEFITS, strcompress('Corrected_image_'+exp_str+'_LONG.fit',/remove_all), long(difference),header
return
end

;=================MAIN PROGRAMME==============
; This code models the scattering of light from bright pixels in an image, subtracts the model
; from the image and trie sto minimize the residuals on the part of the image outside the lunar rim.
; Several examples are provided for different types of experiments:
;...................
; Example 1 uses a real observed image and treats it to generate a surrogate 'ideal image' which is used
; as the image to convolve various PDFs with.
;...................
; Example 2 uses a synthetic image from eshine_15.pro as input (adds scattered light from a selected PDF) and the same
; synthetic image of the Moon to fold with various PDFs.
;...................
; Example 3 uses a real image and a synthetic image as the ideal image
;---------------------------------------------------------------------------------
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
common method,method_str
common describstr,exp_str
common vizualise,viz
;----------------------------------------------------------
; Select the type of imposed profile
typeflag='KING'
typeflag='GAUSSIAN'
;----------------------------------------------------------
; select the type of scattered-light removal
method_str='forward'
method_str='linear'
;----------------------------------------------------------
; Set a descriptive experiment string
other_str='sydney'
exp_str=strcompress(typeflag+method_str+other_str,/remove_all)
;----------------------------------------------------------
; set the visualization level
viz=0
;----------------------------------------------------------
; Select the type of example you want:
example1,observed_image,inside,outside,imin2	; Ex. 1 uses a real image and treats it to make a pretend ideal image
;example2,observed_image,inside,outside,imin2	; Ex. 2 uses an ideal image and treats it to make a pretend observation
;----------------------------------------------------------
; try to remove the scattered light from "observed_image" using forward modelling
if (strupcase(method_str) eq 'FORWARD') then remove_scattered_light_forward_modelling,observed_image,clean_image,inside,outside
; try to remove the scattered light from "observed_image" using BBSOs linear method
if (strupcase(method_str) eq 'LINEAR') then remove_scattered_light_linear_method,observed_image,clean_image,inside,outside
;--------------------------------------------------------------------------
; Post-processing
go_postpp,im1,imin2,im4,observed_image,clean_image,difference
end
