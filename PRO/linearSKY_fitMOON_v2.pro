
PRO go_do_regression,res,xin,yin,par_sigs,yfit,sigsin,p
x=xin
y=yin
sigs=sigsin
res=linfit(x,y,sigma=par_sigs,/double,yfit=yfit,measure_errors=sigs,prob=p)
residuals=abs(y-yfit)
; find and remove wrost deviating point
ipointer=where(residuals lt max(residuals))
x=x(ipointer)
y=y(ipointer)
sigs=sigs(ipointer)
res=linfit(x,y,sigma=par_sigs,/double,yfit=yfit,measure_errors=sigs,prob=p)
return
end

PRO go_clean_lunar_disc,res,theta,theta_step,clean_image,radii,angle,removed_light
; find the cone of the image that can be corrected using the coefficients in 'res'
;------------------------------------------------------
idx=where(angle gt theta and angle le theta+theta_step)
for i=0,n_elements(idx)-1,1 do begin
	correction=radii(idx(i))*res(1)+res(0)
	clean_image(idx(i))=clean_image(idx(i))-correction
	removed_light(idx(i))=correction
endfor
return
end


PRO go_fit_line,filename,intercept,slope,radius,res,p
; will fit a straight line to th edata in
data=get_data(filename)
number=reform(data(0,*))
theta=reform(data(1,*))
x=double(reform(data(2,*)))
y=double(reform(data(3,*)))
sigs=double(reform(data(4,*)))
idx=where(x gt radius*1.03 and x lt radius*1.15)
if (idx(0) ne -1) then begin
;go_do_regression,res,x(idx),y(idx),par_sigs,yfit,sigs(idx),p
res=robust_linefit(x(idx),y(idx))
yfit=res(0)+res(1)*x(idx)
;res=linfit(x(idx),y(idx),sigma=par_sigs,/double,yfit=yfit,measure_errors=sigs(idx),prob=p)
window,1,xsize=400,ysize=300
plot,x(idx),y(idx),psym=7,ystyle=1,title='Angle='+string(theta(0)),xtitle='Distance from Moon ctr.'
errplot,x(idx),y(idx)-sigs(idx),y(idx)+sigs(idx)
oplot,x(idx),yfit
if (p gt 0.1) then print,p,' a probable good fit'
if (p le 0.1) then print,p,' NOT a good fit'
endif
return
end


PRO remove_scattered_light_linear_method,observed_image,clean_image,inside,outside
common moonres,im1,im2,im3
common uselater,im4,difference
common fitedresults,P
common type,typeflag
common circleSTUFF,circle,radius,moon_coords
common vizualise,viz
common paths,path
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
x=dindgen(l(0))
y=dindgen(l(1))
xx=rebin(x,[l(0),l(1)])
yy=transpose(rebin(y,[l(1),l(0)]))
radii=sqrt((xx-x0)^2+(yy-y0)^2)
angle=atan((yy-y0),(xx-x0))/!dtor + 180
angle=360 - reverse(angle,1)
xline=xx
yline=yy
; loop over angle and radii
nbins=100
binsize=4.
p_lim=0.01
radbins=indgen(nbins)*binsize
theta_step=9.0
fstr='(f8.3,1x,f9.2,1x,f8.3,1x,i5,1x,i2)'
p=-0.0
for theta=0.0d0,360.0d0-theta_step,theta_step do begin
	openw,44,path+'bins.dat'
	print,'Theta=',theta
	for ibin=0,nbins-2,1 do begin
		idx=where(radii ge radbins(ibin) and radii lt radbins(ibin+1) and angle ge theta and angle lt theta+theta_step)
		if (idx(0) ne -1) then begin
			if (n_elements(idx) ge 4) then printf,44,ibin,theta,mean(radii(idx)),mean(observed_image(idx)),stddev(observed_image(idx))/sqrt(n_elements(idx))
		endif
	endfor	; end ibin
	close,44
	go_fit_line,path+'bins.dat',intercept,slope,radius,res,p
	if (p gt p_lim) then go_clean_lunar_disc,res,theta,theta_step,clean_image,radii,angle,removed_light
endfor	; end theta

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
contour,cleaned_image,/isotropic
;tvscl,cleaned_image
window,2,title='Scattered light image'
;tvscl,im4
contour,im4,/isotropic
window,3,title='Observed image'
contour,observed_image,/isotropic
;tvscl,observed_image
window,4,title='Observed - Scattered'
contour,observed_image-im4,/isotropic
;tvscl,observed_image-im4
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


PRO generate_two_arrays,ncols,nrows,row,col
row=transpose(indgen(nrows))
for i=0,ncols-2,1 do row=[row,transpose(indgen(nrows))]
col=indgen(ncols)
for i=0,nrows-2,1 do col=[[col],[indgen(ncols)]]
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
		if (r2 gt radius2) then outside(i,j)=1 ELSE inside(i,j)=1
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

PRO get_observed_image,observed_image,observed_image_name,header
common moonres,im1,im2,im3
common ideal,cutoff
common circleSTUFF,circle,radius,moon_coords
; Read in the designated 'observed' image
cube=readfits(observed_image_name,header)
observed_image=reform(cube(*,*,0))
l=size(observed_image,/dimensions)
contour,observed_image,/isotropic
         get_info_from_header,header,'DISCX0',x0
         get_info_from_header,header,'DISCY0',y0
         get_info_from_header,header,'RADIUS',radius
	 moon_coords=[x0,y0]
;----------------------------------------------------------
; find the inside and the outside of the circle around the Moon
find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
im3=outside     ; the skymask
im2=observed_image
return
end

;=================MAIN PROGRAMME==============
; This code removes scattered light with the linear BBSO method
; version 2
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
;----------------------------------------------------------
; Set up the coordinates of the photometric boxes on the ES and BS
;x1=164 &x2=171 & x3=844 &x4=851 &y1=465 & y2=485 ; suitable for 1025x1025, centered
;
x1=72 & x2=82 & y1=238 & y2=275	; suitable for 512x512, centered
x3=433 & x4=439 & y3=230 & y4=287

;----------------------------------------------------------
; set the path to the data IN directoru
path='./'	; i.e. Unix at work
path='/media/thejll/OLDHD/CUBES/'	; i.e. Unix at home
;----------------------------------------------------------
; select the type of scattered-light removal
method_str='linear'
;----------------------------------------------------------
namestring='cube_'
;----------------------------------------------------------
; load the 'observed' image
;files=file_search(strcompress(path+namestring+'*.fits',/remove_all),count=nfiles)
files='/media/thejll/OLDHD/CUBES/cube_2456017.7518360_B_.fits'
nfiles=1
if (nfiles eq 0) then stop
for ifile=0,nfiles-1,1 do begin
	print,files(ifile)
	get_observed_image,observed_image,files(ifile),header
;----------------------------------------------------------
; try to remove the scattered light from "observed_image" using BBSOs linear method
	if (strupcase(method_str) eq 'LINEAR') then begin
		remove_scattered_light_linear_method,observed_image,cleaned_image,inside,outside
; update the header
		sxaddpar, header, 'LINEAR', 0, 'BBSO linear cleaning method'
	endif
;----------------------------------------------------------
	filename=strcompress(path+'BBSO_cleaned_'+strmid(files(ifile),strlen(files(ifile))-9,9),/remove_all)
	writefits,filename,cleaned_image,header
        print,'Wrote file: ',filename
endfor	; end of ifile loop
end


