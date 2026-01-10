ntry=5L
obsname='MSO'
obsname='holi'
obsname='saao'
obsname='keck'
obsname='lapalma'
kstep=1.0
	lolim=0
	gtlim=lolim+kstep
title=strcompress(obsname+' Moon above 45 deg., Sun below -5, 30 yrs since 2000.'+string(lolim)+'<k<'+string(gtlim))
print,title
mm=1
dd=1
yy=2000
hour=1
min=1
sec=0
date=[yy,mm,dd,hour,min,sec]
JULDATE, date, jdstart
jdstart=jdstart+2400000.d0
jdstop=jdstart+30L*365.
map_set,/mollweide,title=title
loadct,39
map_continents,/overplot,title=title,/fill,color=220
;for jd=jdstart,jdstart+3*365.,1./24./2. do begin
openw,33,'glintpoint.dat'
for try=0L,ntry-1,1 do begin
	jd=randomu(seed)*(jdstop-jdstart)+jdstart
	caldat,jd,mm,dd,yy,hour,min,sec
	doy=fix(julday(mm,dd,yy)-julday(12,31,yy-1))
	time=hour+min/60.d0+sec/3600.d0
; Where is the Moon in the local sky?
	MOONPOS, jd, ra, dec, dis, moongeolong, moongeolat
	altitude=dis-6371.	;km
	sunglint,doy,time,moongeolat,moongeolong,altitude,glat,glon,gnadir,gaz
	eq2hor, ra, dec, jd, alt_moon, az, ha,  OBSNAME=obsname
; Where is the Sun in the local sky?
	SUNPOS, jd, ra_sun, dec_sun
	eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  OBSNAME=obsname
; what is the Moon phase?
	MPHASE, jd, k
fmt_str='(f20.6,1x,i3,1x,f8.4,1x,f8.3,1x,f8.3,1x,f8.6,1x,f8.3,1x,f8.3)'
print,format=fmt_str,jd,doy,time,glat,glon,k,alt_moon,alt_sun
	if (alt_moon gt 45 and alt_sun le -5 and (k gt lolim and k lt gtlim)) then plots,glon,glat,psym=7
	printf,33,moongeolong,glon,glat
endfor
map_continents,/overplot,title=title,color=255,mlinethick=2
close,33
end


