PRO MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
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

RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]
fmt='(3(1x,a,i2,1x,i2,1x,i4,1x,i2,1x,i2,1x,f7.4),1x,a,1x,f7.4)'
	fmt2='(2(1x,i2),1x,i4,3(1x,i2),2(1x,f8.3))'
openw,12,'moon.dat'
obsname='dmi'
for JD=double(julday(12,1,2012,0,0,0)),double(julday(12,31,2012,0,0)),1./24./6. do begin
MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
MOONPOS, jd, ra1, dec1, dis, /RADIAN
SUNPOS, jd, ra2, dec2, /RADIAN
great_circle_distance= sphdist(ra1,dec1,ra2,dec2)
;print,great_circle_distance
great_circle_distance= great_circle_distance/!pi*180.
if (alt_sun lt 0 and alt_moon gt 0 and abs(great_circle_distance-22) lt 4) then begin
		caldat,jd,mm,dd,yy,hh,min,sec
		print,format=fmt2,mm,dd,yy,hh,min,sec,alt_moon, great_circle_distance
	    printf,12,great_circle_distance,phase_angle_M,jd,alt_moon
endif
endfor
close,12
data=get_data('moon.dat')
x=reform(data(0,*))
y=reform(data(1,*))
t=reform(data(2,*))-julday(1,1,2008)
alt=reform(data(3,*))
;plot,x,y,xtitle='Angular sep.',ytitle='Moon phase',charsize=2,psym=7
!P.MULTI=[0,1,2]
plot,t,x,xtitle='Days since Jan 1 2008 12 noon',ytitle='Angular separation',charsize=2,psym=7,title='Moon up, Sun down',yrange=[20,24]
plot,x,alt,xtitle='Angular separation',ytitle='Altitude of Moon',title=obsname+" After sundown",charsize=2,psym=7
end
