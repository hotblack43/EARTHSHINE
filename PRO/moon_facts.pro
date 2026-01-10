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

PRO decideifobserve,alt_moon,alt_sun,phase_angle_M,Moonatleast_alt,sun_lessthan_alt,flag
;
flag=314
if (alt_moon gt Moonatleast_alt and alt_sun le sun_lessthan_alt) then flag=1
return
end


;==================== MAIN ================================
for Moonatleast_alt=25,45,10 do begin
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
obsname='MSO'
obsname='lapalma'
openw,33,'data.dat'
;plot,[-30,30],[-185,185],/nodata,xtitle='Lunar declination',ytitle='Lunar phase angle',charsize=2
for JD=1.0d0*julday(1,1,2008),1.0d0*julday(1,1,2010),1./24. do begin
moonpos, JD, RAmoon, DECmoon, Dem
sunpos, JD, RAsun, DECsun
if_variable_distances=0
get_stuff,JD,if_variable_distances,phase_angle_M,k
eq2hor, RAmoon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
eq2hor, RAsun, DECsun, jd, alt_sun, az_sun, ha_sun,  OBSNAME=obsname
sun_lessthan_alt=-5
decideifobserve,alt_moon,alt_sun,phase_angle_M,Moonatleast_alt,sun_lessthan_alt,flag
;print,jd,phase_angle_M
if (flag ne 314) then begin
	;plots,[DECmoon,DECmoon],[phase_angle_M,phase_angle_M],psym=3
	printf,33,DECmoon,phase_angle_M
endif
endfor
close,33
data=get_data('data.dat')
dec=reform(data(0,*))
pha=reform(data(1,*))
minx=-30
maxx=30
miny=-180
maxy=180
binx=1.
biny=5.
Result = HIST_2D(dec,pha, BIN1=binx, BIN2=biny, MAX1=maxx, MAX2=maxy , MIN1=minx, MIN2=miny ) 
nx=(maxx-minx)/binx+1
ny=(maxy-miny)/biny+1
x=findgen(nx)*binx+minx
y=findgen(ny)*biny+miny
;contour,result,x,y,/cell_fill,nlevels=101,xtitle='Lunar declination',ytitle='Lunar phase angle',charsize=2,title='Probability (contour=50 pct)'
; get some nice contours
maxres=max(result)
fraction=fltarr(maxres)
for k=0,maxres-1,1 do begin
	idx=where(result ge k)
	fraction(k)=total(result(idx))/total(result)
endfor
idx=where(fraction le 0.5)
;contour,result,x,y,/overplot,levels=[idx(0)],c_thick=1.2
; plothisto for moon phase angle
p=29.5305882
histo,pha,-180,180,5,xtitle='Lunar phase angle',title='Lunar phase when observable from '+obsname
h=histogram(pha/360.*p-p/2.,min=-30,max=30,binsize=1)
x=indgen(61)-30
plot,abs(x),h,psym=10,xrange=[0,30],xtitle='Days since last New Moon',charsize=1.2,title='Alt gt:'+string(Moonatleast_alt)+' Moon observable from '+obsname,ytitle='Frequency'               
endfor	; end of loop over minimum moon altitudes
end


