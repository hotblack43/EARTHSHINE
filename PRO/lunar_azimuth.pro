openw,12,'Very_loong_list_of_Moon_data.txt'
start=julday(1,1,2010)*1.0d0
stop=julday(1,1,2010+20)*1.0d0
step=1./24.d0
station_lon=15  ; Alps
lon_rad=station_lon/180.*!pi
wave=0.5	; microns 500nm
altitude= 0.0 ; 4.5	; km
pressure=760.*exp(-altitude/7.)
openw,4,'lunar_az_limits.dat'
for station_lat=50,0,-1 do begin ; from Alps
lat_rad=station_lat/180.*!pi
;
small_az=1e10
big_az=-1e10
for jd =start,stop,step do begin
; Sun
SUNPOS, jd, ra, dec
eq2hor, ra, dec, jd, sun_alt, sun_az,lon=station_lon,lat=station_lat
; Moon
MOONPOS, jd, ra, dec, dis, geolong, geolat
MPHASE, jd, k
eq2hor, ra, dec, jd, moon_alt, moon_az,lon=station_lon,lat=station_lat
moon_alt_radians=moon_alt/180.*!pi
am1=1./tan(moon_alt_radians)
am=airmass(jd,ra/180.*!pi,dec/180.*!pi,lat_rad,lon_rad,wave,pressure)
if (am gt 0 and am le 2.3) then begin
;print,format='(3(1x,f8.4))',am,am1,moon_alt
;printf,4,jd,moon_az
if (moon_az lt small_az) then small_az=moon_az
if (moon_az gt big_az) then big_az=moon_az
endif
endfor
;close,4
;data=get_data('lunar_az.dat')
;jd=reform(data(0,*))
;az=reform(data(1,*))
;plot,jd,az
print,station_lat,small_az,big_az
printf,4,station_lat,small_az,big_az
endfor
close,4
end
