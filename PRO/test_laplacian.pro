FUNCTION zenithangmoon,x
; returns Moons zenith angle at Julian day jd (which must be passed via the common block)
; used by get_lon_lat_for_moon_at_zenith, below.
common time,jd
longitude=x(0)
latitude=x(1)
        MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
        eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  lon=longitude,lat=latitude
zenithangMoon=90.-alt_moon
return,zenithangMoon
end

PRO get_lon_lat_for_moon_at_zenith,lon,lat
; routine for using POWELL to find where the Moon is right overhead on Earth
; Define the fractional tolerance:
   ftol = 1.0d-8
   ; Define the starting point:
   P = [0.0d0,0.0d0]
   ; Define the starting directional vectors in column format:
   xi = TRANSPOSE([[1.0, 0.0],[0.0, 1.0]])
   ; Minimize the function:
   POWELL, P, xi, ftol, fmin, 'zenithangmoon',/DOUBLE
lon=p(0)
lat=p(1)
while (lon lt 0) do begin
lon=360.+lon
endwhile
while (lon gt 360.0) do begin
lon=lon-360.0
endwhile
return
end

PRO get_sunglintpos,jd_i,glon,glat,az_moon,alt_moon,moonlat,moonlong
; will return among other things the longitude and latitude on Earth of the sunglint as seen from the Moon
; the longitude of the glint is in the 0-360 degree format.
        common time,jd
        caldat,jd_i,mm,dd,yy,hr,mi,sec
        jd=jd_i
        MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
        obsname='mlo'
        eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
        caldat,jd,mm,dd,yy,hour,min,sec
        doy=fix(julday(mm,dd,yy)-julday(12,31,yy-1))
        time=hour+min/60.d0+sec/3600.d0
; Where on Earth is Moon at zenith?
        get_lon_lat_for_moon_at_zenith,longitude,latitude
        altitude=(dis-6371.d0);   /1000.0d0     ;km
        moonlat=latitude(0)
        moonlong=longitude(0)
        sunglint,doy,time,moonlat,moonlong,altitude,glat,glon,gnadir,gaz
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

PRO getJDandfilterandstuff,filnam,JD,filternam
filtername=' '
str="ls "+filnam+" | sed 's/_/ /g' | sed 's/\// /g' > hej"
spawn,str
ss=''
openr,1,'hej'
readf,1,ss
close,1
idx=strpos(ss,'245')
JD=double(strmid(ss,idx,15))
idx=strpos(ss,' B ')
if (idx(0) ne -1) then filternam=(strmid(ss,idx+1,1))
idx=strpos(ss,' V ')
if (idx(0) ne -1) then filternam=(strmid(ss,idx+1,1))
idx=strpos(ss,' VE1 ')
if (idx(0) ne -1) then filternam=(strmid(ss,idx+1,3))
idx=strpos(ss,' VE2 ')
if (idx(0) ne -1) then filternam=(strmid(ss,idx+1,3))
idx=strpos(ss,' IRCUT ')
if (idx(0) ne -1) then filternam=(strmid(ss,idx+1,5))
return
end

files=['observed_image_JD2456073.7781942.fits','observed_image_JD2456073.7983881.fits','observed_image_JD2456073.7472223.fits']
files=file_search('/data/pth/DARKCURRENTREDUCED/SELECTED_1/245*.fits',count=nfiles)
w=10
openw,77,'jumps_allselected_1.txt'
for i=0,n_elements(files)-1,1 do begin
im=readfits(files(i),header,/sil);+400
filternam=''
getJDandfilterandstuff,files(i),JD,filternam
get_everything_fromJD,JD,phase,azimuth,airmass,longlint
        get_info_from_header,header,'DISCX0',x0
         get_info_from_header,header,'DISCY0',y0
         get_info_from_header,header,'RADIUS',radius
if (x0-radius gt 20 and x0+radius lt 511-20) then begin
row=avg(im(*,y0-w:y0+w),1)
plot,row,yrange=[min(im),min(im)+30]
x1=x0-radius+10
x2=x0-radius+10+4*w
x3=max([0,x0-radius-10-w])
x4=x0-radius-10
;print,x1,x2,x3,x4
jump=(mean(row(x1:x2))-mean(row(x3:x4)))/max(smooth(im,11))
oplot,[x1,x1],[!Y.crange]
oplot,[x2,x2],[!Y.crange]
oplot,[x3,x3],[!Y.crange]
oplot,[x4,x4],[!Y.crange]
print,format='(f15.7,1x,a5,f12.8,2(1x,f9.3))',jd,filternam,jump,phase,airmass
printf,77,format='(f15.7,1x,a5,f12.8,2(1x,f9.3))',jd,filternam,jump,phase,airmass
endif
endfor
close,77
end
