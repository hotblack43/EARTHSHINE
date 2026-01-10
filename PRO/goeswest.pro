hh=17
min=15
yy=1997
mo=6
dd=3
jd=julday(mo,dd,yy,hh,min,0)
doy=fix(jd-julday(12,31,yy-1))
lat=0
lon=-75.5
alt=35887L
sunglint,doy,hh,lat,lon,alt,glat,glon
print,'sunglint alt,lat,lon=',alt,glat,glon
end

