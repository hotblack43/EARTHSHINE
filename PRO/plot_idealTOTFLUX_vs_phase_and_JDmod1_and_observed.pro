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
;-------------------------------------------
data=get_data('idealTOTFLUX.dat')
jd=reform(data(1,*))
idTOT=reform(data(0,*))
n=n_elements(jd)
openw,44,'p.dat'
for i=0,n-1,1 do begin
getphasefromJD,JD(i),phase
print,format='(f15.7,1x,f7.2,1x,f5.2)',jd(i),phase,22.-2.5*alog10(idTOT(i))
printf,44,format='(f15.7,1x,f7.2,1x,f7.4)',jd(i),phase,22.-2.5*alog10(idTOT(i))
endfor
close,44
data=get_data('p.dat')
jd=reform(data(0,*))
ph=reform(data(1,*))
idmag=reform(data(2,*))
;
!P.MULTI=[0,1,2]
plot,jd mod 1,idmag,psym=7
plot,ph,idmag,psym=7
end

