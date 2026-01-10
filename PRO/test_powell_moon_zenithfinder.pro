FUNCTION zenithangMoon,x
common time,jd
longitude=x(0)
latitude=x(1)
        MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
        eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  lon=longitude,lat=latitude
zenithangMoon=90.-alt_moon
return,zenithangMoon
end

PRO get_lon_lat_for_Moon_at_zenith,jd,lon,lat
; routine for using POWELL to find where the Moon is overhead on Earth

; Define the fractional tolerance:
   ftol = 1.0d-8
   ; Define the starting point:
   P = [0.0d0,0.0d0]
   ; Define the starting directional vectors in column format:
   xi = TRANSPOSE([[1.0, 0.0],[0.0, 1.0]])
   ; Minimize the function:
   POWELL, P, xi, ftol, fmin, 'zenithangMoon',/DOUBLE
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


common time,jd
for jd=systime(/julian),systime(/julian)+1.,0.01d0 do begin
get_lon_lat_for_Moon_at_zenith,jd,lon,lat
print,format='(a,2(1x,f9.2),1x,f15.7)','Moon is overhead:',lon,lat,jd
endfor
end
