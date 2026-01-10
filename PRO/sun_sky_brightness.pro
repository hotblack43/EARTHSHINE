PRO sun_sky_brightness,rho,mz,sz,Bsun
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
return
end
