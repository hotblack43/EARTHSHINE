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

PRO get_everything_fromJD,JD,phase,azimuth,am,longlint,glat
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

PRO getFILTERname,name_file,filtername
bits=strsplit(name_file,'_',/extract)
filtername=bits(2)
;print,name_file,filtername
return
end

PRO claimyourdata,JD,albedos,errors,alfa,n,airm,glint_lon,glint_lat,phase,filtername
airm=9.999
glint_lon=0.0
glint_lat=0.0
get_everything_fromJD,JD,phase,azimuth,airm,glint_lon,glint_lat
; fmt='(f15.7,5(1x,f8.4),1x,f10.3,1x,f15.3,1x,a)'
; JD,albedo,erralbedo,alfa,pedestal,xshift,RMSE,totfl,name
file='CLEM.profiles_fitted_results_April_24_2013.txt'
file='CLEM.profiles_fitted_results_July_24_2013.txt'
openr,2,file
ic=0
while not eof(2) do begin
str=''
readf,2,str
bits=strsplit(str,' ',/extract)
JDfile=double(bits(0))
albedofile=float(bits(1))
errorsfile=float(bits(2))
alfafile=float(bits(3))
pedestalfile=float(bits(4))
xshiftfile=float(bits(5))
RMSEfile=float(bits(6))
totfl_file=float(bits(7))
name_file=bits(8)
if (JD eq JDfile) then begin
getFILTERname,name_file,filtername
if (ic eq 0) then begin
albedos=albedofile
errors=errorsfile
alfa=alfafile
endif
if (ic gt 0) then begin
albedos=[albedos,albedofile]
errors=[errors,errorsfile]
alfa=[alfa,alfafile]
endif
ic=ic+1
endif
endwhile
n=n_elements(albedos)
close,2
return
end


;================================================
; code that finds those images where 3 fits differ by less
; than 2 sigma (in albedo)
; Prints a table of the good data
;================================================
openw,27,'CLEM_300_good_data_July.txt'
uniqJDs='uniqJDs.from_CLEMApril24file'
openr,1,uniqJDs
while not eof(1) do begin
JD=0.0d0
readf,1,JD
; find all lines with that JD in the big file
claimyourdata,JD,albedos,errors,alfa,n,airm,glint_lon,glint_lat,phase,filtername
; wheck how errors relate to spread, only look at 3-s
if (n eq 3) then begin
spread=(max(albedos)-min(albedos))
if (spread gt 2.*mean(errors)) then print,'Spread greater than errors'
if (spread le 2.*mean(errors)) then begin
	print,'Spread less than errors'
        fmt='(f15.7,4(1x,f8.4),3(1x,f6.1),1x,a)'
	print,format=fmt,JD,mean(albedos),mean(errors),mean(alfa),airm,phase,glint_lon,glint_lat,filtername
	printf,27,format=fmt,JD,mean(albedos),mean(errors),mean(alfa),airm,phase,glint_lon,glint_lat,filtername
endif
endif else begin
print,'n is not 3, skipping this JD: ',JD
endelse

endwhile
close,1
close,27
end

