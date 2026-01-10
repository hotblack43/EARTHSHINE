;==============================================================================
; Code to model the Dome-Azimuth vs. telescope Altitude-and-azimuth relationship
;-------------------------------------------------------------------------------
; Describe dome and telescope layout
radius=10*12*2.54*10./2.; radius of dome (10' diameter dome)
lat=19.5	; latitude of telescope
; 'origi' is the intersection of the polar axis and the RA axis.
l1=410.0	; distance from origo to A - A is the intersection between 
;         the optical axis and the RA axis.
l3=200.0	; distance from A to B - B is the lens.
displacement=[0,-1071-118,0]	; (E, N, up/down) position of origo from center of Dome
;displacement=[94,1071,0]	; (E, N, up/down) position of origo from center of Dome
; scale the dimensions a bit
factor=20.0
l1=l1/factor
l3=l3/factor
radius=radius/factor
displacement=displacement/factor
;==============================================================================
x00=displacement(0)
y00=displacement(1)
z00=displacement(2)
openw,34,'solution.dat'
printf,34,'      HA           ALT          AZ           DAZ'
openw,33,'solution_noheader.dat'
for ha=-90*2.,90*2.,3 do begin
    for beta=-180,180,3 do begin
        alfa=90.-ha
        ; transformed coordinats of A and B
        xA=x00+l1*cos(alfa*!dtor)
        yA=y00-l1*sin(alfa*!dtor)*sin(lat*!dtor)
        zA=z00+l1*sin(alfa*!dtor)*cos(lat*!dtor)
; now image small disc stuck to end of RA axis: 90-beta is the altitudeo
; localx points North, localy updwards
	localx=l3*sin(beta*!dtor)
	localy=l3*cos(beta*!dtor)
        xB=xa+localy*sin(alfa*!dtor)
        yB=ya+localx
        zB=zA+localy*cos(alfa*!dtor)
	if (zB gt zA) then begin
        ; find equation of line through A and B
        dir_vector=[xb-xa,yb-ya,zb-za]
        dir_vector=dir_vector/sqrt(dir_vector(0)^2+dir_vector(1)^2+dir_vector(2)^2)
	if (dir_vector(2) lt 0) then begin
print,ha,alfa,beta
stop
endif
	; give a point on the line
        x0=xb
        y0=yb
        z0=zb
        dist_old=-10000
        for t=0.,radius*2.,.2 do begin
            x=x0+dir_vector(0)*t
            y=y0+dir_vector(1)*t
            z=z0+dir_vector(2)*t
            dist=sqrt(x^2+y^2+z^2)
            alt=atan((zb-za)/sqrt((xA-xb)^2+(ya-yb)^2))/!dtor
            if (dist ge radius and dist_old lt radius and alt ge 0) then begin
	        get_dome_az,x,y,dome_az
	        get_az,xa,xb,ya,yb,az
                printf,33,ha,alt,az,dome_az
                printf,34,ha,alt,az,dome_az
                dist_old=dist
                endif
            endfor
	endif
        endfor
    endfor
close,33
close,34
;
!P.MULTI=[0,2,2]
for hasign=1,-1,-2 do begin
if (hasign eq -1) then str='East of pier'
if (hasign eq +1) then str='West of pier'
data=get_data('solution_noheader.dat')
ha=reform(data(0,*))
alt=reform(data(1,*))
az=reform(data(2,*))
daz=reform(data(3,*))
jdx=where(sign(ha) eq hasign)
ha=ha(jdx)
alt=alt(jdx)
az=az(jdx)
daz=daz(jdx)
plot,az,daz,psym=3,xtitle='Telescope Azimuth',ytitle='Dome azimuth',/isotropic,xstyle=3,ystyle=3,title=str
if (hasign eq -1) then oplot,az,daz,color=fsc_color('red'),psym=3
if (hasign eq +1) then oplot,az,daz,color=fsc_color('blue'),psym=3
oplot,[180,180],[!Y.crange],linestyle=2
;
kdx=where(finite(az) eq 1)
levs=findgen(37)*10
!P.THICK=2
contour,daz(kdx),alt(kdx),az(kdx),/irregular,xtitle='Altitude',ytitle='Telescope Azimuth',title='Dome azimuth for '+str+' HA',levels=levs,/downhill,xstyle=1,ystyle=1,yrange=[80,270],c_labels=findgen(190)*0+1
plots,[!x.crange],[180,180],linestyle=2
; grid the data
;xout=findgen(10)*10
;yout=findgen(21)*10+80
;Result = GRIDDATA( alt(kdx),  az(kdx),  daz(kdx), /grid, xout=xout, yout=yout ) 
;surface,result,xout,yout,zrange=[80,280],zstyle=1,xtitle='Telescope Alt',ytitle='Telescope Az'
endfor
xyouts,/normal,0.1,0.95,'l!d1!n='+string(l1)
xyouts,/normal,0.1,0.93,'l!d3!n='+string(l3)
xyouts,/normal,0.1,0.91,'x0='+string(x00)+' E'
xyouts,/normal,0.1,0.89,'y0='+string(y00)+' N'
xyouts,/normal,0.1,0.87,'z0='+string(z00)+' z'
end

