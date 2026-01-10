X = [-6, 0, 6, 0, -6]
Y = [0, 6, 0, -6, 0]
USERSYM, X, Y,/fill
decomposed=0
loadct=39
start=julday(10,10,2006)*1.0d0
stop=julday(11,18,2006)*1.0d0
step=.1/24.
plot,[0,1,2],[2,3,4],/nodata,xrange=[0,360],yrange=[0,60],xtitle='Days since start',title='Start:'+'Oct 10 2006'

for jd =start,stop,step do begin
caldat,jd,mm,dd,yy
; Sun
SUNPOS, jd, ra, dec
eq2hor, ra, dec, jd, sun_alt, sun_az,lon=-38,lat=72.5
; Moon
MOONPOS, jd, ra, dec, dis, geolong, geolat
MPHASE, jd, k
eq2hor, ra, dec, jd, moon_alt, moon_az,lon=-38,lat=72.5
moon_alt_radians=moon_alt/180.*!pi
airmass=1./tan(moon_alt_radians)
;
oplot,[moon_az,moon_az],[moon_alt,moon_alt],psym=4
oplot,[sun_az,sun_az],[sun_alt,sun_alt],psym=2

endfor
end
