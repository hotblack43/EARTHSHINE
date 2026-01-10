PRO getearthimage,jd,lon,lat
;--------------------------------------------------------------------------------------
; Will generate a picture of the Earth as seen from the Moon at a certain input time
; will show day(nigt effects
; will use NCEP 4xdaily tcdc cloud cover
; First generate the map of intensities to show
; Need a land-sea map to generate a sea-land type albedo map
get_land_sea,lon,lat,landseamask
idx=where(landseamask eq -1)
landseamask(idx)=1
maptoshow=0.05+0.10*landseamask
; need the cloud map
get_tcdc_2010_2012,jd,cloud,lonX,latX
if (total(lon - lonX) ne 0 or total(lat ne lat) ne 0) then stop
cloud=cloud/100.
maptoshow=cloud*0.8+(1.-cloud)*maptoshow
; need the day-night map
SUNPOS, jd, ra_sun, dec_sun
for i=0,N_ELEMENTS(LON)-1,1 DO BEGIN
for J=0,N_ELEMENTS(LAT)-1,1 DO BEGIN
eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha, lon=lonX(i),lat=latX(j)
if (alt_sun lt 0) then maptoshow(i,j)=0.0
maptoshow(i,j)=maptoshow(i,j)*sin(alt_sun*!dtor)	; illumination effect
endfor
endfor
; get the view point
get_lon_lat_for_moon_at_zenith,seenfromlon,seenfromlat
rotangle=0
distancetomoon=384000.0/6371.0
map_continents,/overplot
return
end

;;....
;common time,jd
; define jd=....
;get_tcdc_2010_2012,jd,map,lon,lat
;getearthimage,jd,lon,lat
;.........
