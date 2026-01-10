

start=julday(4,1,2006)*1.0d0
stop=julday(4,2,2006)*1.0d0
step=1./24.d0

station_lon=11	; CPH
for station_lat=90.,0.,-15. do begin	;  CPH
old_az=0.0
old_time=0.0
x=0.0
y=0.0
for jd =start,stop,step do begin

    SUNPOS, jd, ra, dec
    eq2hor, ra, dec, jd, alt, az,lon=station_lon,lat=station_lat
    x=[x,jd]
    y=[y,az-old_az]
    old_az=az

endfor
x=x(2:n_elements(x)-1)
y=y(2:n_elements(y)-1)
idx=where(y gt 0)
x=x(idx)
y=y(idx)
caldat,x,mm,dd,yy,hh,min,sec
fracyear=yy+(mm-1.d0)/12.+dd/365.25d0+hh/24./365.25d0+min/24./365.25/60.
plot,fracyear,y,ytitle='Degrees/hour',title='Solar angular speed in azimuth: lat='+string(station_lat),charsize=1.3,xstyle=1
endfor
end
