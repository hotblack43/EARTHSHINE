 ; Converst RA/DEC to Alt/AZ
 common obs,obsname
 common lims,sun_lim,am_lim
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 ; note the minus sign - lon follows observatory.pro and -lon what zensun expects (USA is neg lon)
 lon=-obs_struct.longitude
 print,'lon,lat: ',lon,lat
; case 1
;ra_moon=172.893196073
;DEmoon=-4.89141991793
;jd=julday(6,21,2011,8,19,21)
; case 2
;171.899619078, -4.89198185671
;2011-06-21T08:15:23
ra_moon=171.899619078
DEmoon=-4.89198185671
jd=julday(6,21,2011,8,15,23)
; case 3 M7
;269.474019651, -34.8437781158
;2011-06-21T12:25:44
ra_moon=269.474019651
DEmoon=-34.8437781158
jd=julday(6,21,2011,12,25,44)
; calib1.fits
;279.195922656, -38.544723061
;2011-06-23T13:28:41
ra_moon=279.195922656
DEmoon=-38.544723061
jd=julday(6,23,2011,23,28,41)
; calib2.fits
; 279.193339675, -38.5445960193
;18:36:46.402, -38:32:40.546
;2011-06-23T13:28:41
;ra_moon=279.193339675
;DEmoon=-38.5445960193
;jd=julday(6,23,2011,23,28,41)
;---------------------------------
; 2011-06-30T06:48:31
;ra_moon=212.593057783
;DEmoon=-61.2107202664
;............................
; YU55_11_9_2011_7_0_UTC.csv
jd=julday(11,9,2011,7,0,0)
;stringad,'23 44 23 19 12 57',ra_moon,dec_moon
cvtsixty,'23:44:23',0.0d0,360.0d0,1,['',''],ra_moon,/HOURS,/DEGREES
cvtsixty,'19:12:57',-90.0d0,90.0d0,1,['',''],dec_moon,/DEGREES
print,ra_moon,dec_moon
 eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
print,'RA:',sixty(ra_moon/360.*24.)
print,'DEC :',sixty(dec_moon)
print,'Alt:',alt_moon,' or in deg/min/sec: ',sixty(alt_moon)
print,'Az :',az_moon,' or in deg/min/sec: ',sixty(az_moon)
end
