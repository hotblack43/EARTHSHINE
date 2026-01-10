common SITE,LAT,LNG,TZONE
lat=55.7157
LNG=12.5612
TZONE=+0	; just a dummy value NOT USED BY THIS CODE
openw,44,'zenithpos.dat',/append
for i=0L,60.*24.,1 do begin
JD=1.0d0*systime(/julian)
ZENPOS, JD, Ra, Dec
caldat,JD,mm,dd,yy,hh,mi,se
radec, ra/!dtor, dec/!dtor, ihr, imin, xsec, ideg, imn, xsc
print,format='(a,f15.7,1x,i2,a,i2,a,i4,a,i2,a,i2,a,f6.3)','JD: ',JD,mm,'/',dd,'/',yy, ' ',hh,':',mi,':',se
fmt1='(a4,f11.6,a,a,f9.6)'
print,format=fmt1,'RA: ',ra/!dtor,' deg', ' DEC: ', dec/!dtor
fmt='(a4,i2,a,i2,a,f5.2,a7,i3,a5,i2,a3,f5.2,a2)'
print,format=fmt,'RA: ',ihr,':', imin,':', xsec, '  DEC: ', ideg,' deg ', imn," ' ", xsc,' "'
eq2hor, ra/!dtor, dec/!dtor, jd, alt, az,lat=lat,lon=lng,precess_=1
print,alt,az
printf,44,format='(f15.7,2(1x,f11.6))',jd, alt, az
wait,45
endfor
close,44
end
