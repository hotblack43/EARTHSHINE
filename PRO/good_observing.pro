; RA
hh=13
mm=22.3
; DEC
deg=54
amin=22
;13 22 08.46 +54 22 41.5 
obsname='lund'
starname='ZetaUMa'
openw,2,strcompress(starname+'_altitudes.dat',/remove_all)
for jd=julday(9,20,2010,0,0,0),julday(9,30,2010,0,0,0),1./24./4. do begin
SUNPOS, jd, rasun, decsun
eq2hor, rasun, decsun, JD, altsun, azsun, ha, OBSNAME=obsname , $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1
if (altsun lt 0) then begin
caldat,jd,a,b,c,d,e,f
RAdegrees=hh*15.+ten(0,mm)
DECdegrees=ten(deg,amin)
eq2hor, RAdegrees, DECdegrees, JD, alt, az, ha, OBSNAME=obsname , $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1
print,format='(i2,1x,i2,1x,i4,1x,i2,1x,i2,1x,i2,1x,f9.3)',a,b,c,d,e,f,alt
printf,2,format='(i2,1x,i2,1x,i4,1x,i2,1x,i2,1x,i2,1x,f9.3)',a,b,c,d,e,f,alt
endif
endfor
close,2
end
