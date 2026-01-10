PRO sunupdown,jd,lon,lat,sunup,sund
;caldat,jd,mm,dd,yy,hh,mi
doy=fix(jd-julday(12,31,2015,0,0,0))
time=(jd-long(jd))*24.0
zensun,doy,time,lat,lon,zenith,azimuth,solfac,sunrise=sunup,sunset=sund,local=local
tzone=systime(/julian)-systime(/julian,/utc)
sund=long(jd)+(sund-12.0)/24.+tzone
sunup=long(jd)+(sunup-12.0)/24.+tzone
end

lat=55.715
lon=12.558
jd=systime(/julian)
sunupdown,jd,lon,lat,sunup,sund
print,sunup,sund
caldat,sunup,mm,dd,yy,hh,mi & print,'Sun up at: ',mm,dd,yy,hh,mi
caldat,sund,mm,dd,yy,hh,mi & print,'Sun down at: ',mm,dd,yy,hh,mi
end
