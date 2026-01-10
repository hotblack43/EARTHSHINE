ntry=10L
obsname='mlo'
kstep=1.0
	lolim=0
	gtlim=lolim+kstep
title=strcompress(obsname+' Moon above 45 deg., Sun below -5, 30 yrs since 2000.'+string(lolim)+'<k<'+string(gtlim))
; 2011-07-26 14:32:38
mm=12
dd=21
yy=2011
hour=1
min=32
sec=38
jdstart=julday(mm,dd,yy,hour,min,sec)
jdstart=2455917.12d0+14
jdstop=jdstart+31.
jdstep=3./24.	; each 3 hours
openw,33,'glintccords.dat'
for jd_i=jdstart,jdstop,jdstep do begin
	caldat,jd_i,mm,dd,yy,hr,mi,sec
	jd=jd_i
	MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
	eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
	caldat,jd,mm,dd,yy,hour,min,sec
	doy=fix(julday(mm,dd,yy)-julday(12,31,yy-1))
	time=hour+min/60.d0+sec/3600.d0
; Where on Earth is Moon at zenith?
	finding_longlat_moon_at_zenith,mm,dd,yy,hour,min,sec,longitude,latitude
	altitude=(dis-6371.d0);   /1000.0d0	;km
	moonlat=latitude(0)
	moonlong=longitude(0)
	sunglint,doy,time,moonlat,moonlong,altitude,glat,glon,gnadir,gaz
	print,format='(f16.7,1x,2(1x,f9.3),a,i2,1x,i2,1x,i4,1x,i2,1x,i2,1x,f4.1)',jd,glat,glon,' at: ',mm,dd,yy,hr,mi,sec
	printf,33,glat,glon
endfor
close,33
; map it
data=get_data('glintccords.dat')
glat=reform(data(0,*))
glon=reform(data(1,*))
map_set
map_continents,/overplot
oplot,glon,glat,psym=7,color=fsc_color('red')
map_grid,/overplot
end

