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


;==========================================
; example calling code
;
JD=systime(/julian)
get_sunglintpos,jd,glon,glat,az_moon,alt_moon,moonlat,moonlong
print,'Coordinates of Sunglint, right now, as seen from Moon is: lat,lon= ',glat,glon
end
