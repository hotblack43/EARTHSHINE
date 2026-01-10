geolong=0.0d0
geolat=55.0d0
dec_max=-1e22
for jd=julday(5,15,2005,12,12,12),julday(8,15,2009,12,12,12),1.0d0/24.0d0/60.0d0 do begin
MOONPOS, jd, ra, dec, dis, geolong, geolat
if (dec gt dec_max) then begin
	dec_max=dec
	jd_max=jd
	caldat,jd_max,mm,dd,yy,hh,mi,se
endif
print,jd,dec,jd_max,dec_max,mm,dd,yy,hh,mi,se
endfor
end
