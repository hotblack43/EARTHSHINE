PRO get_stuff,JD,if_variable_distances,phase_angle_M,illum_frac
;------------------------------------------------------------------------
; Moon's and Sun's equatorial coordinates
; Earth-Moon distance
; Sun-Earth distance
; phase angles (elongations)
; Moon's illumination
;------------------------------------------------------------------------
DRADEG = 180.0D/!DPI
JD = double(JD)
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]
if (JD GT 0.0d) then begin
  moonpos, JD, RAmoon, DECmoon, Dem
  sunpos, JD, RAsun, DECsun
  xyz, JD-2400000.0, Xs, Ys, Zs, equinox=2000
  if (if_variable_distances EQ 1) then begin
    Dse = sqrt(Xs^2 + Ys^2 + Zs^2)*AU
    Dem = Dem
  endif else begin
    Dse = AU
    Dem = 384400.0d
  endelse
endif else begin
  RAmoon  = double(phase_angle)
  DECmoon = 0.0d
  RAsun   = 0.0d
  DECsun  = 0.0d
endelse
RAdiff = RAmoon - RAsun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
illum_frac = (1 + cos(phase_angle_M/DRADEG))/2.0
end
ntry=5000L
obsname='MSO'
obsname='holi'
obsname='saao'
obsname='keck'
obsname='lapalma'
mm=1
dd=1
yy=2008
hour=1
min=1
sec=0
date=[yy,mm,dd,hour,min,sec]
JULDATE, date, jdstart
jdstart=jdstart+2400000.d0
jdstop=jdstart+5L*365.
plot,[0,1],[0,180],/nodata,ytitle='Moon-Sun separation [deg]',xtitle='Illuminated fraction',charsize=2,xstyle=1,ystyle=1
fmt='(f20.7,6(1x,f10.3))'
openw,12,'accumulated_data.txt'
for jd=jdstart,jdstop,1./24. do begin
; where is the Moon in the sky=
MOONPOS, jd, ra_moon, dec_moon, dis
eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
; Where is the Sun in the local sky?
	SUNPOS, jd, ra_sun, dec_sun
	eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  OBSNAME=obsname
; what is the Moon phase?
if_variable_distances=1
get_stuff,JD,if_variable_distances,phase_angle_M,k
; what is the angular distance between Moon and SUn?
u=0	; radians
gcirc,u,ra_moon*!dtor, dec_moon*!dtor,ra_sun*!dtor, dec_sun*!dtor,dis
dis=dis/!pi*180.
printf,12,format=fmt,jd,alt_moon,alt_sun,dis,k,phase_angle_M
;print,format=fmt,jd,alt_moon,alt_sun,dis,k,phase_angle_M
plots,k,dis,psym=3
endfor
close,12
end

