obsname='mlo'
observatory, obsname, obs
observatory_longitude = -obs.longitude
observatory_latitude  = obs.latitude
observatory_altitude  = obs.altitude
print,observatory_longitude,observatory_latitude,observatory_altitude
jd=2455707.7730d0;julday(5,1,1,2011,12,12,12)
jd=julday(5,26,2011,6,34,21)
print,'JD: ',jd
ra=9.86/24.*360.0d0
dec=-18.133611
;
eq2hor, RA, DEC, JD, altitude, az, ha, LAT=observatory_latitude , LON=observatory_longitude ,  $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
print,'Altitude=',altitude
end

