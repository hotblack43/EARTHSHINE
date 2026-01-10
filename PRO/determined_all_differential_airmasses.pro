FUNCTION am,zenith_angle,im
if (im eq 1) then am=1./cos(zenith_angle*!dtor)*[1.0-0.0012*((1./cos(zenith_angle*!dtor))^2-1.0)]
; Rosenberg formula
if (im eq 2) then am=1.0d0/(cos(zenith_angle*!dtor)+0.025*exp(-11.*cos(zenith_angle*!dtor)))
return,am
end

obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=-obs_struct.longitude
 print,'lon,lat: ',lon,lat
file='Chris_list_good_images.txt'
openr,1,file
openw,33,'differential_airmass.dat'
while not eof(1) do begin
jd=0.0d0
readf,1,jd
        moonpos, JD, RAmoon, DECmoon
	eq2hor, ramoon, decmoon, jd, alt_moon, az, ha,  OBSNAME=obsname
	d=0.3
printf,33,format='(f15.7,1x,f9.4)',jd,-am(90.-alt_moon-d/2.,1)+am(90.-alt_moon+d/2.,1)
endwhile
close,1
close,33
end
