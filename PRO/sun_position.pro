jdstart=julday(1,1,2008)
jdstop=julday(12,31,2008)
icount=0
for jd=double(jdstart),double(jdstop),1.0d0/24.0d0/6.d0 do begin
; Where is the Sun in the local sky?
	SUNPOS, jd, ra_sun, dec_sun
	eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,lat=55,lon=12
	caldat,jd,mm,dd,yy,hh,mi
	if (icount eq 0 and dd eq 15) then begin
	x=az	
	y=alt_sun
	endif
	if (icount gt 0 and dd eq 15) then begin
	x=[x,az]	
	y=[y,alt_sun]
	print,mm,dd,yy,hh,mi,icount
	endif
	icount=icount+1
endfor
plot,x,y,min=0.0,psym=4
end
