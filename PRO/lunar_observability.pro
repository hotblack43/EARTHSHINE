start=julday(1,1,2007)*1.0d0
stop=julday(4,1,2009)*1.0d0
step=.1/24.
old_jd=start-step
nstations=8
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
for istat=7,nstations-1,1 do begin
set_plot,'ps
device,/encapsulated,file=strcompress(tstr(istat)+'.eps',/remove_all)
station_long=station_lon(istat)
station_lati=station_lat(istat)
openw,13,'label.txt'
printf,13,tstr(istat)
close,13
openw,12,'verylonglistoflunardata.txt'
max_alt=-9999
for jd =start,stop,step do begin
	delta_day=fix(abs(old_jd-jd)*24)
	caldat,jd,mm,dd,yy,hh,min,sec
; Sun
	SUNPOS, jd, ra, dec
	eq2hor, ra, dec, jd, sun_alt, sun_az,lon=station_long,lat=station_lati
; Moon
	MOONPOS, jd, ra, dec, dis, geolong, geolat
	MPHASE, jd, k
	eq2hor, ra, dec, jd, moon_alt, moon_az,lon=station_long,lat=station_lati
	moon_alt_radians=moon_alt/180.*!pi
	airmass=1./tan(moon_alt_radians)
	if (moon_alt gt max_alt and sun_alt lt -5) then begin
		max_alt=moon_alt
	endif
		if (moon_alt gt 0 and sun_alt lt -5) then printf,12,moon_alt,moon_az
endfor
		print,'Maximum altitude:',max_alt,sun_alt,mm,dd,yy,hh
close,12
; plot away..
titstr=''
openr,13,'label.txt'
readf,13,titstr
close,13
file='verylonglistoflunardata.txt'
data=get_data(file)
lunar_alt=reform(data(0,*))
lunar_lon=reform(data(1,*))
;----------------
alt_limit=30.
idx=where(lunar_alt ge alt_limit)
alt_limit=15.
jdx=where(lunar_alt ge alt_limit)
histo, lunar_alt,0,90,2,xtitle='Lunar altitude',ytitle='N',xrange=[0,90],title=titstr,/abs
if (idx(0) ne -1) then histo, lunar_alt(idx),0,90,2,/overplot,/abs
if (jdx(0) ne -1) then histo, lunar_alt(jdx),0,90,2,/overplot,/abs
histo, lunar_lon,0,360,5,xtitle='Lunar azimuth',ytitle='N',xrange=[0,360],title=titstr,/abs
if (idx(0) ne -1) then histo, lunar_lon(idx),0,360,5,/overplot,/abs
if (jdx(0) ne -1) then histo, lunar_lon(jdx),0,360,5,/overplot,/abs
device,/close
endfor	
end
