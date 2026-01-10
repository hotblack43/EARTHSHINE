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



file='all_JD_.dat'
obsname='mlo'
openr,1,file
openw,2,'list_of_JD_phase_k.dat'
while not eof(1) do begin
jd=0.0d0
readf,1,jd
mphase,jd,k
MOONPHASE,jd(0),phase_angle_M,alt_moon,alt_sun,obsname
print,format='(f15.7,2(1x,f9.3))',jd,phase_angle_M,k
printf,2,format='(f15.7,2(1x,f9.3))',jd,phase_angle_M,k
endwhile
close,1
close,2
data=get_data('list_of_JD_phase_k.dat')
jd=reform(data(0,*))
phase=reform(data(1,*))
k=reform(data(2,*))
!P.MULTI=[0,1,2]
plot,phase,k,xtitle='Phase',ytitle='k',charsize=2,psym=7
histo,phase,-180,180,3,xtitle='Phase'
end
