jd=julday(12,11,2010,6,9,57)
SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha,obsname='lapalma'
MOONPOS, jd, ra_moon, DECmoon, dis
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,lon=obslon,lat=obslat
print,'Moon:',alt_moon
print,'Sun :',alt_sun
end
