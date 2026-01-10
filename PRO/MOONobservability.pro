 PRO get_sunmoonangle,jd,angle
 ; returns the angle between Sun and Moon as seen from Earth
 angle=1
obsname='MLO'
 MOONPOS, jd, ra_moon, dec_moon, dis
 eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
 ; Where is the Sun in the local sky?
 SUNPOS, jd, ra_sun, dec_sun
 eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  OBSNAME=obsname
 ; what is the angular distance between Moon and SUn?
 u=0     ; radians
 gcirc,u,ra_moon*!dtor, dec_moon*!dtor,ra_sun*!dtor, dec_sun*!dtor,dis
 angle=dis/!pi*180.
 return
 end
 
 ; code that will describe various aspects of MOON 
 ; observability for a range of days.
 jdstart=systime(/julian)-1.0d0
 jdstop=jdstart+366
 jdstep=1./24.0d0/4.
 sunlim=3.
 moonlim=0.0
 w=10/2.
 lo_angle=42-w
 hi_angle=42+w
	openw,3,'MOONobservability.txt'
	openw,4,'MOONobservability.no_txt'
     print,'A: S-E-M angle, M: Moon altitude, S: Sun altitude'
     printf,3,'A: S-E-M angle, M: Moon altitude, S: Sun altitude, K: Illum fract.'
 fmt='(f15.3,2(1x,i2),1x,i4,2(1x,i2),4(1x,a,1x,f6.2),1x,a)'
 for jd=jdstart,jdstop,jdstep do begin
	mphase,jd,k
     flag=' '
     get_sunmoonangle,jd,angle
     if (angle ge lo_angle and angle le hi_angle) then flag=' *'
     MOONPOS, jd, ra_moon, dec_moon, dis
     ; Where is the MOON in the local sky?
     eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon, lon=lon, lat=lat
     ; Where is the Sun in the local sky?
     SUNPOS, jd, ra_sun, dec_sun
     eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  obslon=lon, lat=lat
     if (alt_sun lt sunlim and alt_moon gt moonlim) then begin
         caldat,jd,dd,mm,yy,hh,mi,se
         print,format=fmt,jd,dd,mm,yy,hh,mi,'A:',angle,'M:',alt_moon,'S:',alt_sun,'K:',k,flag
         printf,3,format=fmt,jd,dd,mm,yy,hh,mi,'A:',angle,'M:',alt_moon,'S:',alt_sun,'K:',k,flag
         printf,4,format=fmt,jd,dd,mm,yy,hh,mi,'',angle,'',alt_moon,'',alt_sun,'',k
         endif
     endfor
     print,'A: S-E-M angle, M: Moon altitude, S: Sun altitude, K: Illum fract.'
     printf,3,'A: S-E-M angle, M: Moon altitude, S: Sun altitude, K: Illum fract.'
     close,3
     close,4
 end
