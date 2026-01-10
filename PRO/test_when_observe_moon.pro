PRO when_observe_moon,jd_in,starting,stopping
 common obs,obsname
 horison_alt=0.0
 aha=long(jd_in)
     icount=0
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
             print,format='(f11.3,3(1x,f9.3))',jd,ramoon,decmoon,am
             icount=icount+1
             icount=icount+1
             endif
         endif
     endfor
	starting=min(list)
	stopping=max(list)
 return
 end
 
 common obs,obsname
 obsname='lapalma'
 jd=double(julday(12,12,2010,12,12,12))
 print,'Testing JD=',jd
 when_observe_moon,jd,starting,stopping
	print,'Start observe mon, stop : ',starting,stopping
 end
 
