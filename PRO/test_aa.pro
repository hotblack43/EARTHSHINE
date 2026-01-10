obsname='lund'
observatory, obsname, obs
observatory_longitude = -obs.longitude
observatory_latitude  = obs.latitude
observatory_altitude  = obs.altitude
print,'lon,lat:',observatory_longitude,observatory_latitude
TZ=0
;...................................
; setthe date here
mm=12
dd=13
yy=2010
;...................................
xJD=julday(mm,dd,yy,5+TZ,0,10)
moonpos, xJD, RAmoon, DECmoon, Dem
eq2hor, RAmoon, DECmoon, xJD, moon_altitude, az, ha, LAT=observatory_latitude , LON=observatory_longitude ,  $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
print,format='(a,f9.3,a,f20.6)','Up Moon alt:',moon_altitude,' jd=',xjd
;...................................
xJD=julday(mm,dd,yy,7+TZ,41,10)
sunpos, xJD, RAmoon, DECmoon, Dem
eq2hor, RAmoon, DECmoon, xJD, moon_altitude, az, ha, LAT=observatory_latitude , LON=observatory_longitude ,  $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
print,format='(a,f9.3,a,f20.6)','Up Sun alt:',moon_altitude,' jd=',xjd
;...................................
xJD=julday(mm,dd,yy,11+TZ,57,12)
moonpos, xJD, RAmoon, DECmoon, Dem
eq2hor, RAmoon, DECmoon, xJD, moon_altitude, az, ha, LAT=observatory_latitude , LON=observatory_longitude ,  $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
print,format='(a,f9.3,a,f20.6)','Dn Moon alt:',moon_altitude,' jd=',xjd
;...................................
xJD=julday(mm,dd,yy,14+TZ,45,12)
sunpos, xJD, RAmoon, DECmoon, Dem
eq2hor, RAmoon, DECmoon, xJD, moon_altitude, az, ha, LAT=observatory_latitude , LON=observatory_longitude ,  $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
print,format='(a,f9.3,a,f20.6)','Dn Sun alt:',moon_altitude,' jd=',xjd
;...................................
end

