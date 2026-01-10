FUNCTION CIE_clear_sky_standard,chi,Z,Zs,a,b,c,d,e
 ; calculates the CIE Clear SKy Standard Luminance
 ;
 CIE_clear_sky_standard=f(chi,c,d,e)*psi(Z,a,b)/f(Zs,c,d,e)/psi(0.0,a,b)
 return, CIE_clear_sky_standard
 end

FUNCTION findGDdistance,alt1,az1,alt2,az2
; finds the great circle distance in degrees between the two points
; all inputs are in degrees
GC=great_circle(az1,alt1,az2,alt2)/6378388.d0/!pi/2.*360.0
return,GC
end


FUNCTION sun_sky_brightness,rho,mz,sz
;
; Follows Krisciunas and Schaefer PASP vol 103: pp.1033 (1991) but
; substitutes the Sun for the Moon in
; providing the brightness of a patch of sky given:
; rho 	- Sun/sky patch separation
; k	- extinction coefficient for the band considered
; mz	- Sun's zenith distance
; sz	- zenith distance of sky patch
;
k=0.172	; typical V band extinction at Mauna Loa
;
I_star = 10^(-0.4d0*(-26.86+12.73))
;
f_of_rho=10^5.36d0*(1.06d0+[cos(rho*!dtor)]^2)+10^(6.15d0-rho/40.d0)
;
x_of_z=(1.0d0-0.96d0*[sin(sz*!dtor)]^2)^(-0.5)
;
x_of_zm=(1.0d0-0.96d0*[sin(mz*!dtor)]^2)^(-0.5)
;
Bsun=f_of_rho*I_star*10^(-0.4d0*k*x_of_zm)*(1.0d0-10^(-0.4d0*k*x_of_z))
;
;print,format='(4(g10.4,1x))',I_star,f_of_rho,x_of_z,Bsun
return,Bsun
end

PRO CIE_absolute_sky_luminace_Sun_only,alt,az,sun_alt,sun_az,abs_lum
; Will evaluate the sky brightness at (alt,az) given the position of the Sun
; by using the CIE relative model and the KS absolute model.
; basic idea is that KS model may be better at zenith where multiple scattering 
; and other things (Mie scatt) is less of a problem, while the CIE relative model 
; is better at low altitudes.
;
;-------------------------------------------------------------------
; INPUTS : 
; alt,az is the sky positions
; sun_alt,sun_az is the solar position
; OUTPUT :
; abs_lum is the absolute luminance of the sky at alt,az 
;-------------------------------------------------------------------
; evaluate the CIE Model
; Type 11 or 12
     a=-1.0
     b=-0.32
     c=10.
     d=-3.0
     e=0.45
             element_azimuth=az
             element_zenith_dist=90.0 - alt
             sun_zenith_dist=sun_alt 
             Azz=abs(sun_az-element_azimuth)
             chi=acos(cos(sun_zenith_dist*!dtor)*cos(element_zenith_dist*!dtor)+sin(sun_zenith_dist*!dtor)*sin(element_zenith_dist*!dtor)*cos(Azz*!dtor))/!dtor
             CIE_relative_to_zenith=CIE_clear_sky_standard(chi,element_zenith_dist,sun_zenith_dist,a,b,c,d,e)
;
; Then get the KS value for zenith
rho=findGDdistance(sun_alt,sun_az,alt,element_azimuth)
mz=sun_zenith_dist
sz=element_zenith_dist
KS_at_zenith = sun_sky_brightness(rho,mz,sz)
abs_lum = CIE_relative_to_zenith * KS_at_zenith
return
end



; Code to evaluate absolute CIE sky luminance model using KS absolute at zenitha nd
; the relative CIE model
;
abslum=fltarr(360,90)
; ... get the Suns position
obsname='mlo'
jd=julday(12,12,2010,12,0,0)
SUNPOS, jd, ra_sun, DEsun
eq2hor, ra_sun, DEsun, jd, sun_alt, sun_az, ha_sun,  OBSNAME=obsname
for alt=0,89,1 do begin
for az=0,359,1 do begin
CIE_absolute_sky_luminace_Sun_only,alt,az,sun_alt,sun_az,abs_lum
abslum(az,alt)=abs_lum
endfor
endfor
surface,abslum,charsize=3
end
