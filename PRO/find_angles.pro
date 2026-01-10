PRO get_sunmoonangle,jd,angle
; returns the angle between Sun and Moon as seen from Earth
angle=1
MOONPOS, jd, ra_moon, dec_moon, dis
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
; Will report the angle between Sun and Moon as seen from Earth for any input FITS image 
; of the Moon.
;-----------------------------------------------------------------------------------------
openw,44,'sunmoonangle.dat'
openr,2,'files.txt'
while not eof(2) do begin
b=''
readf,2,b
jd=double(strmid(b,0,14))
get_sunmoonangle,jd,angle
mphase,jd,k
printf,44,b,angle,k
endwhile
close,2
close,44
end

