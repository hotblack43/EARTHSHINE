PRO get_sunmoonangle,jd,angle
COMPILE_OPT idl2, HIDDEN
; returns the angle between Sun and Moon as seen from Earth
angle=1
MOONPOS, jd, ra_moon, dec_moon, dis
obsname='MLO'
eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
; Where is the Sun in the local sky?
        SUNPOS, jd, ra_sun, dec_sun
        eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  OBSNAME=obsname
; what is the angular distance between Moon and SUn?
u=0     ; radians
gcirc,u,ra_moon*!dtor, dec_moon*!dtor,ra_sun*!dtor, dec_sun*!dtor,dis
angle=dis/!pi*180.
return
end

;-----------------------------------------------------------------------------------------
; Will report the angle between (180 minus) Sun and Moon as seen from Earth for any JD
; given by the loop
;-----------------------------------------------------------------------------------------
COMPILE_OPT idl2, HIDDEN
openw,23,'SEM_angle.tab'
for jd=julday(1,1,2010,0,0,1),julday(1,1,2013),1./24. do begin
;for jd=systime(/julian)-1,systime(/julian)-1+365,1./24./4. do begin
get_sunmoonangle,jd,angle
mphase,jd,k
moonpos, JD, RAmoon, DECmoon
obsname='MLO'
eq2hor, ramoon, decmoon, jd, alt_moon, az, ha,  OBSNAME=obsname
sunpos, JD, RAsun, DECsun
eq2hor, RAsun, DECsun, JD, sun_alt, sun_az, ha, OBSNAME=obsname
caldat,jd,mm,dd,yy,hh,mi,se
fmtstr='(f15.7,1x,1x,f7.2)'
angle=abs(angle)
if (ramoon gt RAsun) then angle=-abs(angle)
print,format=fmtstr,jd,angle
printf,23,format=fmtstr,jd,angle
;
endfor
close,23
end

