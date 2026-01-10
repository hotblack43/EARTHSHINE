PRO zenith_luminance,solar_altitude,turbidity,zenith_luminance
; SSLD V.4. "A set of standard skies" R. Kittler and S. Darula
a1=1.036
a2=0.71
a=a1*turbidity+a2
b=23.0
c=4.43
d=0.74
e=18.52
;print,a1,a2,a,b,c,d,e
;
zenith_luminance=a*sin(solar_altitude*!dtor)+0.7*(turbidity+1.0)*(sin(solar_altitude*!dtor))^c/(cos(solar_altitude*!dtor))^d+0.04*turbidity
;print,solar_altitude,turbidity,zenith_luminance
; the above is in kilo-candela per square meters.
; do unit conversion using 1 L = 3.1831 kcd/m^2
zenith_luminance=zenith_luminance/3.1831/1e-9	; nL
return
end

 
 FUNCTION findGDdistance,alt1,az1,alt2,az2
 ; finds the great circle distance in degrees between the two points
 ; all inputs are in degrees
 GC=great_circle(az1,alt1,az2,alt2)/6378388.d0/!pi/2.d0*360.0d0
 return,GC
 end
 
 FUNCTION CIE_clear_sky_standard,chi,Z,Zs,a,b,c,d,e
 ; calculates the CIE Clear SKy Standard Luminance
 ;
 CIE_clear_sky_standard=f(chi,c,d,e)*psi(Z,a,b)/f(Zs,c,d,e)/psi(0.0,a,b)
 return, CIE_clear_sky_standard
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
 I_star = 10^(-0.4d0*(-26.86+16.57))
 ;
 f_of_rho=10^5.36d0*(1.06d0+[cos(rho*!dtor)]^2)+10^(6.15d0-rho/40.d0)
 ;
 x_of_z=(1.0d0-0.96d0*[sin(sz*!dtor)]^2)^(-0.5)
 ;
 x_of_zm=(1.0d0-0.96d0*[sin(mz*!dtor)]^2)^(-0.5)
 ;
 Bsun=f_of_rho*I_star*10^(-0.4d0*k*x_of_zm)*(1.0d0-10^(-0.4d0*k*x_of_z))
 ;
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
; Type 14
     a=-1.0
     b=-0.15
     c=16.
     d=-3.0
     e=0.30
 element_azimuth=az
 element_zenith_dist=90.0 - alt
 sun_zenith_dist=90.-sun_alt 
 Azz=abs(sun_az-element_azimuth)
 chi=acos(cos(sun_zenith_dist*!dtor)*cos(element_zenith_dist*!dtor)+sin(sun_zenith_dist*!dtor)*sin(element_zenith_dist*!dtor)*cos(Azz*!dtor))/!dtor
 CIE_relative_to_zenith=CIE_clear_sky_standard(chi,element_zenith_dist,sun_zenith_dist,a,b,c,d,e)
 ;
;; Then get the KS value for zenith
;rho=findGDdistance(sun_alt,sun_az,90.0,element_azimuth)
;mz=sun_zenith_dist
;sz=0.0 ; element_zenith_dist
;KS_at_zenith = sun_sky_brightness(rho,mz,sz)
 ; other model for Zenith luminance from CIE:
 turbidity=2.5
 zenith_luminance,sun_alt,turbidity,KS_at_zenith
 abs_lum = CIE_relative_to_zenith * KS_at_zenith
 return
 end
 
 
 
 
 
 PRO contplot_sky,sky,x,y,xtit,ytit,tit
 iflog=1
	if (iflog ne 1) then begin
 contour,sky,/cell_fill,nlevels=101,xtitle=xtit,ytitle=ytit,xstyle=1,ystyle=1,title=tit
 contour,sky,/overplot,nlevels=7,/downhill
	endif
	if (iflog eq 1) then begin
 contour,alog(sky),/cell_fill,nlevels=101,xtitle=xtit,ytitle=ytit,xstyle=1,ystyle=1,title=tit
 contour,alog(sky),/overplot,nlevels=7,/downhill
	endif
 ; also find darkest spot
 id=min(sky,loc)
 idx=array_indices(sky,loc) 
 plots,[idx(0),idx(0)],[idx(1),idx(1)],psym=7
 print,'B :',sky(idx(0),idx(1)),max(sky),sky(idx(0),idx(1))/max(sky),idx(0),idx(1)
 return
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
 
 ;=============================================================== 
 ; Main code. Builds a model of the sky brightness allowing 
 ; for Moon and Sun
 ;=============================================================== 
 common peterspecial,phi,inc
 aziarr=findgen(360)
 altarr=findgen(90)
 sky=dblarr(360,90)
 sky_m=dblarr(360,90)
 sky_s=dblarr(360,90)
 jjd=julday(12,12,2010,23,0,0)
 for jd=jjd,jjd+30.,.25 do begin
     ; ... get the Moons position
     MOONPOS, jd, ra_moon, DECmoon, dis
     distance=dis/6371.
     obsname='mlo'
     eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
     mphase,jd, k
     ;lpa=phi/!dtor	; convention on lpa!
     lpa=inc/!dtor	; convention on lpa!
     ; ... get the Suns position
     SUNPOS, jd, ra_sun, DEsun
     eq2hor, ra_sun, DEsun, jd, alt_sun, az_sun, ha_sun,  OBSNAME=obsname
     ; only near twilight
     if (alt_sun  gt 0) then begin
         ; loop over sky positions and lpa
         for Iazimuth=0,359,1 do begin
             for Ialtitude=0,89,1 do begin
                 rho_m=findGDdistance(alt_moon, az_moon,Ialtitude,Iazimuth)
                 rho_s=findGDdistance(alt_sun, az_sun,Ialtitude,Iazimuth)
                 mz=90.-alt_moon
                 msun=90.-alt_sun
                 sz=90.-Ialtitude
                 ; get Moon from KS
                 moon_sky_brightness,lpa,rho_m,mz,sz,Bmoon
                 ; get Sun from KS and CIE combined
                 CIE_absolute_sky_luminace_Sun_only,Ialtitude,Iazimuth,msun,az_sun,Bsun
                 
                 sky_m(Iazimuth,Ialtitude)=Bmoon
                 sky_s(Iazimuth,Ialtitude)=Bsun
                 sky(Iazimuth,Ialtitude)=Bmoon+Bsun
                 endfor
             endfor
         str=strcompress(' S:'+string(alt_sun)+' M:'+string(alt_moon)+' Ph:'+string(lpa))
         !P.MULTI=[0,1,4]
         !P.charsize=2
         contplot_sky,sky,aziarr,altarr,'Azimuth','Altitude','Sun and Moon'+str
         contplot_sky,sky_s,aziarr,altarr,'Azimuth','Altitude','Sun only '
         contplot_sky,sky_m,aziarr,altarr,'Azimuth','Altitude','Moon only '
         contplot_sky,sky-sky_s,aziarr,altarr,'Azimuth','Altitude','Sun+Moon - Sun'
         endif
     endfor
 end
