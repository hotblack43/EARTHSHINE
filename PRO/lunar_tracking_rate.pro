jdstart=double(julday(1,1,2010))
jdstop=double(julday(1,1,2011))
jdstep=0.25d0;	/24.
openw,44,'data.tmp'
for jd=jdstart,jdstop,jdstep do begin
MOONPOS, jd, ra, dec, dis, geolong, geolat
printf,44,jd,ra,dec
endfor
close,44
data=get_data('data.tmp')
days=reform(data(0,*))
caldat,days,mm,dd,yy
fracyr=yy+(mm-1)/12.+dd/365.25
ra=reform(data(1,*))
dec=reform(data(2,*))
raderivative=deriv(days,ra)
decderivative=deriv(days,dec)
plot,fracyr,deriv(ra)*4./24.,yrange=[-0.5,0.8],ystyle=1,psym=3,ytitle='rate of lunar coordinates [deg/hr = asec/sec]',xtitle='Year',title='(upper) RA rate, (lower) Decl rate',xstyle=1
oplot,fracyr,deriv(dec)*4./24.,psym=3
end
