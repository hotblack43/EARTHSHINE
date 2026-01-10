 FUNCTION zenithangsun,x
 ; returns Moons zenith angle at Julian day jd (which must be passed via the common block)
 ; used by get_lon_lat_for_sun , below.
 common time,jd
 longitude=x(0)
 latitude=x(1)
 SUNPOS, jd, ra_sun, dec_sun
 eq2hor, ra_sun, dec_sun, jd, alt_sun, az_sun, ha_sun,  lon=longitude,lat=latitude
 zenithangsun=90.-alt_sun
 return,zenithangsun
 end
 PRO get_lon_lat_for_sun_at_zenith,lon,lat
 ; routine for using POWELL to find where the Moon is right overhead on Earth
 ; Define the fractional tolerance:
 ftol = 1.0d-8
 ; Define the starting point:
 P = [0.0d0,0.0d0]
 ; Define the starting directional vectors in column format:
 xi = TRANSPOSE([[1.0, 0.0],[0.0, 1.0]])
 ; Minimize the function:
 POWELL, P, xi, ftol, fmin, 'zenithangsun',/DOUBLE
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

PRO find_daynightline,lons,lats
; Given JD will find points on Earth where the Sun seems to be rising or setting
common time,jd
get_lon_lat_for_sun_at_zenith,lons,lats
return
end




; code to test the subrouytine that finds the lon,lat set ofpoints all on the sunset (or rise) line.
common time,jd
jd=systime(/julian,/utc)
caldat,jd,mm,dd,yy,hh,mi,se
find_daynightline,lons,lats
print,format='(a,1x,f15.7)','jd: ',jd
print,mm,dd,yy,hh,mi,se
print,'Sun is overhead at lon,lat: ',lons,lats,' deg E/N'
end
