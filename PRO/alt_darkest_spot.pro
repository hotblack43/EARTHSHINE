PRO alt_darkest_spot,solar_altitude,alt
;
; calculates the altitude of the darkest spot on the twilight sky 
; given the solar altitude
;
; alt = altitude of the darkest spot (in degrees), azimuth = solar az + 180 degrees
; solar_altitude = altitude of the Sun in degrees
;
; Note: Formula developed from CIE model 11 (or 12), and is valid for solar altitudes
; between -15 and + 40 degrees
;
alt = 78.952381 -0.59754690*solar_altitude
;
return
end
