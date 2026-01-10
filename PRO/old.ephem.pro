PRO ephem,jd,alt,az
obslong=342.1184-360.0
obslat=+28.7606 
obsaltitude=2326
MOONPOS, jd, ra, dec, dis, geolong, geolat
eq2hor, ra, dec, jd, alt, az, LAT=obslat , LON=obslong , $
ALTITUDE=obsaltitude

return
end

for hh=18.,24.,.1 do begin
jd=julday(5,27,2004,hh,00,00)
ephem,jd,alt,az
print,hh+2,alt,az
endfor
end
