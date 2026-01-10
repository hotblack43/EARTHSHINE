PRO bestspot_radec,jd,obsname,sun_altitude,alt,ra,dec
sunpos, JD, RAsun, DECsun
eq2hor, RAsun, DECsun, JD, sun_altitude, sun_az, ha, OBSNAME=obsname , $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1
alt_darkest_spot,sun_altitude,alt
; get the ra,dec of that spot
spotaz=sun_az+180.0
while (spotaz gt 360.0) do begin
spotaz=spotaz-360.0
endwhile
HOR2EQ, alt, spotaz, jd, ra, dec,  OBSNAME=obsname , PRECESS_= 1, NUTATE_= 1, REFRACT_= 1,  ABERRATION_= 1
return
end

openw,67,'best_altitude.dat'
obsname='mlo'
for im=0.0,1.0,.001 do begin
jd=julday(3,12,2010,0,0,0)+im
sunpos, JD, RAsun, DECsun
eq2hor, RAsun, DECsun, JD, sun_altitude, sun_az, ha, OBSNAME=obsname , $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1
bestspot_radec,jd,obsname,sun_altitude,alt,ra,dec
printf,67, sun_altitude,alt
endfor
close,67
end

