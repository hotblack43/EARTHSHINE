PRO getmoon_ecliptic_lonfromsun_and_lat,jd,moonheliolon,moonecllat
; returns distance in degrees from moon to suna long the ecliptic
; and Moons ecliptic latitude also in degrees
; input is julian day
moon,jd,ra,dec,phase,moonlon,moonlat
 EULER, ra,dec, moonECLlon,moonECLlat,  3
 SUNPOS, jd, sunra, sundec, elong
 EULER, sunra,sundec, sunECLlon,sunECLlat,  3
 moonheliolon=moonECLlon-sunECLlon
return
end
