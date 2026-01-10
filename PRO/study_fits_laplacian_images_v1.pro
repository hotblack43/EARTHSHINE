FUNCTION ls,i,e
; i and e are angle sin DEGREES
value=cos(i*!dtor)/(cos(i*!dtor)+cos(e*!dtor))
help,value,i,e
return,value
end

PRO gooverplot,cosine,x,y
idx=where(y gt max(y)/10.)
shiftt=mean(x(idx))
idx=where(y gt max(y)/3.)
top=max(y(idx))
;oplot,findgen(360),cos((findgen(360)-shiftt)*!dtor)*top,color=fsc_color('red')
oplot,findgen(360),ls(45.,findgen(360))*top,color=fsc_color('red')
stop
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

PRO MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
;-----------------------------------------------------------------------
; Set various constants.
;-----------------------------------------------------------------------
RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]
MOONPOS, jd, ra_moon, DECmoon, dis
distance=dis/6371.
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
return
end
PRO get_everything_fromJD,JD,phase,azimuth,am,longlint
obsname='mlo'
observatory,obsname,obs_struct
lat=obs_struct.latitude
lon=obs_struct.longitude
; get the phase and azimuth
MOONPHASE,jd,azimuth,phase,alt_moon,alt_sun,obsname
; get the airmass
moonpos, JD, RAmoon, DECmoon
am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
; get the longlint
get_sunglintpos,jd,longlint,glat,az_moon,alt_moon,moonlat,moonlong
return
end

 FUNCTION get_JD_from_filename,name
 idx=strpos(name,'24')
 JD=double(strmid(name,idx,15))
 return,JD
 end

PRO get_everything_fromJD,JD,phase,azimuth,am,longlint
obsname='mlo'
observatory,obsname,obs_struct
lat=obs_struct.latitude
lon=obs_struct.longitude
; get the phase and azimuth
MOONPHASE,jd,azimuth,phase,alt_moon,alt_sun,obsname
; get the airmass
moonpos, JD, RAmoon, DECmoon
am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
; get the longlint
get_sunglintpos,jd,longlint,glat,az_moon,alt_moon,moonlat,moonlong
return
end

;------------------------------------
PRO getcoordsfromheader,header,x0,y0,radius
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     bits=strsplit(header(jdx),' ',/extract)
     x0=bits(2)
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     bits=strsplit(header(jdx),' ',/extract)
     y0=bits(2)
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     bits=strsplit(header(jdx),' ',/extract)
     radius=bits(2)
     endelse
 return
 end
 
 PRO goget_radii_angles,x0,y0,lap,radii,angle
 ; find radii of all pixels
 l=size(lap,/dimensions)
 x=findgen(l(0))
 y=findgen(l(1))
 xx=rebin(x,[l(0),l(1)])
 yy=transpose(rebin(y,[l(1),l(0)]))
 radii=sqrt((xx-x0)^2+(yy-y0)^2)
 angle=atan((xx-x0),-(yy-y0))/!dtor + 180
 return
 end
 
 PRO goplotsweeps,x0,y0,radius,lap,minval,name
 ; find (r,theta) of all pixels
 goget_radii_angles,x0,y0,lap,radii,angle
 ;contour,/isotropic,angle,/cell_fill,nlevels=101
 levs=findgen(9)*40.
 contour,/isotropic,/overplot,angle,levels=levs,c_labels=indgen(9)*0+1
 openw,33,'laplacian_range.dat'
 step=6
 for theta=0,360-step,step do begin
     xx=[]
     yy=[]
     zz=[]
     for r=radius-20,radius+20,2 do begin
         idx=where(angle gt theta and angle le theta+step and radii gt r and radii le r+2)
         x=mean(radii(idx))
         y=mean(lap(idx))
         z=stddev(lap(idx))
         xx=[xx,x]
         yy=[yy,y]
         zz=[zz,z]
         endfor
;    plot,xx,yy,charsize=2,xtitle='radius',ytitle='Laplacian',title=strcompress(string(theta)+' to '+string(theta+step))
     printf,33,theta,max(yy)-min(yy)
     endfor
 close,33
 data=get_data('laplacian_range.dat')
;!P.MULTI=[0,1,2]
 plot_io,xstyle=3,charsize=1.9,ystyle=3,data(0,*),data(1,*),xtitle='Theta',ytitle='max - min of Laplacian on edge',title=name
 gooverplot,cosine,data(0,*),data(1,*)
 minval=median(data(1,where(data(1,*) lt 0.01*max(data(1,*)))))
 oplot,[!X.crange],[minval,minval],linestyle=2
 maxval=median(data(1,where(data(1,*) gt 0.1*max(data(1,*)))))
 oplot,[!X.crange],[maxval,maxval],linestyle=2
 maxval=median(data(1,where(data(1,*) gt 0.2*max(data(1,*)))))
 oplot,[!X.crange],[maxval,maxval],linestyle=2
 wait,1
 return
 end
 
 ;=============================================================
 ; Study Laplacian of images
 ; Version 1: plots in a loop over found images
;files=file_search('observed_image_JD*',count=n)
 openw,44,'laplace_data_observed.dat'
;files=file_search('OUTPUT/IDEAL/synth_folded_scaled_shifted_JD245*',count=n)
 files=file_search('OUTPUT/IDEAL/ideal_image*',count=n)
;openw,44,'laplace_data_ideals.dat'
 for ifile=0,n-1,1 do begin
 	!P.MULTI=[0,1,2]
 	im=readfits(files(ifile),header,/silent)
 	lap=laplacian(im)
;	!P.MULTI=[0,3,4]
 	contour,xstyle=3,ystyle=3,/isotropic,hist_equal(im),/cell_fill,nlevels=101
 	getcoordsfromheader,header,x0,y0,radius
        JD=get_JD_from_filename(files(ifile))
	get_filter_from_JD,JD,filterstr,filternumber
        get_everything_fromJD,JD,phase,azimuth,am,longlint
 	goplotsweeps,x0,y0,radius,lap,minval,files(ifile)
 	print,format='(f15.7,5(1x,g15.6),1x,a)',JD,phase,am,minval,total(im,/double),minval/total(im,/double),filterstr
 	printf,44,format='(f15.7,5(1x,g15.6),1x,i2)',JD,phase,am,minval,total(im,/double),minval/total(im,/double),filternumber
;a=get_kbrd()
 endfor
 close,44
 print,'Now plot columns in file laplace_data.dat'
 end
