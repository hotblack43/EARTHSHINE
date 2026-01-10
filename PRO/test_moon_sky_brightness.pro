FUNCTION findGDdistance,alt1,az1,alt2,az2
; finds the great circle distance in degrees between the two points
; all inputs are in degrees
GC=great_circle(az1,alt1,az2,alt2)/6378388.d0/!pi/2.*360.0
return,GC
end

PRO moon_sky_brightness,lpa,rho,mz,sz,Bmoon
;
; Follows Krisciunas and Schaefer PASP vol 103: pp.1033 (1991) in
; providing the brightness of a patch of sky given:
; lpa	- lunar phase angle (in degrees)
; rho 	- Moon/sky patch separation
; k	- extinction coefficient for the band considered
; mz	- Moon's zenith distance
; sz	- zenith distance of sky patch
;
k=0.172	; typical V band extinction at Mauna Loa
;
I_star = 10^(-0.4d0*(3.84d0+0.026d0*abs(lpa)+4.0e-9*lpa^4))
;
f_of_rho=10^5.36d0*(1.06d0+[cos(rho*!dtor)]^2)+10^(6.15d0-rho/40.d0)
;
x_of_z=(1.0d0-0.96d0*[sin(sz*!dtor)]^2)^(-0.5)
;
x_of_zm=(1.0d0-0.96d0*[sin(mz*!dtor)]^2)^(-0.5)
;
Bmoon=f_of_rho*I_star*10^(-0.4d0*k*x_of_zm)*(1.0d0-10^(-0.4d0*k*x_of_z))
;
;print,format='(4(g10.4,1x))',I_star,f_of_rho,x_of_z,Bmoon
return
end

common peterspecial,phi,inc
sky=fltarr(360,90)
jjd=julday(12,12,2010,23,0,0)
for jd=jjd,jjd+1.0,0.01 do begin
MOONPOS, jd, ra_moon, DECmoon, dis
distance=dis/6371.
obsname='mlo'
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
mphase,jd, k
lpa=phi/!dtor
; ... get the Moons position
; loop over sky positions and lpa
for Iazimuth=0,359,1 do begin
for Ialtitude=0,89,1 do begin
rho=findGDdistance(alt_moon, az_moon,Ialtitude,Iazimuth)
mz=90.-alt_moon
sz=90.-Ialtitude
moon_sky_brightness,lpa,rho,mz,sz,Bmoon
sky(Iazimuth,Ialtitude)=Bmoon
if (rho lt 10.0) then sky(Iazimuth,Ialtitude)=0.0
endfor
endfor
contour,sky,/cell_fill,nlevels=101,xtitle='Azimuth',ytitle='Altitude',xstyle=1,ystyle=1
contour,sky,/overplot,nlevels=7,/downhill
endfor
end
