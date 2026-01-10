PRO get_az,adjacent,opposite,az
if (adjacent ge 0) then signx=+1
if (adjacent lt 0) then signx=-1
if (opposite ge 0) then signy=+1
if (opposite lt 0) then signy=-1
arg=abs(opposite/adjacent)
if (signx eq +1 and signy eq +1) then az=90.-atan(arg)/!dtor
if (signx eq +1 and signy eq -1) then az=90.+atan(arg)/!dtor
if (signx eq -1 and signy eq -1) then az=270.-atan(arg)/!dtor
if (signx eq -1 and signy eq +1) then az=270.+atan(arg)/!dtor
return
end

PRO get_vector_pointing,beta,dir_vector,vector_alt,vector_azi
dx=dir_vector(0)
dy=dir_vector(1)
dz=dir_vector(2)
if (dz lt 0) then stop
vector_alt=atan(dz,sqrt(dx^2+dy^2))/!dtor
;get_az,sqrt(dx^2+dy^2),dz,vector_alt
if (vector_alt lt 0) then stop
while (vector_alt gt 90) do begin
vector_alt=vector_alt-90.
endwhile
get_az,dx,dy,vector_azi
return
end

 function sign, x
 compile_opt idl2
 on_error, 2
 if x gt 0 then return, 1
 if x lt 0 then return, -1
 return, 0
 end
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
 ;displacement=-displacement	; (E, N, up/down) position of origo from center of Dome
 ; scale the dimensions a bit
 factor=20.0;*15.24	; makes dimensions feet after scaling
 l1=l1/factor
 l3=l3/factor
 radius=radius/factor
 displacement=displacement/factor
 ; describe the orientation convention:
 imode=1	; telescope may be on one side of pier and observe same hemisphere
		; i.e. telescope can be on East side and observe East hemi.
 imode=2	; telescope may only ever observe in hemisphere opposite - i.e. same as direction it points
		; West-West or East-East
 imode=2
 if (imode eq 1) then signconvention=1
 if (imode eq 2) then signconvention=-1
 ;==============================================================================
 x00=displacement(0)
 y00=displacement(1)
 z00=displacement(2)
 openw,55,'vector_alt_az.dat'
 openw,34,'solution.dat'
 printf,34,'      sXB           ALT          AZ           DAZ'
 openw,33,'solution_noheader.dat'
 for ha=90.,-90.,-2. do begin	; angle between vertical and RA axis
     for beta=0.,360.,2. do begin	; angle between optical axis and horisontal, 0=North, 90=up,180=South
         alfa=90.-ha		; angle between horisontal and RA axis 
         ; transformed coordinats of A and B
         xA=x00+l1*cos(alfa*!dtor)
         yA=y00-l1*sin(alfa*!dtor)*sin(lat*!dtor)
         zA=z00+l1*sin(alfa*!dtor)*cos(lat*!dtor)
         ; now imagine small disc stuck to end of RA axis
         ; localx points North, localy updwards
         localx=l3*cos(beta*!dtor)
         localy=l3*sin(beta*!dtor)
         xB=xa-localy*sin(alfa*!dtor)
         yB=ya+localx
         zB=za+localy*cos(alfa*!dtor)
         if (zB gt zA) then begin
             ; find equation of line through A and B
             dir_vector=[xb-xa,yb-ya,zb-za]
             dir_vector=dir_vector/sqrt(dir_vector(0)^2+dir_vector(1)^2+dir_vector(2)^2)
	     get_vector_pointing,beta,dir_vector,vector_alt,vector_azi
	printf,55,format='(3(1x,f9.2),1x,f6.2,1x,f6.2)',dir_vector,vector_alt,vector_azi
	if (vector_alt ge 0) then begin
             ; give a point on the line
             x0=xb
             y0=yb
             z0=zb
             dist_old=-10000
             for t=0.,radius*2.,.1 do begin
                 x=x0+dir_vector(0)*t
                 y=y0+dir_vector(1)*t
                 z=z0+dir_vector(2)*t
                 dist=sqrt(x^2+y^2+z^2)
                 ;alt=atan((zb-za)/sqrt((xA-xb)^2+(ya-yb)^2))/!dtor
                 if (dist ge radius and dist_old lt radius) then begin
                     get_dome_az,x,y,dome_az
			if (imode eq 1) then begin
                     printf,33,fix(xb/abs(xb)),vector_alt,vector_azi,dome_az
                     printf,34,fix(xb/abs(xb)),vector_alt,vector_azi,dome_az
			endif
			if (imode eq 2) then begin
                     printf,33,fix((xb-xa)/abs(xb-xa)),vector_alt,vector_azi,dome_az
                     printf,34,fix((xb-xa)/abs(xb-xa)),vector_alt,vector_azi,dome_az
			endif
                     dist_old=dist
                     endif
                 endfor
                     endif
             endif
         endfor
     endfor
 close,33
 close,34
 ;
 !P.MULTI=[0,1,2]
 for xbsign=1*signconvention,-1*signconvention,-2*signconvention do begin
     if (xbsign eq -1 and imode eq 1) then str='West of pier'
     if (xbsign eq +1 and imode eq 1) then str='East of pier'
     if (xbsign eq -1 and imode eq 2) then str='East of pier'
     if (xbsign eq +1 and imode eq 2) then str='West of pier'
     data=get_data('solution_noheader.dat')
     az=reform(data(2,*))
     kdx=where(finite(az) eq 1)
     data=data(*,kdx)
     xbsign_arr=reform(data(0,*))
     alt=reform(data(1,*))
     az=reform(data(2,*))
     daz=reform(data(3,*))
     ;
     jdx=where(xbsign_arr eq xbsign)
     xb=xb(jdx)
     alt=alt(jdx)
     az=az(jdx)
     daz=daz(jdx)
     kdx=where(finite(az) eq 1 and finite(alt) eq 1)
     levs=findgen(36*2+1)*5
     levs=findgen(36*1+1)*10
	;levs=[levs,findgen(44)*2+160]
	;levs=levs(sort(levs))
	;levs=levs(uniq(levs))
     !P.THICK=2
     contour,daz(kdx),alt(kdx),az(kdx),/irregular,xtitle='Altitude',ytitle='Telescope Azimuth',title='Dome azimuth for '+str,levels=levs,/downhill,xstyle=1,ystyle=1,c_labels=findgen(190)*0+1,yrange=[80,270];,xrange=[0,90]
     plots,[!x.crange],[180,180],linestyle=2
     endfor
 xyouts,/normal,-0.04,1.08,'l!d1!n='+string(l1)
 xyouts,/normal,-0.04,1.06,'l!d3!n='+string(l3)
 xyouts,/normal,-0.04,1.04,'x0='+string(x00)+' E'
 xyouts,/normal,-0.04,1.02,'y0='+string(y00)+' N'
 xyouts,/normal,-0.04,1.00,'z0='+string(z00)+' z'
 xyouts,/normal,-0.04,0.98,'Dome radius='+string(radius)
 close,55
 end
 
