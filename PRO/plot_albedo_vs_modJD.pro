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
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME='mlo';obsname
SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
return
end


PRO getphasefromJD,JD,phase
MOONPHASE,jd(0),phase_angle_M,alt_moon,alt_sun,obsname
phase=phase_angle_M
return
end















colorname=['red','blue','green','orange','yellow','cyan']
file='CLEM.profiles_fitted_results_SEPT_2013_cubes.txt'
filtername="_V_"
str="grep "+filtername+" "+file+" | awk '{print $1,$2}' > p.dat"
spawn,str
data=get_data('p.dat')
jd=reform(data(0,*))
idx=sort(jd)
data=data(*,idx)
jd=reform(data(0,*))
alb=reform(data(1,*))
!P.MULTI=[0,2,2]
longjd=long(jd)
uniqjd=longjd(uniq(longjd(sort(longjd))))
n=n_elements(uniqjd)
; gett he phase
phases=fltarr(n_elements(jd))
for k=0,n_elements(jd)-1,1 do begin
getphasefromJD,JD(k),phase
phases(k)=phase
endfor
;
plot,xstyle=3,yrange=[0.24,0.4],jd mod 1,xrange=[0.0,0.2],alb,psym=1,xtitle='JD mod 1',ytitle='V Albedo'
for i=0,n-1,1 do begin
jdx=where(long(jd) eq uniqjd(i))
oplot,psym=-7,jd(jdx) mod 1,alb(jdx),color=fsc_color(colorname(i mod 5))
endfor
plot,xstyle=3,yrange=[0.24,0.4],jd mod 1,xrange=[0.74,0.9],alb,psym=1,xtitle='JD mod 1',ytitle='V Albedo'
for i=0,n-1,1 do begin
jdx=where(long(jd) eq uniqjd(i))
oplot,psym=-7,jd(jdx) mod 1,alb(jdx),color=fsc_color(colorname(i mod n_elements(colorname)))
endfor
; plot against phase
idx=where(phases gt -150 and phases lt -50)
plot,yrange=[min(alb),max(alb)],ystyle=3,phases(idx),alb(idx),psym=7,xtitle='Lunar Phase angle',ytitle='V Albedo'
idx=where(phases gt 0 and phases lt 180)
plot,yrange=[min(alb),max(alb)],ystyle=3,phases(idx),alb(idx),psym=7,xtitle='Lunar Phase angle',ytitle='V Albedo'
end
