PRO sunglint_pth,geolong,geolat,jd,moon_altitude,moon_az,sun_altitude,sun_az
MOONPOS, jd, RAmoon, DECmoon, dis, moon_geolong, moon_geolat
eq2hor, RAmoon, DECmoon, JD, moon_altitude, moon_az, moon_ha, LAT=geolat, LON=geolong

SUNPOS, jd, sun_ra, sun_dec
eq2hor, sun_ra, sun_dec, JD, sun_altitude,sun_az, sun_ha, LAT=geolat, LON=geolong
return
end

;===============================================
jd=julday(12,12,1997,12,12,12)
max_delta_altitude=1e9
max_delta_azimuth=1e9
for geolong=-180.0,180.0,1.0 do begin
for geolat=-90.0d0,90.0d0,1.0d0 do begin
	sunglint_pth,geolong,geolat,jd,moon_altitude,moon_az,sun_altitude,sun_az
	delta_altitude=moon_altitude-sun_altitude
	delta_azimuth=moon_az-sun_az
	if (abs(delta_altitude) lt max_delta_altitude and abs(delta_azimuth)-360 lt max_delta_azimuth) then begin
	print,geolong,geolat,delta_altitude,delta_azimuth
	max_delta_altitude=abs(delta_altitude)
	max_delta_azimuth=abs(delta_azimuth)-360
endif
endfor
endfor
end
