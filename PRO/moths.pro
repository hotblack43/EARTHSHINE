jd1=julday(1,6,1995,02,59,00)
jd2=julday(1,1,2013,23,59,00)
obsname='lund'
openw,33,'Moonshine_Bjerringbro_kl2Nat.dat'
for jd=jd1,jd2,1.0d0 do begin
     moonpos, jd, ra_moon, dec_moon
     eq2hor, ra_moon, dec_moon, jd, alt, az, ha, obsname=obsname
mphase,jd,k
if (alt le 0) then k=0
caldat,jd,mm,dd,yy,hh
print,yy,mm,dd,hh,k
printf,33,yy,mm,dd,hh,k
;print,jd-jd1+1,k
;printf,33,jd-jd1+1,k
endfor
close,33
end
