JD=double(systime(/julian,/utc))
print,format='(f20.10)',jd
MOONPOS, jd, ra_moon, DECmoon, dis
print,sixty(ra_moon),sixty(DECmoon)
eq2hor, ra_moon, decmoon, jd, alt_moon, az_moon, ha, obsname='mlo'
print,'Alt,Az: ',alt_moon, az_moon
end
