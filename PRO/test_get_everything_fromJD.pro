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


PRO MOONPHASE_PTH,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
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
MOONPHASE_PTH,jd,azimuth,phase,alt_moon,alt_sun,obsname
; get the airmass
moonpos, JD, RAmoon, DECmoon
am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
; get the longlint
get_sunglintpos,jd,longlint,glat,az_moon,alt_moon,moonlat,moonlong
return
end

; typical use
; file='listofJDs.txt'
; openr,1,file
; ic=0
; get_lun,uyujk
; openw,uyujk,'ERASMEjkhgjygvf.dat'
; while not eof(1) do begin
; JD=0.0d0
; readf,1,JD
; get_everything_fromJD,JD,phase,azimuth,airmass,longlint
; print,format='(f15.7,4(1x,f9.3))',JD,phase,azimuth,airmass,longlint
; printf,uyujk,format='(f15.7,4(1x,f9.3))',JD,phase,azimuth,airmass,longlint
; ic=ic+1
; endwhile
; print,'N: ',ic
; close,1
; close,uyujk
; data=get_data('ERASMEjkhgjygvf.dat')
; phase=reform(data(1,*))
; glon=reform(data(4,*))
; !P.CHARSIZE=2
; plot,phase,glon,psym=7,xtitle='Lunar phase',ytitle='Sunglint longitude [deg East]'
; end
