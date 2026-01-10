PRO moonphase_pth2,jd,phase_angle_M,phase_angle_E,alt_moon,alt_sun,obsname
 ;-----------------------------------------------------------------------
 ; Set various constants.
 ;-----------------------------------------------------------------------
RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]


 observatory, obsname, obs
 observatory_longitude = -obs.longitude
 observatory_latitude  = obs.latitude
 observatory_altitude  = obs.altitude
 
;print,'Lon,lat,altitude,name of observatory : ',observatory_longitude,observatory_latitude,observatory_altitude
 
 MOONPOS, jd, ra_moon, DECmoon, dis
 eq2hor, RA_moon, DECmoon, JD, alt_moon, az, ha, OBSNAME=obsname
 SUNPOS, jd, ra_sun, DECsun
 eq2hor, RA_sun, DECsun, JD, alt_sun, az, ha, OBSNAME=obsname
 
 RAdiff = ra_moon - ra_sun
 sign = +1
 if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
 phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
 phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
 return
 end
