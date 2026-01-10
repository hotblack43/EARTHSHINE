PRO MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
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
MOONPOS, jd, ra_moon, DECmoon, dis
distance=dis/6371.
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME='mlo';obsname
SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
return
end


PRO getphasefromJD,JD,phase
MOONPHASE,jd(0),phase_angle_M,alt_moon,alt_sun,obsname
phase=phase_angle_M
return
end

get_lun,w
fmt='(f20.6,2(1x,i2),1x,i4,3(1x,i2),1(1x,f9.3))'
openw,w,'ISS_MOON.tab'
for jd=double(julday(12,01,2022,12,0,0.0d0)),double(julday(12,01,2027,12,0,0.0d0)),1./24. do begin
	getphasefromJD,JD,phase
	caldat,jd,a,b,c,d,e,f
	printf,w,format=fmt,jd,a,b,c,d,e,f,phase
	print,format=fmt,jd,a,b,c,d,e,f,phase
endfor
close,w
free_lun,w
end
