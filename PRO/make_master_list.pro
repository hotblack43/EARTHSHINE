PRO when_observe_moon,jd_in,starting,stopping
 common obs,obsname
 horison_alt=0.0
 aha=long(jd_in)
     icount=0
	list=!VALUES.F_NaN
        starting=0
        stopping=0
 for jd=double(aha)+0.5,double(aha)+1.5,1./24./12.d0 do begin
     sunpos, JD, RAsun, DECsun
     eq2hor, raSUN, decSUN, jd, alt_SUN, az, ha,  OBSNAME=obsname
     if (alt_SUN lt horison_alt) then begin
         moonpos, JD, RAmoon, DECmoon
         eq2hor, ramoon, decmoon, jd, alt_moon, az, ha,  OBSNAME=obsname
         observatory,obsname,obs_struct
         ;        print,obs_struct.longitude,obs_struct.latitude
         am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, obs_struct.latitude*!dtor, obs_struct.longitude*!dtor)
         if (am le 2.0) then begin
             if (icount eq 0) then list=jd
             if (icount gt 0) then list=[list,jd]
;            print,format='(f11.3,3(1x,f9.3))',jd,ramoon,decmoon,am
             icount=icount+1
             icount=icount+1
             endif
         endif
     endfor
	if (finite(product(list)) eq 1) then begin
        starting=min(list)
        stopping=max(list)
	endif
 return
 end


;===============================================================================
; Code to 
;===============================================================================
 common obs,obsname
 obsname='lapalma'
; read the HORIZON datafile set up using sendit.xxxxx
 f='res3.2month'
 f='res3'
 f='res3.1month'
 data=get_data(f)
;
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
 e=R*cos((90.-alfa)*!dtor)	; distance to terminator
 beta=90.-alfa			; in degrees
 ; set filter angle
 filter_angle=(PA+90) 
 ;
 offset=fltarr(n)	; offset: shift to East is positive
 ;--------------------------------------------------------------------------
 ; select for all PA>180 & d < 0	- RHS bright less than half
 idx=where(PA gt 180 and dist lt 0)
 offset(idx)=R(idx)/2.	; offset in asec East is Positive
 ;--------------------------------------------------------------------------
 ; select for all PA>180 & d > 0	- RHS bright more than half
 idx=where(PA gt 180 and dist gt 0)
 offset(idx)=(R(idx)*cos((90+alfa(idx)+beta(idx)/2.)*!dtor))	; offset in degrees	East is Positive
 ;--------------------------------------------------------------------------
 ; select for all PA<180 & d < 0	- LHS bright less than half
 idx=where(PA lt 180 and dist lt 0)
 offset(idx)=-R(idx)/2.0	; offset in asec East is Positive
 ;--------------------------------------------------------------------------
 ; select for all PA<180 & d > 0	- LHS bright more than half
 idx=where(PA lt 180 and dist gt 0)
 offset(idx)=-R(idx)*cos((90+alfa(idx)+beta(idx)/2.)*!dtor)	; offset in degrees	East is Positive
 ;--------------------------------------------------------------------------
;
 offset=offset/3600.0	; offset in degrees now
;
 openw,12,'p.dat'
 openw,14,'filter_orientations.dat'
 fmt='(f12.3,1x,5(f9.4,1x),2(1x,f11.3))'
 fmt2='(f12.3,1x,2(f9.4,1x),2(1x,f11.3))'
 for i=0,n-1,1 do begin
     when_observe_moon,jd(i),starting,stopping
     print,format=fmt,jd(i),diameter(i),PA(i),dist(i),offset(i),filter_angle(i),starting,stopping
     printf,12,format=fmt,jd(i),diameter(i),PA(i),dist(i),offset(i),filter_angle(i),starting,stopping
     printf,14,format=fmt2,jd(i),offset(i),filter_angle(i),starting,stopping
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

