PRO contplot_sky,sky,x,y,xtit,ytit,tit
contour,sky,/cell_fill,nlevels=101,xtitle=xtit,ytitle=ytit,xstyle=1,ystyle=1,title=tit
contour,sky,/overplot,nlevels=7,/downhill
; also find darkest spot
id=min(sky,loc)
idx=array_indices(sky,loc) 
plots,[idx(0),idx(0)],[idx(1),idx(1)],psym=7
print,'B :',sky(idx(0),idx(1))
return
end

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


common peterspecial,phi,inc
aziarr=findgen(360)
altarr=findgen(90)
sky=fltarr(360,90)
sky_m=fltarr(360,90)
sky_s=fltarr(360,90)
jjd=julday(12,12,2010,23,0,0)
for jd=jjd,jjd+30.,0.1 do begin
; ... get the Moons position
MOONPOS, jd, ra_moon, DECmoon, dis
distance=dis/6371.
obsname='mlo'
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
mphase,jd, k
lpa=phi/!dtor
; ... get the Suns position
SUNPOS, jd, ra_sun, DEsun
eq2hor, ra_sun, DEsun, jd, alt_sun, az_sun, ha_sun,  OBSNAME=obsname
; only near twilight
if (abs(alt_sun lt 20)) then begin
; loop over sky positions and lpa
for Iazimuth=0,359,1 do begin
for Ialtitude=0,89,1 do begin
rho_m=findGDdistance(alt_moon, az_moon,Ialtitude,Iazimuth)
rho_s=findGDdistance(alt_sun, az_sun,Ialtitude,Iazimuth)
mz=90.-alt_moon
msun=90.-alt_sun
sz=90.-Ialtitude
moon_sky_brightness,lpa,rho_m,mz,sz,Bmoon
sun_sky_brightness,rho_s,msun,sz,Bsun
sky_m(Iazimuth,Ialtitude)=Bmoon
sky_s(Iazimuth,Ialtitude)=Bsun
sky(Iazimuth,Ialtitude)=Bmoon+Bsun
endfor
endfor
str=strcompress(' S:'+string(alt_sun)+' M:'+string(alt_moon)+' Ph:'+string(lpa))
!P.MULTI=[0,1,3]
!P.charsize=2
contplot_sky,sky,aziarr,altarr,'Azimuth','Altitude','Sun and Moon'+str
contplot_sky,sky_s,aziarr,altarr,'Azimuth','Altitude','Sun only '
contplot_sky,sky_m,aziarr,altarr,'Azimuth','Altitude','Moon only '
endif
endfor
end
