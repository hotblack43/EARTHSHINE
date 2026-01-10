PRO get_daz,dx,dy,daz
arg=abs(dx/dy)
if (dx ge 0 and dy ge 0) then daz=90.-atan(arg)/!dtor
if (dx ge 0 and dy lt 0) then daz=90.+atan(arg)/!dtor
if (dx lt 0 and dy lt 0) then daz=270.-atan(arg)/!dtor
if (dx lt 0 and dy ge 0) then daz=270.+atan(arg)/!dtor
return
end

; Follows note found at http://www.dppobservatory.net/DomeAutomation/dome_synchronisation.pdf
;
!P.CHARSIZE=2
!P.thick=2
; givens:
lati=19.5	; site latitude in degrees
r=410.	; distance from cg to optical axis
BigR=10.*12.*25.4/2.	; Dome radius
;
x=0.		; East coordinate of cg
y=-1071.-118.	; North coordinate of cg
y=0.
z=0.		; up coordinate of cg
;---------------------------------
openw,33,'domeAzi.dat'
for alt=0.,89.,1. do begin
for az=0.,359.,1. do begin
; given alt,az,lat get ha and declin
ALTAZ2HADEC, alt, az, lati, ha, declin
e=alt	; telescope altitude in degrees
;---------------------------------
az_test=acos(cos(declin*!dtor)*sin(ha*!dtor)/sin((90.-e)*!dtor))/!dtor	; telescope azimuth
xprime=x+r*sin(ha*!dtor)
yprime=y-r*sin(lati*!dtor)*cos(ha*!dtor)
zprime=z+r*cos(lati*!dtor)*cos(ha*!dtor)
lprimesq=(xprime^2+yprime^2+zprime^2)
m=lprimesq-BigR^2
l=xprime*cos(e*!dtor)*sin(az*!dtor)-yprime*cos(e*!dtor)*cos(az*!dtor)+zprime*sin(e*!dtor)
d=sqrt(L*L-M)-L
dprime=d*cos(e*!dtor)
dx=dprime*sin(az*!dtor)+xprime
dy=dprime*cos(az*!dtor)-yprime
dz=d*sin(e*!dtor)+zprime
get_daz,dx,dy,daz
printf,33,ha,alt,az,daz
endfor
endfor
close,33
data=get_data('domeAzi.dat')
az=reform(data(2,*))
idx=where(finite(az) eq 1)
data=data(*,idx)
az=reform(data(2,*))
ha=reform(data(0,*))
alt=reform(data(1,*))
az=reform(data(2,*))
daz=reform(data(3,*))
;
!P.MULTI=[0,1,2]
kdx=where(ha gt 0 and ha le 180)	; condition for West
if (kdx(0) ne -1) then contour,/downhill,/irregular,daz(kdx),alt(kdx),az(kdx),title='West of pier',xtitle='Telescope altitude',ytitle='Telescope Azimuth',xstyle=1,yrange=[90,270],c_labels=findgen(200)*0+1,levels=findgen(37)*10;,/isotropic
kdx=where(ha gt 180 and ha le 360)	; condition for East
if (kdx(0) ne -1) then contour,/downhill,/irregular,daz(kdx),alt(kdx),az(kdx),title='East of pier',xtitle='Telescope altitude',ytitle='Telescope Azimuth',xstyle=1,yrange=[90,270],c_labels=findgen(200)*0+1,levels=findgen(37)*10;,/isotropic
end
