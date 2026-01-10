jdstart=double(julday(1,1,2006))
jdstop=double(julday(12,31,2006))
over=0.0
under=0.0
for lati=0,90,10 do begin
for jd=jdstart,jdstop,1./24. do begin
sunpos,jd,ra,dec
eq2hor,ra,dec,jd,alt,az,lon=12,lat=lati
if (alt ge 0) then over=over+1.
if (alt lt 0) then under=under+1.
endfor
pct=1.0*over/(under+over)*100.0
print,'Sun over horison ',over/(under+over)*100.0,' % at lat=',lati
endfor
end

