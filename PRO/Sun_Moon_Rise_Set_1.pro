PRO go_look_rise_set
data=get_data('SUnMoonRiseSet.dat')
sunup=reform(data(0,*))
sundn=reform(data(1,*))
moonup=reform(data(2,*))
moondn=reform(data(3,*))
plot,sunup-long(sunup),color=fsc_color('yellow'),ystyle=1,yrange=[-1,1]
oplot,sundn-long(sundn),linestyle=2,color=fsc_color('yellow')
oplot,moonup-long(moonup),color=fsc_color('blue')
oplot,moondn-long(moondn),linestyle=2,color=fsc_color('blue')
return
end

PRO go_get_sun_moon_rise_set,sunrise,sunset,moonOKstart,moonOKend
data=get_data('temp.tmp')
jd=reform(data(0,*))
am=reform(data(1,*))
alt_sun=reform(data(2,*))
n=n_elements(jd)
sunrise=-911
sunset=-911
moonOKstart=jd(0)
moonOKend=jd(n-1)
sun_lim=-5
am_lim=2.
for i=1,n-1,1 do begin
; find sunrise
if (alt_sun(i) gt sun_lim and alt_sun(i-1) le sun_lim) then sunrise=jd(i)
; then sunset
if (alt_sun(i) le sun_lim and alt_sun(i-1) gt sun_lim) then sunset=jd(i)
; find Moon rise above its OK limit
if (am(i) le am_lim and am(i-1) gt am_lim) then moonOKstart=jd(i)
; then Moon set below its OK limit
if (am(i) gt am_lim and am(i-1) le am_lim) then moonOKend=jd(i)
endfor
return
end


 ; Will print a table of times for sun and moon rise and set 
 ;
 common obs,obsname
 obsname='mlo'
 jdstart=double(julday(1,1,2011,12,0,0))
 jdend=double(julday(3,1,2011,12,0,0))
 jdstep=1.
 openw,4,'SUnMoonRiseSet.dat'
 ic=0
 for ijd=jdstart,jdend,jdstep do begin
;print,'JD: ',ijd
 openw,3,'temp.tmp'
 for jd=ijd-2.0,ijd+2.0,1./24./12. do begin
     sunpos, JD, RAsun, DECsun
     eq2hor, raSUN, decSUN, jd, alt_SUN, az, ha,  OBSNAME=obsname
         moonpos, JD, RAmoon, DECmoon
         eq2hor, ramoon, decmoon, jd, alt_moon, az, ha,  OBSNAME=obsname
         observatory,obsname,obs_struct
         am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, obs_struct.latitude*!dtor, obs_struct.longitude*!dtor)
	printf,3,format='(f20.7,1x,g9.4,1x,f9.2)',jd,am,alt_SUN
 endfor
 close,3
; analyze temp.tmp
go_get_sun_moon_rise_set,sunrise,sunset,moonOKstart,moonOKend
txt='Dont know'
if (moonOKstart gt sunrise and moonOKend le sunset) then txt='M rises during night, sets before sunset'
if (moonOKstart gt sunrise and moonOKend gt sunset) then txt='M rises during night, up at sunset'
if (moonOKstart gt sunset and moonOKend lt sunrise) then txt='M never up'
if (moonOKstart le sunrise and moonOKend lt sunset) then txt='M already up, sets before morning'
print,format='(i3,1x,4(1x,f11.3),1x,a)',ic,sunrise,sunset,moonOKstart,moonOKend,txt
printf,4,format='(4(1x,f11.3))',sunrise,sunset,moonOKstart,moonOKend
ic=ic+1
     endfor
close,4
; look at the rise and set times
go_look_rise_set
 end
