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

file='CLEM.profiles_fitted_ideal_to_convolved_ideal_Oct_10_2013.txt'
tstr='Model images vs model images'
;..............
file='CLEM.profiles_fitted_results_July_24_2013.txt'
tstr='old H63, Clem -> Wildey & SD adj.'
;...........
file='CLEM.profiles_fitted_results_Oct_2013_NEW_Hapke63.txt'
tstr='new H63, Clem unadjusted'
file='CLEM.profiles_fitted_results_SEPT_2013_cubes.txt'
tstr='old H63, Clem -> Wildey & SD adj.'
file='CLEM_Wildey_SDscaled.profiles_fitted_results_Oct_2013_NEW_Hapke63.txt'
tstr='new H63, Clem -> Wildey & SD adj.'
file='CLEM_Wildey_SDscaled.profiles_fitted_results_Oct_2013_H-X.txt'
tstr='H-X Clem -> Wild + SD scaled'
file='CLEM_notscaled.profiles_fitted_results_Oct_2013_H-X.txt'
tstr='H-X CLEM not scaled'
file='CLEM_notscaled.profiles_fitted_results_Oct_2013_newHapke63.txt'
tstr='new Hapke 63; Clem not scaled'
;.............................
str='cat '+file+" | grep _VE1| awk '{print $1,$2,$3,$4,$5,$6,$7}' > p.dat"
spawn,str
data=get_data('p.dat')
jd=reform(data(0,*))
albedo=reform(data(1,*))
n=n_elements(jd)
ph=fltarr(n)
;
obsname='mlo'
for i=0,n-1,1 do begin
MOONPHASE,jd(i),phase_angle_M,alt_moon,alt_sun,obsname
ph(i)=phase_angle_M
print,jd(i),ph(i),albedo(i)
endfor
!P.MULTI=[0,2,2]
plot,ph,albedo,psym=7,xtitle='Lunar phase angle',ytitle='Albedo',title=tstr,xrange=[-130,-70],xstyle=3,yrange=[0.2,0.47],ystyle=3
plot,ph,albedo,psym=7,xtitle='Lunar phase angle',ytitle='Albedo',title=tstr,xrange=[90,150],xstyle=3,yrange=[0.2,0.47],ystyle=3
!P.MULTI=[1,1,2]
plot,ph,albedo,psym=7,xtitle='Lunar phase angle',ytitle='Albedo',title=tstr,xrange=[-180,180],xstyle=3,ystyle=3,yrange=[0.,1.]
end
