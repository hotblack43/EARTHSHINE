start=julday(7,31,2006)*1.0d0
stop=julday(8,1,2006)*1.0d0
step=.1/24.	; time step in units of days
old_jd=start-step
nstations=9
;
station_lon=149.3; Canarias
station_lat=-33.7	; Canarias
tstr='Grove Creek'
;
station_lon=17; Canarias
station_lat=28.5	; Canarias
tstr='Canary Islands'

set_plot,'ps
device,/encapsulated,file=strcompress(tstr+'half_hourly.eps',/remove_all)
station_long=station_lon
station_lati=station_lat
openw,13,'label.txt'
printf,13,tstr
close,13
max_alt=-9999
duration=0
old_if_OK=0
alt_limit=15
openw,33,'field_rotation.dat'
for jd =start,stop,step do begin
	delta_day=fix(abs(old_jd-jd)*24)
	caldat,jd,mm,dd,yy,hh,min,sec
; Sun
	SUNPOS, jd, ra, dec
	eq2hor, ra, dec, jd, sun_alt, sun_az,lon=station_long,lat=station_lati
; Moon
	MOONPOS, jd, ra, dec, dis, geolong, geolat
	eq2hor, ra, dec, jd, moon_alt, moon_az,lon=station_long,lat=station_lati
	MPHASE, jd, k
	moon_alt_radians=moon_alt/180.*!pi
	rotation_rate=4.1666e-3*cos(station_lati*!dtor)*cos(moon_az*!dtor)/cos(moon_alt*!dtor)
;	print,rotation_rate*3600.,'arsec per second'
caldat,jd,mm,dd,yy,hh,min
	hour=hh+min/60.
	if (k gt 0.2 and k lt 0.8 and moon_alt gt 15 and sun_alt lt -18) then printf,33,hour,rotation_rate*3600.
endfor	; end of jd loop
close,33
data=get_data('field_rotation.dat')
x=reform(data(0,*))
y=reform(data(1,*))
plot,x,y,title=tstr,xtitle='Hour (UTC)',ytitle='Field rotation (arsec/second)',charsize=1.5,xstyle=1,ystyle=1,psym=7
device,/close
set_plot,'win
discradius=50	; in pixels
plot,x,y/206265.*discradius*3600.,title=tstr,xtitle='Hour (UTC)',ytitle='Rim rotation (pixels/hour)',charsize=1.5,xstyle=1,ystyle=1,psym=7
end
