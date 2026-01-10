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
     openw,44,path+'bins.dat'
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
 get_photometric_ratio,difference,ratio5
 print,'In the corrected image the BS/ES ratio is     :',ratio5
 printf,58,ratio5
 return
 end
 
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
     trial_sigma=2.381
     factor=   100.5381
     bias=10.0
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
     /DOUBLE,iter=iter ,EPS=1.0d-16
     print,'Performed ',iter,' iterations. Fmin was:',Fmin
     DFPMIN, P, ftol, Fmin, 'moonresidual_King', 'moonresidual_King_derivative_2' , $
     /DOUBLE,iter=iter ,EPS=1.0d-16
     print,'Performed ',iter,' iterations. Fmin was:',Fmin
     
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
 get_lun,w
 openw,w,'Jacobs.ascii'
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
 printf,w,pdf
openw,47,'pdf.bin'
writeu,47,pdf
close,47
 printf,w,'----------------------------                     '
 idx=where(radius gt 1.0)
 pdf(idx)=1./radius(idx)^pp
 printf,w,pdf
 printf,w,'----------------------------                     '
 ; shift the pdf to the origin
 pdf=shift(pdf,l(0)/2.,l(1)/2.)
 printf,w,pdf
 printf,w,'----------------------------                     '
 ; normalize it
 pdf=pdf/total(pdf,/double)
 printf,w,pdf
 printf,w,'----------------------------                     '
 printf,w,col
 printf,w,'----------------------------                     '
 printf,w,row
 printf,w,'----------------------------                     '
 printf,w,radius
 printf,w,'----------------------------                     '
 printf,w,idx
 printf,w,'----------------------------                     '
 printf,w,deltax
 printf,w,'----------------------------                     '
 printf,w,deltay
 printf,w,'----------------------------                     '
 close,w
 free_lun,w
 ;stop
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
 common counters,icount
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
 print,'Count : ',icount
	icount=icount+1
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
 writefits,'ideal_image_generated_from_input.fts',im1
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
 ; from the image and tries to minimize the residuals on the part of the image outside the lunar rim.
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
 common counters,icount
 icount=0
 iflag=0
 openw,58,'BSESratio.dat'	; log file for photometry
 ;----------------------------------------------------------
 ; Set up the coordinates of the photometric boxes on the ES and BS
 x1=135 &x2=158 & x3=230 &x4=255 &y1=187 & y2=211 ; suitable for 400x400 image
 ;x1=32 &x2=67 & x3=100 &x4=125 &y1=65 & y2=100 ; suitable for sydney_2x2.fit
 ;----------------------------------------------------------
 ; To enable fitting in just some part of the image, a 'line' through the image
 ; and a point in the image are set up - other pixels are then tested
 ; against the line and the point to see if the pixels are on the same side
 ; of the line as the point, if they are that pixel is allowed for minimising on
 line=[-10,0,-10,100]	; is defined by the x,y coords of twopoints on the line
 point1=[10,10]
 ;----------------------------------------------------------
 ; select the operating system
 path='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\'	; Windows at home
 path='./'	; i.e. Unix at work
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
 yes_POWELL=1	; applies to FORWARD method only, ignored otherwise
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
 ; load the 'observed' image and its ideal counterpart
 observed_image_name='simulated_observed_image.fit'
 ideal_image_name='ideal_starting_image.fit' ; NOTE: might be ignored depending on settings elsewhere ...
 get_observed_image,observed_image,ideal_image_name,observed_image_name
 ;----------------------------------------------------------
 ; try to remove the scattered light from "observed_image" using BBSOs linear method
 if (strupcase(method_str) eq 'LINEAR') then remove_scattered_light_linear_method,observed_image,cleaned_image,inside,outside
 ;----------------------------------------------------------
 ; try to remove the scattered light from "observed_image" using forward modelling
 if (strupcase(method_str) eq 'FORWARD') then remove_scattered_light_forward_modelling,observed_image,cleaned_image,inside,outside
 ;--------------------------------------------------------------------------
 ; Post-processing
 go_postpp,im1,dummy,im4,observed_image,cleaned_image,difference
 ; close files
 close,58
 end
 
 
