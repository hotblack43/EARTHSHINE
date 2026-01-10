

;-------------------------------
; Code to find  times hwen the Moon and a given geostationary satellite are aligned
common time,jd
openw,33,'moongeopos.dat'
for jd=julday(1,1,2010,0,0,0),julday(1,1,2012,12,12,12),0.0743d0 do begin
        get_lon_lat_for_moon_at_zenith,longitude,latitude
print,format='(f15.7,2(1x,f9.3))',jd,longitude,latitude
printf,33,format='(f15.7,2(1x,f9.3))',jd,longitude,latitude
endfor
close,33
end
