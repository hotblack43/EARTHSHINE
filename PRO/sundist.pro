




openw,33,'p.dat'
for jd=julday(1,1,2011,0,0,0),julday(1,1,2013,0,0,0),1.0d0 do begin
date=jd - 2400000
XYZ, date, x, y, z, EQUINOX = 2000
printf,33,date,sqrt(x^2+y^2+z^2)
endfor
close,33
data=get_data('p.dat')
jd=reform(data(0,*))
d=reform(data(1,*))
plot,jd,d,ystyle=3,xstyle=3,psym=7
end
