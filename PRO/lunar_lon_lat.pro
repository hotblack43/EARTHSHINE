PRO lunar_lon_lat,JD,lon,lat
;---------------------------------------------------------------------------------------------
; Code to return the longitude and latitude (in degrees) of the sublunar
; point on Earth - this, the lon,lat of the point where the line from Earth to
; Moon pierces the Earth's surface, given the time (as JD Julian day).
;---------------------------------------------------------------------------------------------
MOONPOS, jd, ra_moon, DECmoon, dis
; get the Sidereal Time in Greenwich (i.e. the Hr angle of the Vernal Equinox)
lonGreenwich=0.0
lsidtim,jd*1.0d0,lonGreenwich,sidtim
GST=sidtim/2.0d0/!pi*360.0d0	; GST (in degrees)
lat = DECmoon
lon = (360 - (GST - ra_moon)) mod (360.0d0)
return
end
