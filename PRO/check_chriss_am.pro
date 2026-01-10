PRO MOONPHASE,jd,phase_angle_E,alt_moon,alt_sun,obsname
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
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
		SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
return
end

PRO get_mlo_airmass,jd,am
;
; Calculates the airmass of the observed Moon as seen from MLO
;
; INPUT:
;   jd  -   julian day
; OUTPUT:
;   am  -   the required airmass
;
    lat=19.53d0
    lon=155.576
    MOONPOS,jd,ra,dec
    eq2hor,ra,dec,jd,alt,az,lon=lon,lat=lat
    ra=degrad(ra)
    dec=degrad(dec)
    lat=degrad(lat)
    lon=degrad(lon)
    am = airmass(jd,ra,dec,lat,lon)
    return
end


;--------------------------------------------
; code to check on the airmass and phases Chris gets
;--------------------------------------------
openw,33,'stuff.dat'
data=get_data('cflynn_JD_phase_am.dat')
cflynn_jd=reform(data(0,*))
cflynn_phase=reform(data(1,*))
cflynn_am=reform(data(2,*))
obsname='mlo'
for i=0,n_elements(cflynn_jd)-1,1 do begin
jdin=cflynn_jd(i)
MOONPHASE,jdin,phase_angle_E,alt_moon,alt_sun,obsname
get_mlo_airmass,jdin,am
printf,33,format='(f15.7,4(1x,f9.4))',cflynn_jd(i),cflynn_phase(i),cflynn_am(i),phase_angle_E,am
print,format='(f15.7,4(1x,f9.4))',cflynn_jd(i),cflynn_phase(i),cflynn_am(i),phase_angle_E,am
endfor
close,33
;
data=get_data('stuff.dat')
jd=reform(data(0,*))
cf_phase=reform(data(1,*))
cf_am=reform(data(2,*))
pth_phase=reform(data(3,*))
pth_am=reform(data(4,*))
;
!P.charsize=1.7
!P.MULTI=[0,1,2]
plot,/isotropic,cf_phase,pth_phase,psym=7,xtitle='Chris phase',ytitle='Peter phase'
plot,/isotropic,cf_am,pth_am,psym=7,xtitle='Chris airmass',ytitle='Peter airmass'
plots,[0,12],[0,12],linestyle=2
end

