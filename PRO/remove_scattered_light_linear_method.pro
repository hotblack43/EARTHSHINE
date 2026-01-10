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
 ; loop over angle and radii
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
 return
 end
