; Tabulating position of Moon or Sun altitude
mm=1
dd=1
yy=2011
obsname='lund'
get_lun,w
openw,w,'SunandMoonaltitude.tab'
for jd=double(julday(mm,dd,yy,12,0,0)),double(julday(mm,dd+1,yy,12,0,0)),3./24./60.d0 do begin
     SUNPOS, jd, ra_sun, dec_sun
     eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha, obsname=obsname
     moonpos, jd, ra_moon, dec_moon
     eq2hor, ra_moon, dec_moon, jd, alt_moon, az, ha, obsname=obsname
caldat,jd,a,b,c,d,e,f
print,format=fmt,jd,a,b,c,d,e,f,alt_sun,alt_moon
printf,w,format=fmt,jd,a,b,c,d,e,f,alt_sun,alt_moon
fmt='(f20.6,2(1x,i2),1x,i4,3(1x,i2),2(1x,f9.3))'

endfor
close,w
free_lun,w
end
