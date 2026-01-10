start=julday(1,1,2007)*1.0d0
stop=julday(4,1,2009)*1.0d0
step=.5/24.	; time step in units of days
old_jd=start-step
nstations=9
station_lon=fltarr(nstations)
station_lat=fltarr(nstations)
tstr=strarr(nstations)
station_lon(0)=25	; Oulu
station_lat(0)=65	; Oulu
tstr(0)='Oulu'
station_lon(1)=-50	; Søndre Strømfjord
station_lat(1)=67	; Søndre Strømfjord
tstr(1)='Sdr. Stromfjord'
station_lon(2)=26	; Sondakylä
station_lat(2)=67	; Sondakylä 
tstr(2)='Sodankyla'
station_lon(3)=-69; Thule
station_lat(3)=76.5	; Thule
tstr(3)='Thule'
station_lon(4)=11	; CPH
station_lat(4)=55	;  CPH
tstr(4)='Copenhagen'
station_lon(5)=-38	; Summit
station_lat(5)=72	; Summit
tstr(5)='Summit'
station_lon(6)=-69; NP
station_lat(6)=90	; NP
tstr(6)='North Pole'
station_lon(7)=-69; Eq
station_lat(7)=0	; Eq
tstr(7)='Equator'
station_lon(8)=17; Canarias
station_lat(8)=28.5	; Canarias
tstr(8)='Canary Islands'
for istat=0,nstations-1,1 do begin
set_plot,'ps
device,/encapsulated,file=strcompress(tstr(istat)+'half_hourly.eps',/remove_all)
station_long=station_lon(istat)
station_lati=station_lat(istat)
openw,13,'label.txt'
printf,13,tstr(istat)
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
	if (k gt 0.2 and k lt 0.8 and moon_alt gt 15 and sun_alt lt -5) then printf,33,double(jd),rotation_rate*3600.,istat
endfor	; end of jd loop
close,33
data=get_data('field_rotation.dat')
x=reform(data(0,*))
y=reform(data(1,*))
plot,x,y,title=tstr(istat),xtitle='JD',ytitle='Field rotation (arsec/second)',charsize=1.5,xstyle=1,ystyle=1
endfor	; end of istat loop
end
