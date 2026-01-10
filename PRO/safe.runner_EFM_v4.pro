PRO godoitbetter,startguess_in,im,x0,y0,r0
findbettercircle,im,startguess_in,x0,y0,r0
startguess=[x0,y0,r0,2.,1.]
findbettercircle,im,startguess,x0,y0,r0 
startguess=[x0,y0,r0,1.,.33]
findbettercircle,im,startguess,x0,y0,r0 
startguess=[x0,y0,r0,.5,.13]
findbettercircle,im,startguess,x0,y0,r0 
return
end

pro findbettercircle,sicle,startguess,x0,y0,r0
; will find a better fitting circle, giving a starting guess
openw,92,'trash13.dat'
w=startguess(3)
stepsize=startguess(4)
idx=where(sicle eq 1)
coords=array_indices(sicle,idx)
x=coords(0,*)
y=coords(1,*)
n=n_elements(idx)
ic=0
for ix=startguess(0)-w,startguess(0)+w,stepsize do begin
for iy=startguess(1)-w,startguess(1)+w,stepsize do begin
for rad=startguess(2)-w,startguess(2)+w,stepsize do begin
isum=0
for j=0,n-1,1 do begin
radtest=sqrt((x(j)-ix)^2+(y(j)-iy)^2)
if (abs(radtest-rad) lt 1.0) then isum=isum+1
endfor
printf,92,ix,iy,rad,isum
endfor
endfor
endfor
close,92
data=get_data('trash13.dat')
x=reform(data(0,*))
y=reform(data(1,*))
r=reform(data(2,*))
tot=reform(data(3,*))
idx=where(tot eq max(tot))
print,'maxtot:',max(tot)
if (n_elements(idx) eq 1) then begin
x0=x(idx)
y0=y(idx)
r0=r(idx)
endif
if (n_elements(idx) gt 1) then begin
x0=x(idx(0))
y0=y(idx(0))
r0=r(idx(0))
endif
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
 
 FUNCTION hosteSOBEL,im
 x=[[-1.,0,1.],[-2.,0,2.],[-1.,0,1.]]
 y=[[1.,2.,1.],[0,0,0],[-1.,-2.,-1.]]
 resx=convol(im,x)
 resy=convol(im,y)
 return,abs(resx)+abs(resy)
 end
 
 
 PRO gostripthename,str,fitsname
 ;xx=strpos(str,'245')
 ;fitsname=strmid(str,xx,strlen(str)-xx)
 str2=strsplit(str,'/',/extract)
 fitsname=str2(n_elements(str2)-1)
 return
 end
 
 PRO go_clean_lunar_disc,res,kdx,theta,theta_step,clean_image,radii,angle,removed_light,whichcleaned,iflog
 ; find the cone of the image that can be corrected using the coefficients in 'res'
 ;------------------------------------------------------
 idx=where(angle gt theta and angle le theta+theta_step)
 if (idx(0) ne -1) then begin
 coords=array_indices(clean_image,idx)
 whichcleaned(coords(0,*),coords(1,*))=1	; flag cleaned pixel
 for i=0,n_elements(idx)-1,1 do begin
     correction=radii(idx(i))*res(1)+res(0)
     if (iflog eq 1) then correction=10^correction
     clean_image(idx(i))=clean_image(idx(i))-correction
     removed_light(idx(i))=correction
     endfor
 endif
 return
 end
 
 PRO gofindradiusandcenter,im_in,x0,y0,radius
 common rememberthis,firstguess
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 ; im=laplacian(im,/CENTER)
 ; im=hosteSOBEL(im)
 im=SOBEL(im)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 imuselater=im
 ; remove specks
 im=median(im,3)
 writefits,'inputimageforsicle.fits',im_in
 writefits,'sicle.fits',im
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 openw,49,'trash2.dat'
 for i=0,ntries-1,1 do begin 
     irnd=randomu(seed)*nels
     x1=reform(coords(0,irnd))
     y1=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x2=reform(coords(0,irnd))
     y2=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x3=reform(coords(0,irnd))
     y3=reform(coords(1,irnd))
     ;oplot,[x1,x1],[y1,y1],psym=7
     fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
     printf,49,x0,y0,radius
     endfor
 close,49
 spawn,'grep -v NaN trash2.dat > aha2.dat'
 spawn,'mv aha2.dat trash2.dat'
 data=get_data('trash2.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 openw,47,'circle.dat' & printf,47,x0,y0,radius & close,47
 firstguess=[x0,y0,radius]
 ; So, that was a robust first guess - but not good enough! Using the first guess we go on and (hopefully) improve
print,'First guess x0,y0,r0:',firstguess
startguess=[x0,y0,radius,7,2]
godoitbetter,startguess,imuselater,x0,y0,radius
print,'Best x0,y0,r0:',x0,y0,radius
 openw,47,'circle.dat' & printf,47,x0,y0,radius & close,47
if (n_elements(x0) gt 1 or n_elements(y0) gt 1 or n_elements(radius) gt 1) then stop
 return
 end
 
 PRO go_fit_line,filename,res,iflog,idx
 ; will fit a straight line to the data in 'filename'
 common vizualise,viz
 data=get_data(filename)
 theta=reform(data(0,*))
 x=reform(data(1,*))
 y=reform(data(2,*))
 if (iflog ne 1) then begin
     res=ladfit(x,y,/double) & yhat=res(0)+res(1)*x
     ;		res=linfit(x,y,/double,yfit=yhat)
     endif
 if (iflog eq 1) then begin
     idx=where(y gt 0)
     res=[911,911]
     if (idx(0) ne -1) then begin
     res=ladfit(x(idx),alog10(y(idx)),/double) & yhat=res(0)+res(1)*x(idx)
     endif
     endif
 if (viz eq 1) then begin
     window,1,xsize=400,ysize=300
     plot,x,y,psym=7,ystyle=1,title='Angle='+string(theta(0)),$
     xtitle='Distance from Moon ctr.'
     oplot,x,yhat,color=fsc_color('red'),thick=2
     if (iflog eq 1) then oplot,x(idx),yhat,color=fsc_color('red'),thick=2
     endif
 return
 end
 
 FUNCTION test_if_same_side,line,point1,point2
 ; Will test if two points are on the same side of a line
 ; INPUTS:
 ; line = [a1,a2,b1,b2], coords of two points ON the line
 ; point1 = [c1,c2], coords of the first point
 ; point2 = [d1,d2], coords of the second point
 a1=double(line(0))
 a2=double(line(1))
 b1=double(line(2))
 b2=double(line(3) )
 c1=double(point1(0))
 c2=double(point1(1))
 d1=double(point2(0))
 d2=double(point2(1))
 stat1=crossp([a1-c1,a2-c2,0],[a1-b1,a2-b2,0])
 stat2=crossp([a1-d1,a2-d2,0],[a1-b1,a2-b2,0])
 test=(stat1(2)/abs(stat1(2)) eq stat2(2)/abs(stat2(2)))
 return,test
 end
 
 PRO find_circle_inside_outside,radius_in,CENTER,inside,outside,l,idx_inside,idx_outside
 common lineandpoint,line,point1
 radius=radius_in
 if (n_elements(radius_in) gt 1) then radius=radius_in(0)
 inside=intarr(l)
 outside=intarr(l)
 radius2=radius^2
 ;..........
 for i=0,l(0)-1,1 do begin
     for j=0,l(1)-1,1 do begin
         r2= (i-CENTER(0))^2+(j-CENTER(1))^2
         ;if (r2 gt radius2 and test_if_same_side(line,point1,[i,j,0]) eq 1) then outside(i,j)=1 ELSE inside(i,j)=1
         if (r2 gt radius2) then outside(i,j)=1 ELSE inside(i,j)=1
         endfor
     endfor
 idx_inside=where(inside eq 1)
 idx_outside=where(outside eq 1)
 return
 end
 
 PRO remove_scattered_light_linear_method,observed_image,clean_image,inside,outside,DSonleft,iflog
 ;----------------------------------------------------
 common moonres,im1,im2,im3
 common uselater,im4,difference
 common fitedresults,P
 common type,typeflag
 common circleSTUFF,circle,radius,moon_coords
 common vizualise,viz
 common paths,path
 common which,whichcleaned
 ;----------------------------------------------------
 ; BBSO - i.e. sky extrapolation - method
 ; take the image observed_image and generate a correction 
 ; for the scattered light
 ; place the corrected image in clean_image
 ; Will work on log images given that iflog=1
 ;----------------------------------------------------
 clean_image=observed_image
 removed_light=clean_image*0.0d0
 whichcleaned=clean_image*0
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
 ;angle=atan((yy-y0),(xx-x0))/!dtor + 180
 angle=atan((xx-x0),-(yy-y0))/!dtor + 180
 xline=xx
 yline=yy
;if (viz eq 1) then begin
;    window,2
;    surface,radii,charsize=2
;    window,3
;    surface,angle,charsize=2
;    endif
 ; loop over angle and radii
 nbins=100
 binsize=5.
 p_lim=0.1
 radbins=indgen(nbins)*binsize
 theta_step=6.0
 fudge=4.0	; an arbitrary factor that compensates for dependency between data points
 fstr='(f8.3,1x,f9.2,1x,f8.3,1x,i5,1x,i2)'
 ;............................
 if (DSonleft eq 1) then begin
     for theta=0.0d0,180.0d0-theta_step,theta_step do begin
         openw,44,'bins.dat'
         idx=where(angle ge theta and angle lt theta+theta_step and radii gt radius(0)*1.05)
         for kl=0,n_elements(idx)-1,1 do printf,44,theta,radii(idx(kl)),observed_image(idx(kl))
         close,44
         go_fit_line,'bins.dat',res,iflog,kdx
         go_clean_lunar_disc,res,kdx,theta,theta_step,clean_image,radii,angle,removed_light,whichcleaned,iflog
         endfor	; end theta
     endif	; end of DSonleft = 1
 ;............................
 if (DSonleft ne 1) then begin
     for theta=180.0d0,360.0d0-theta_step,theta_step do begin
         openw,44,'bins.dat'
         idx=where(angle ge theta and angle lt theta+theta_step and radii gt radius(0)*1.05)
         for kl=0,n_elements(idx)-1,1 do printf,44,theta,radii(idx(kl)),observed_image(idx(kl))
         if (viz eq 1) then begin
             window,0
             im=observed_image
             im(idx)=max(im)
             contour,im,/isotropic,/cell_fill,xstyle=1,ystyle=1
             endif
         close,44
         go_fit_line,'bins.dat',res,iflog,kdx
         go_clean_lunar_disc,res,kdx,theta,theta_step,clean_image,radii,angle,removed_light,whichcleaned,iflog
         endfor	; end theta
     endif
 ;............................
 im4=removed_light
 difference=observed_image-removed_light
 return
 end
 
 PRO get_circle,l,coords,circle,radius_in,maxval
 radius=radius_in
 if (n_elements(radius_in) gt 1) then radius=radius_in(0)
 circle=fltarr(l)*0.0
 astep=0.1d0
 x0=coords(0)
 y0=coords(1)
 for angle=0.0d0,360.0d0-astep,astep do begin
     x=x0+radius*cos(angle*!dtor)
     y=y0+radius*sin(angle*!dtor)
     if ((x ge 0 and x le l(0)-1) and (y ge 0 and y le l(0)-1)) then circle(x,y)=maxval
     endfor
 return
 end
 
 PRO get_observed_image,inname,observed_image,header,cg_x,cg_y,q_flag
 common circleSTUFF,circle,radius,moon_coords
 common vizualise,viz
 observed_image=readfits(inname,header)
 ;---------------------------
 ; use a binary code system for setting flags for various quality problems
 maxcounts=53000.0
 mincounts=10000.0
 maxstrip=50
 ; check image for OK fluxes
 if (max(observed_image) gt maxcounts) then q_flag=q_flag+1
 if (max(observed_image) lt mincounts) then q_flag=q_flag+2
 if (mean(observed_image) lt 0.0) then q_flag=q_flag+4
 ; check image for 'dragging'
 strip=avg(observed_image(*,0:20),1)
 if (max(strip) gt maxstrip) then q_flag=q_flag+8
 ;---------------------------
 l=size(observed_image,/dimensions)
 gofindradiusandcenter,observed_image,x0,y0,radius
 if (n_elements(radius) gt 1) then begin
	print,'stop 314: '
	stop
 endif
 moon_coords=[x0,y0]
 get_circle,l,moon_coords,circle,radius,max(observed_image)
 ;----------------------------------------------------------
 ; check that radius is sensible and that Moon is well centred
 minradius=120
 maxradius=160
 width=40	; safety margin between moon edge and edge of image
 if (radius gt maxradius or radius lt minradius) then q_flag=q_flag+16
 if ((x0-radius lt width) or (y0-radius lt width) or (512-x0-radius lt width) or (512-y0-radius lt width)) then q_flag=q_flag+32
 ;----------------------------------------------------------
 ; Build a composite image of Moon and circle
 ;imin2=observed_image+circle
 ;if (viz eq 1) then tvscl,alog(imin2)
 ;----------------------------------------------------------
 ; find the inside and the outside of the circle around the Moon
 find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
 im3=outside     ; the skymask
 im2=observed_image
 ; find the center of gravity coordinates
 meshgrid,l(0),l(1),x,y
 im=observed_image
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
 return
 end
PRO findafittedlinearsurface,im,mask,thesurface
l=size(im,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
;----------------------------------------
offset=mean(im(0:10,0:10))
thesurface=findgen(512,512)*0.0
mim=mask*im
get_lun,wxy
openw,wxy,'masked.dat'
for i=0,511,1 do begin
for j=0,511,1 do begin
if (mim(i,j) ne 0.0) then begin
printf,wxy,i,j,mim(i,j)
endif
endfor
endfor
close,wxy
free_lun,wxy
data=get_data('masked.dat')
res=sfit(data,/IRREGULAR,1,kx=coeffs)
print,coeffs
thesurface=coeffs(0,0)+coeffs(1,0)*y+coeffs(0,1)*x+coeffs(1,1)*x*y
thesurface=thesurface+offset
return
end
PRO plot3things,observed,trialim,cuttoffval,alfa 
 common circle,x0,y0,radius
 y1=256
 delta=sqrt(radius^2-(y1-y0)^2)
 !P.MULTI=[0,1,3]
 plot_io,observed(*,y1),yrange=[min(observed),max(observed)],title=filename,xstyle=3
 oplot,trialim(*,y1),color=fsc_color('red')
 oplot,[!X.crange],[max(observed(*,y1)),max(observed(*,y1))],linestyle=2
 oplot,[!X.crange],[max(observed(*,y1))/cuttoffval,max(observed(*,y1))/cuttoffval],linestyle=2
 oplot,[x0-delta,x0-delta],[!Y.CRANGE],linestyle=2
 oplot,[x0+delta,x0+delta],[!Y.CRANGE],linestyle=2
offs=mean(observed(0:10,y1))
 plot,observed(*,y1),yrange=[offs,offs+70],xstyle=3
 oplot,trialim(*,y1),color=fsc_color('red')
 oplot,[x0-delta,x0-delta],[!Y.CRANGE],linestyle=2
 oplot,[x0+delta,x0+delta],[!Y.CRANGE],linestyle=2
 plot,observed(*,y1)-trialim(*,y1),yrange=[-10,70],xstyle=3 & plots,[!X.crange],[0,0],linestyle=2
 oplot,[x0-delta,x0-delta],[!Y.CRANGE],linestyle=2
 oplot,[x0+delta,x0+delta],[!Y.CRANGE],linestyle=2
return
end

PRO get_info_from_header,header,str,valout
if (str eq 'ACT') then begin
        get_cycletime,header,valout
	return
endif
if (str eq 'UNSTTEMP') then begin
        get_temperature,header,valout
	return
endif
if (str eq 'DMI_ACT_EXP') then begin
        get_measuredexptime,header,valout
	return
endif
if (str eq 'DMI_COLOR_FILTER') then begin
        get_filtername,header,valout
	return
endif
if (str eq 'FRAME') then begin
	get_time,header,valout
	return
endif
return
end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

 PRO get_cycletime,header,acttime
 idx=where(strpos(header, 'ACT') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 acttime=float(strmid(str,16,15))
 return
 end

 PRO get_temperature,header,temperature
 idx=where(strpos(header, 'UNSTTEMP') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 temperature=float(strmid(str,16,15))
 return
 end

 PRO get_measuredexptime,header,measuredtexp
 idx=where(strpos(header, 'DMI_ACT_EXP') ne -1)
 str='999'
 measuredtexp=911
 if (idx(0) ne -1) then begin
	str=header(idx(0))
 	measuredtexp=float(strmid(str,24,8))
 endif
 return
 end

PRO get_times,h,act,exptime
get_info_from_header,h,'DMI_ACT_EXP',act
get_EXPOSURE,h,exptime
end

 PRO getbasicfilename,namein,basicfilename
 print,namein
 basicfilename=strmid(namein,strpos(namein,'.')-7)
 ;basicfilename=strmid(namein,strpos(namein,'2455'))
 return
 end

 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end


PRO gofindDSandBSinboxes,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag
; determine if BS is to the right or the left of the center
; iflag = 1 means position 1
; iflag = 2 means position 2
if (iflag eq 1) then ipos=4./5.
if (iflag eq 2) then ipos=2./3.
 BS=911.999
 DS=911.999
if (cg_x gt x0) then begin
 if ((cg_x-w ge 0 and cg_x+w le 511 and cg_y-w ge 0 and cg_y+w le 511) and (x0-radius*ipos-w ge 0 and x0-radius*ipos+w le 511 and y0-w ge 0 and y0+w le 511)) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*ipos-w:x0-radius*ipos+w,y0-w:y0+w))
endif
endif
if (cg_x lt x0) then begin
 if ((cg_x-w ge 0 and cg_x+w le 511 and cg_y-w ge 0 and cg_y+w le 511) and (x0+radius*ipos-w ge 0 and x0+radius*ipos+w le 511 and y0-w ge 0 and y0+w le 511)) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*ipos-w:x0+radius*ipos+w,y0-w:y0+w))
endif
endif
return
end

PRO bestBSspotfinder,im,cg_x,cg_y
; find the coordinates of a spot near the brightest part of the BS
 l=size(im,/dimensions)
smooim=median(im,5)
idx=where(smooim eq max(smooim))
coo=array_indices(smooim,idx)
cg_x=coo(0)
cg_y=coo(1)
if (cg_x lt 0 or cg_x gt l(0) or cg_y lt 0 or cg_y gt l(1)) then stop
return
end


PRO get_mask,x0,y0,radius,mask
 ; build a 1/0 mask that is a circle (center x0,y0) and radius r with 1's outside radius and 0's inside
 common sizes,l
 nx=l(0) & ny=l(1) & mask=fltarr(nx,ny)
 for i=0,nx-1,1 do begin
     for j=0,ny-1,1 do begin
         rad=sqrt((i-x0)^2+(j-y0)^2)
         if (rad ge radius) then mask (i,j)=1 else mask(i,j)=0.0
         endfor
     endfor
 return
 end
 
 PRO gogetjulianday,header,jd
 idx=strpos(header,'JULIAN')
 str=header(where(idx ne -1))
 jd=double(strmid(str,15,15))
 return
 end
 
 
 FUNCTION get_mean_flux_in_box,im_in
 im=im_in
 im=smooth(im,7,/edge_truncate)
 xl=362
 xr=385
 yd=220
 yu=304
 subim=im(xl:xr,yd:yu)
 idx=where(finite(subim) eq 1)
 ; RMSE
 res=sqrt(mean(subim(idx)^2))
 return,res
 end
 
 
 FUNCTION get_errorINwholeIMAGE,im_in
 im=im_in
 im=smooth(im,7,/edge_truncate)
 idx=where(finite(im) eq 1)
 ; RMSE
 res=sqrt(mean(im(idx)^2))
 return,res
 end
 
 FUNCTION minimize_me, X, Y, P
 common names,filename
 common vizualiz,ifviz
 l=size(x,/dimensions)
 n=l(0)
 ; should return the error model - i.e. the image of the residuals
 common ims,observed,source,residual,mask,trialim,cleanup
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b,idealbiasinbox
 common cutoff,cuttoffval
 ; The independent variables are X and Y
 a=p(0)
 alfa=p(1)
 ; generate a Source image from the observed image 
 ; subtracting the current guess ofr the offset
 im=observed-a
 ; generate the '1/75th' source image
 factor=cuttoffval
 idx=where(im lt max(smooth(im,3))/factor)
 im(idx)=0
 writefits,'source.fits',im
 ; then use that estimate of the source to fold etc
 str='./justconvolve source.fits source_folded_out.fits '+string(alfa)
 spawn,str
 source_folded=readfits('source_folded_out.fits',/silent)
 b=(total(observed,/double))/total(source_folded+a,/double)
 print,'b=',b
 trialim=a+b*source_folded
 ; get residuals wrt observed image
 cleanup=observed-trialim
 ; set up the removal of a linear fitted surface
 writefits,'cleanup.fits',cleanup
 writefits,'mask.fits',mask
 findafittedlinearsurface,cleanup,mask,thesurface
 trialim=trialim+thesurface
 cleanup=observed-trialim
 ;
 residual=(cleanup)/observed*100.0
 idx=where(finite(residual) ne 1)
 if (idx(0) ne -1) then residual(idx)=0.0
 ; evaluate model fit 
 errorwholeimage=get_errorINwholeIMAGE(mask*residual)
 ; print out some results
 print,'----------------->',p,b,errorwholeimage
 if (ifviz eq 1 ) then plot3things,observed,trialim,cuttoffval,alfa 
 return, (residual*mask)
 END
 
 
 ;------------------------------------------------------------------------
 ; RUNNER version 4. EFM method.
 ;------------------------------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,source,residual,mask,trialim,cleanup
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b,idealbiasinbox
 common sizes,l
 common cutoff,cuttoffval
 common names,filename
 common circle,x0,y0,radius
 common vizualiz,ifviz
 ifviz=0
 cuttoffval=90
 night='2456000'
 openr,22,'runner_JD.txt'
 readf,22,night
 close,22
 ; path for EMF-cleaned DSs
 lowpath='/media/SAMSUNG/'
 ;lowpath='/data/pth/DATA/ANDOR/'
 outpath=strcompress('EFMCLEANED_HAPKE63/',/remove_all)
 ;outpath=strcompress(lowpath+'DARKCURRENTREDUCED/JD'+night+'/EFMCLEANED/',/remove_all)
 ;spawn,'rm -r '+outpath
 ;spawn,'mkdir '+outpath
 get_lun,ww
 openw,ww,'collected_output_EFM_realimages_'+night+'.txt'
 str=strcompress(lowpath+'DARKCURRENTREDUCED/'+night+'*INDIADD.fi*',/remove_all)
 files=file_search(str,count=nfiles)
 for i=0,nfiles-1,1 do begin
 ; read in the observed image
 filename=files(i)
 getbasicfilename,files(i),basicfilename
 print,'Reading ',files(i)
 print,'basicfilename: ',basicfilename
 observed=readfits(files(i),header)+10
     a=mean(observed(0:10,0:10))
     alfa=1.7d0+randomn(seed)/10.
 ; select if OK else skip
 if(max(observed) gt 10000 and max(observed) lt 53000) then begin
 get_times,header,act,exptime
 l=size(observed,/dimensions)
 ; find light C.G.
 bestBSspotfinder,observed,cg_x,cg_y
 ; add some bias
 writefits,'observed.fits',observed
 ; generate a Source image from the observed image 
 ; generate the '1/75th' source image
 im=observed
 factor=cuttoffval
 idx=where(im lt max(smooth(im,3))/factor)
 im(idx)=0
 writefits,'source.fits',im
 source=readfits('source.fits')
 ; generate the 1/0 mask
 gofindradiusandcenter,im,x0,y0,radius
 ;radius=radius+6
 get_mask,x0,y0,radius+6,mask
 writefits,'mask.fits',mask
     ; Define the starting point:
     start_parms = [a,alfa]
     ; Find best parameters using MPFIT2DFUN method
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
     kdx=where(observed le 0)
     jdx=where(observed gt 0)
     weights=1./sqrt(observed) 
     weights(kdx)=median(1./sqrt(observed(jdx)))
     weights=weights*sqrt(3090.)
     weights=observed*0.0+1.0
     z=observed*0.0	; target is a zero plane
     ; set up the PARINFO array - indicate double-sided derivatives (best)
     parinfo = replicate({mpside:0, value:0.D, $
     fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-4}, 2)
     parinfo[0].fixed = 0
     parinfo[1].fixed = 0
     ; a
     parinfo[0].limited(0) = 0
     parinfo[0].limits(0)  = 100.0
     parinfo[0].limited(1) = 0
     parinfo[0].limits(1)  = 0.
     ; alfa
     parinfo[1].limited(0) = 0
     parinfo[1].limits(0)  = 0.0
     parinfo[1].limited(1) = 0
     parinfo[1].limits(1)  = 0
     parinfo[*].value = start_parms
     
     ; print,parinfo
     results = MPFIT2DFUN('minimize_me', X, Y, Z, weights=weights, $
     PARINFO=parinfo,perror=sigs,STATUS=hej,xtol=1e-11)
     ; Print the solution point:
     print,'STATUS=',hej
     PRINT, 'Solution point: ', results(0),' +/- ',sigs(0),' or ',sigs(0)/results(0)*100.,' % error.'
     PRINT, 'Solution point: ', results(1),' +/- ',sigs(1),' or ',sigs(1)/results(1)*100.,' % error.'
;
 a=results(0)
 alfa=results(1)
 ; do a plot in postscript
set_plot,'ps'
device,/color
device,xsize=18,ysize=24.5,yoffset=2
 thing=strmid(basicfilename,0,strpos(basicfilename,'.fits'))
 device,filename=strcompress(outpath+'bestfit_EFM_'+thing+'_.ps',/remove_all)
 plot3things,observed,trialim,cuttoffval,alfa 
 set_plot,'x'
 ; save the cleaneup image (i.e. just the DS)
 sxaddpar, header, 'DISCX0', x0(0), 'Disc center x coordinate'
 sxaddpar, header, 'DISCY0', y0(0), 'Disc center x coordinate'
 sxaddpar, header, 'DISCRA', radius(0), 'Disc radius.'
 sxaddpar, header, 'ALFA', alfa, 'PSF alfa found via EFM.'
 writefits,strcompress(outpath+'DS_'+basicfilename,/remove_all),cleanup,header
endif
endfor
close,ww
free_lun,ww
 end
