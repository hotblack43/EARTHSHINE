obsname='lund'
observatory, obsname, obs
observatory_longitude = obs.longitude
observatory_latitude  = obs.latitude
observatory_altitude  = obs.altitude
fmt='(f20.5,1x,1x,i2,1x,i2,1x,i4,1x,i2,1x,i2,1x,f5.2,2(1x,i3,1x,i2,1x,f6.2),2(1x,f10.5))'
openw,44,'MOON_RA_DEC.dat'
print,'       Julian         Mo Dd Year Hr Mi secs   hh mm  ss.ss ddd mm  ss.ss   Azimuth    Altitude'
printf,44,'       Julian         Mo Dd Year Hr Mi secs   hh mm  ss.ss ddd mm  ss.ss   Azimuth    Altitude'

for xJD=julday(8,30,2010,0,0,0),julday(8,30,2010,0,10,0),1.d0/24./12. do begin
; for the JD get the GEOcentric RA and DEC of the Moon
moonpos, xJD, RAmoon, DECmoon, Dem
; calculate azimuth and altitude for the given site
eq2hor, RAmoon, DECmoon, xJD, alt_moon, az_moon, ha=ha,  OBSNAME=obsname
; now get the TOPOcentric RA and DEC
hor2eq,alt_moon, az_moon,xJD,RAmoon, DECmoon, ha=ha, OBSNAME=obsname
caldat,xJD,a,b,c,d,e,f
; convert all decimals 
radec, ramoon, decmoon, ihr, imin, xsec, ideg, imn, xsc
print,format=fmt,xJD,a,b,c,d,e,f,ihr, imin, xsec, ideg, imn, xsc, az_moon,alt_moon
printf,44,format=fmt,xJD,a,b,c,d,e,f,ihr, imin, xsec, ideg, imn, xsc,az_moon,alt_moon
endfor
close,44
end


