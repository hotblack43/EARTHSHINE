
jd0=julday(5,31,2004,21)
jd1=julday(7,3,2004,21)
jdstep=0.199
for jd=jd0*1.0d0,jd1*1.0d0,jdstep*1.0d0 do begin
print,jd
endfor

MOONPOS, jd, ramoonR, decmoonR, dis, geolongMOONrads, geolatMOONrads,/RADIAN
SUNPOS, jd, rasunR, decsunR, elongSUNrdas,obltR,/RADIAN
d1 = sphdist(geolongMOONrads, geolatMOONrads, elongSUNrdas, 0.0)
new_d1=d1
if (geolongMOONrads-elongSUNrdas gt !pi) then new_d1=2.*!pi-new_d1
print,format='(6(f8.3,1x),1x,i2,1x,i2,1x,i4)',k,geolongMOONrads,elongSUNrdas,geolongMOONrads-elongSUNrdas,d1,new_d1,mm,dd,yy

end
