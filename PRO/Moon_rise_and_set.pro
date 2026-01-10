PRO moonriseandset,jd,alt_moon,alt_sun
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
obsname='lapalma'
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
		SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname

RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG


return
end

openw,5,'moonriseandset.dat'
fmt='(f20.5,1x,f8.3)'
for JD=double(julday(12,7,2007,0,0,0)),double(julday(1,9,2008,0,0,0)),1.0d0/2./24. do begin
moonriseandset,jd,alt_moon,alt_sun
if (alt_sun lt -5) then begin
	printf,5,format=fmt,jd,alt_moon &print,format=fmt,jd,alt_moon
	endif
endfor
close,5
;-------
openr,5,'moonriseandset.dat'
while not eof(5) do begin
readf,5,x,y
tmin=1e36
tmax=-1e36
if (y gt 45.) then begin
tmin=min([tmin,x])
tmax=max([tmax,x])
endif
if (y le 45.) then begin
print,tmin,tmax
endif

endwhile

close,5
end