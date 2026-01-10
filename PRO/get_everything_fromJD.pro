 PRO get_everything_fromJD,JD,phase,azimuth,am,glon,glat
 help,JD,phase,azimuth,am,glon,glat
 obsname='mlo'
help,obsname,obs_struct
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the phase and azimuth
 MOONPHASE,jd,azimuth,phase,alt_moon,alt_sun,obsname
 ; get the airmass
 moonpos, JD, RAmoon, DECmoon
 am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
; get the sunglint stuff
get_sunglintpos,jd,glon,glat,az_moon,alt_moon,moonlat,moonlong
 print,format='(f15.7,4(1x,f9.4))',JD,azimuth,phase,glon,glat
 return
 end
