openw,12,'Very_loong_list_of_Moon_data.txt'
start=julday(1,1,2006)*1.0d0
stop=julday(1,1,2009)*1.0d0
step=1./24.
old_jd=start-step
station_lon=-50	; Søndre Strømfjord
station_lat=67	; Søndre Strømfjord
station_lon=25	; Oulu
station_lat=65	; Oulu
station_lon=-38	; Summit
station_lat=72	; Summit
station_lon=11	; Summit
station_lat=55	; Summit
;
lonstep=5
latstep=5
for jd =start,stop,step do begin
for station_lon=0,360-lonstep,lonstep do begin
for station_lat=-90,90,latstep do begin
caldat,jd,mm,dd,yy,hh,min,sec
doy=jd-julday(1,1,yy)
; Sun
SUNPOS, jd, ra, dec
eq2hor, ra, dec, jd, sun_alt, sun_az,lon=station_lon,lat=station_lat
; Moon
MOONPOS, jd, ra, dec, dis, geolong, geolat
MPHASE, jd, k
eq2hor, ra, dec, jd, moon_alt, moon_az,lon=station_lon,lat=station_lat
moon_alt_radians=moon_alt/180.*!pi
airmass=1./tan(moon_alt_radians)
; determine if Moon can be observed from the coordinate
if (sun_alt lt -5 and moon_alt gt 11 and (k gt 0.1 and k lt 0.8)) then begin
moon_alt_radians=moon_alt/180.*!pi
airmass=1./tan(moon_alt_radians)
caldat,jd,mm,dd,yy,hh,min,sec
doy=jd-julday(1,1,yy)

print,station_lat,station_lon,airmass,doy
printf,12,station_lat,station_lon,airmass,doy
endif
endfor
endfor
endfor
end
