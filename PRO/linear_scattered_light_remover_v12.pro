PRO getJDfromname,filename,JD,filtername
print,filename
bits=strsplit(filename,'_',/extract)
JD=double(bits(1))
filtername=strcompress('_'+bits(2)+'_',/remove_all)
return
end

PRO get_filter_from_JD,JD,filterstr,filternumber
filternames=['B','V','VE1','VE2','IRCUT']
filternumbers=indgen(n_elements(filternames))
file='JD_and_filter.txt'
spawn,"grep "+string(JD,format='(f15.7)')+" "+file+" > hkjgvghjkv"
openr,22,'hkjgvghjkv'
str=''
readf,22,str
close,22
bits=strsplit(str,' ',/extract)
JDfound=double(bits(0))
filterstr=bits(1)
if (JD ne JDfound) then stop
filternumber=filternumbers(where(filternames eq filterstr))
return
end

 PRO get_photometry,x0,y0,dx,dy,w,cleaned_image,DScounts
 blob=cleaned_image(x0+dx-w:x0+dx+w,y0+dy-w:y0+dy+w)
 DScounts=median(blob)
 return
 end

 
 PRO godotherequirederotation,im,x0,y0
; will apply a 7 degree clockwise rotation of the input image
im=ROT(im,7.0,1.0,x0,y0,/pivot)
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

PRO godoitbetter,startguess_in,im,x0,y0,r0
findbettercircle,im,startguess_in,x0,y0,r0
startguess=[x0,y0,r0,2.,1.]
findbettercircle,im,startguess,x0,y0,r0 
startguess=[x0,y0,r0,1.,.33]
findbettercircle,im,startguess,x0,y0,r0 
startguess=[x0,y0,r0,.4,.13]
findbettercircle,im,startguess,x0,y0,r0 
return
end

pro findbettercircle,sicle,startguess,x0,y0,r0
; will find a better fitting circle, giving a starting guess
get_lun,poi
openw,poi,'trash13.dat'
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
printf,poi,ix,iy,rad,isum
endfor
endfor
endfor
close,poi
free_lun,poi
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
 
 PRO gofindradiusandcenter_fromheader,header,x0,y0,radius
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCX0 not in header. Assigning dummy value'
 x0=256.
 endif else begin
 x0=float(strmid(header(jdx),15,9))
 endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCY0 not in header. Assigning dummy value'
 y0=256.
 endif else begin
 y0=float(strmid(header(jdx),15,9))
 endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'RADIUS not in header. Assigning dummy value'
 radius=134.327880000
 endif else begin
 radius=float(strmid(header(jdx),15,9))
 endelse
 radius=radius(0)
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
	 get_lun,qws
         openw,qws,'bins.dat'
         idx=where(angle ge theta and angle lt theta+theta_step and radii gt radius(0)*1.05)
         for kl=0,n_elements(idx)-1,1 do printf,qws,theta,radii(idx(kl)),observed_image(idx(kl))
         close,qws
	 free_lun,qws
         go_fit_line,'bins.dat',res,iflog,kdx
         go_clean_lunar_disc,res,kdx,theta,theta_step,clean_image,radii,angle,removed_light,whichcleaned,iflog
         endfor	; end theta
     endif	; end of DSonleft = 1
 ;............................
 if (DSonleft ne 1) then begin
     for theta=180.0d0,360.0d0-theta_step,theta_step do begin
	get_lun,qws
         openw,qws,'bins.dat'
         idx=where(angle ge theta and angle lt theta+theta_step and radii gt radius(0)*1.05)
         for kl=0,n_elements(idx)-1,1 do printf,qws,theta,radii(idx(kl)),observed_image(idx(kl))
         if (viz eq 1) then begin
             window,0
             im=observed_image
             im(idx)=max(im)
             contour,im,/isotropic,/cell_fill,xstyle=1,ystyle=1
             endif
         close,qws
	free_lun,qws
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
 
 PRO get_observed_image_2,inname,observed_image,header,cg_x,cg_y,q_flag
 common circleSTUFF,circle,radius,moon_coords
 common vizualise,viz
 observed_image=readfits(inname,header)
 observed_image=reform(observed_image(*,*,0))
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
 gofindradiusandcenter_fromheader,header,x0,y0,radius
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
 
 ;..............................................................................
 ; Version 12. 
 ; Uses X0,Y0,Radius from fitsheader - unlike previous versions
 ; Also does NOT apply rotations, since this is assumed to have been done
 ; Like Version 11 but uses 'cubes' and extracts some simple photometry on DS/BS ratio
 ;..............................................................................
 common paths,path
 common circleSTUFF,circle,radius,moon_coords
 common vizualise,viz
 common lineandpoint,line,point1
 common which,whichcleaned
 t1=systime(/julian)
 path='./'
 viz=0
 basepath=strcompress('/data/pth/DARKCURRENTREDUCED/SELECTED_2/',/remove_all)
 inpath='/media/thejll/OLDHD/CUBES/';basepath
 print,'basepath: ',basepath
 outpath0=strcompress(inpath+'BBSO_CLEANED/',/remove_all)
 outpath1=strcompress(inpath+'BBSO_CLEANED_LOG/',/remove_all)
;spawn,'rm -r '+outpath0
;spawn,'mkdir '+outpath0
;print,'Created ',outpath0
;spawn,'rm -r '+outpath1
;spawn,'mkdir '+outpath1
;print,'Created ',outpath1
 line=[256,0,256,511]
 point1=[511,0]
 openr,81,'Chris_list_good_images_integer_JDs.txt'
 while not eof(81) do begin
 JDwanted=''
 readf,81,JDwanted
 openw,82,'BBSO_method_extracted_BScounts_'+JDwanted+'.dat'
 files=file_search(strcompress(inpath+'cube_'+JDwanted+'.*.fits',/remove_all),count=n)
 print,'Found ',n,' files to work on.'
 get_lun,wsy
 openw,wsy,'linear_scattered_light_remover_v11.log'
 for i=0,n-1,1 do begin
     for iflog=0,1,1 do begin
         gostripthename,files(i),fitsname
	 getJDfromname,files(i),JD,filtername
         observed_image_name=files(i)
	 print,'Trying to read file: ',files(i)
	 q_flag=0
         get_observed_image_2,observed_image_name,observed_image,header,cg_x,cg_y,q_flag
; only proceed with images that have q_flag=0
	if (q_flag eq 0) then begin
         get_time,header,JD
         x0=moon_coords(0) & y0=moon_coords(1)
         totflux=total(observed_image,/double)
         maxflux=max(observed_image)
         ;----------------------------------------------------------
         ; try to remove the scattered light from "observed_image" using BBSOs linear method
         DSonleft = 1
         if (cg_x lt x0) then DSonleft=0
         print,'DSonleft: ',DSonleft
         remove_scattered_light_linear_method,observed_image,cleaned_image,inside,outside,DSonleft,iflog
         ;
         if (iflog eq 0) then begin
             writefits,strcompress(outpath0+fitsname,/remove_all),cleaned_image,header
             print,'wrote to ',outpath0
             endif
         if (iflog eq 1) then begin
             writefits,strcompress(outpath1+fitsname,/remove_all),cleaned_image,header
             print,'wrote to ',outpath1
             endif
         t2=systime(/julian)
         fmt='(3(1x,f9.3),f8.1,1x,e11.5,1x,i3,1x,a)'
         printf,wsy,format=fmt,x0,y0,radius,maxflux,totflux,q_flag,files(i)
; time for photometry
        dx=-107
	dy=-13
	w=7
 	get_photometry,x0,y0,dx,dy,w,cleaned_image,DScounts
	printf,82,format='(i3,1x,f15.7,1x,f10.6,1x,g12.7,1x,a)',iflog,JD,DScounts,total(observed_image,/double),filtername
	print,format='(i3,1x,f15.7,1x,f10.6,1x,g12.7,1x,a)',iflog,JD,DScounts,total(observed_image,/double),filtername
	endif
         endfor
     endfor
 close,wsy
 free_lun,wsy
 close,17
 close,82
 endwhile
 close,81
 end
 
