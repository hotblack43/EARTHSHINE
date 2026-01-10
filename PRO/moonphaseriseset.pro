PRO MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun
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
obsname='lapalma'
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

PRO get_moon_rise_set,jd,jd_rise,jd_set
MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun
moon_sign=alt_moon/abs(alt_moon)
moon_lim=0.0
step=1./24./12.	; step is 5 minutes
;--------------------------------------------------------------------------------
altitude=911
time=911
for ijd=jd-0.6,jd+0.6,step do begin
	MOONPHASE,ijd,phase_angle_M,alt_moon,alt_sun
	altitude=[altitude,alt_moon]
	time=[time,ijd]
endfor
idx=where(altitude ne 911)
altitude=altitude(idx)
time=time(idx)
sign=deriv(altitude)/abs(deriv(altitude))
plot,time,sign,yrange=[-1.1,1.1]
oplot,[jd,jd],[!Y.crange]

for i=1,n_elements(altitude)-2,1 do begin
	if (sign(i-1) gt 0 and sign(i+1) lt 0) then jd_set=time(i)
	if (sign(i-1) lt 0 and sign(i+1) gt 0) then jd_rise=time(i)
endfor
return
end

old_set=911.0d0
old_rise=911.0d0
fmt='(3(1x,a,i2,1x,i2,1x,i4,1x,i2,1x,i2,1x,f7.4),1x,a,1x,f7.4)'
for JD=double(julday(03,1,2011,0,0,0)),double(julday(3,1,2021,0,0)),4./24. do begin
get_moon_rise_set,jd,jd_rise,jd_set
if (abs(jd_rise - old_rise) gt 1e-4) then begin
	;print,format='(3(a,1x,f13.4))','Time:',jd,' Moon-rise:',jd_rise,' Moon-set:',jd_set
	caldat,jd,a,b,c,d,e,f
	caldat,jd_rise,a1,a2,a3,a4,a5,a6
	caldat,jd_set,b1,b2,b3,b4,b5,b6
	print,format=fmt,'Time: ',a,b,c,d,e,f,' Rise: ',a1,a2,a3,a4,a5,a6,'Set: ',b1,b2,b3,b4,b5,b6,' D: ',jd_set-jd_rise
	old_rise=jd_rise
endif
endfor
end
