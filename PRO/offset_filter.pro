 f='res3.2month'
 f='res3.1month'
 f='res3'
 data=get_data(f)
 jd=reform(data(0,*))		; Julian Day
 diameter=reform(data(1,*))	; Moon diameter in arcseconds
 PA=reform(data(2,*))		; Position Angle (CCW from Celestial North) of middle of BS
 dist=reform(data(3,*))		; 'distance' to sub-solar-point (neg is sun behind Moon)
 illumpct=reform(data(4,*))	; Illumination fraction in percent
 n=n_elements(dist)
 ;
 R=diameter/2.
 arg=abs(dist)/R
 alfa=acos(arg)/!dtor	; in degrees
 e=R*cos((90.+alfa)*!dtor)
 beta=90.-alfa			; in degrees
 ;
 offset=dist*0.0+911.0
 filter_angle=dist*0.0+911.
 ; select for all PA>180 & d < 0
 idx=where(PA gt 180 and dist lt 0)
 offset(idx)=R(idx)/2.	; offset in asec East is Positive


 ; select for all PA>180 & d > 0
 idx=where(PA gt 180 and dist gt 0)
 offset(idx)=-(R(idx)*cos((90+alfa(idx)+beta(idx)/2.)*!dtor))	; offset in degrees	East is Positive


 ; select for all PA<180 & d > 0
 idx=where(PA lt 180 and dist gt 0)
 offset(idx)=R(idx)*cos((90+alfa(idx)+beta(idx)/2.)*!dtor)	; offset in degrees	East is Positive


 ; select for all PA<180 & d < 0
 idx=where(PA lt 180 and dist lt 0)
 offset(idx)=-R(idx)/2.0	; offset in asec East is Positive
 offset=offset/3600.0	; offset in degrees now

 ; set filter angle
 filter_angle=PA-90.0
;
 openw,12,'p.dat'
 openw,14,'filter_orientations.dat'
 fmt='(f12.3,1x,5(f9.4,1x))'
 fmt2='(f12.3,1x,2(f9.4,1x))'
 for i=0,n-1,1 do begin
     print,format=fmt,jd(i),diameter(i),PA(i),dist(i),offset(i),filter_angle(i)
     printf,12,format=fmt,jd(i),diameter(i),PA(i),dist(i),offset(i),filter_angle(i)
     printf,14,format=fmt2,jd(i),offset(i),filter_angle(i)
     endfor
 close,12
 close,14
data=get_data('p.dat')
 jd=reform(data(0,*))		; Julian Day
 diameter=reform(data(1,*))	; Moon diameter in arcseconds
 PA=reform(data(2,*))		; Position Angle (CCW from Celestial North) of middle of BS
 dist=reform(data(3,*))		; 'distance' to sub-solar-point (neg is sun behind Moon)
 offset=reform(data(4,*))	; offset from disc centre
 filter_angle=reform(data(5,*))	; offset from disc centre
 n=n_elements(dist)
 !P.MULTI=[0,1,4]
 !P.CHARSIZE=2
; select just the situations that are good to observe
 kdx=where(illumpct gt 25 and illumpct lt 75)
 plot,psym=-7,jd(kdx),PA(kdx),xtitle='Julian Day',ytitle='SS Position Angle (CCW)',xstyle=1
oplot,[!X.CRANGE],[180,180]
 plot,psym=-7,jd(kdx),dist(kdx),xtitle='Julian Day',ytitle='SS distance',xstyle=1
oplot,[!X.CRANGE],[0,0]
 plot,psym=-7,JD(kdx),offset(kdx),xtitle='Julian Day',Ytitle='Filter Offset from disc centre',xstyle=1
oplot,[!X.CRANGE],[0,0]
 plot,psym=-7,JD(kdx),filter_angle(kdx),xtitle='Julian Day',Ytitle='Filter Angle wrt North',xstyle=1
oplot,[!X.CRANGE],[0,0]
; select just the situations that are good to observe
 kdx=where(illumpct gt 0)
 plot,psym=-7,jd(kdx),PA(kdx),xtitle='Julian Day',ytitle='SS Position Angle (CCW)',xstyle=1
oplot,[!X.CRANGE],[180,180]
 plot,psym=-7,jd(kdx),dist(kdx),xtitle='Julian Day',ytitle='SS distance',xstyle=1
oplot,[!X.CRANGE],[0,0]
 plot,psym=-7,JD(kdx),offset(kdx),xtitle='Julian Day',Ytitle='Filter Offset from disc centre',xstyle=1
oplot,[!X.CRANGE],[0,0]
 plot,psym=-7,JD(kdx),filter_angle(kdx),xtitle='Julian Day',Ytitle='Filter Angle wrt North',xstyle=1
oplot,[!X.CRANGE],[0,0]
 end
