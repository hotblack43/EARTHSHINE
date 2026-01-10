PRO get_zodiacal_SMK,jd,zd
common sukminkwoon,iflagSMK,delta_lon,delta_lat,zoddata
if (iflagSMK ne 314) then begin
zoddata=float(get_data('~/idl_tools/sukminnkwoonZLtablewithoutheaders.dat'))
; Note that the table from Suk Minn KWoon is missing 30x30 degree innermost part!
delta_lon=findgen(181)*2
delta_lat=findgen(46)*2
iflagSMK=314
endif
 ; get coords from JD
 moon,jd,ra,dec,phase,moonlon,moonlat
 SUNPOS, jd, sunra, sundec, elong
 eclipticlat=moonlat
 heliolon=moonlon-elong
 if (heliolon gt 180) then heliolon=heliolon-180
; interpolate the table in log-space and convert back to linear
 inter=10^grid_interpol(alog10(zoddata),delta_lat,delta_lon,[abs(eclipticlat)],[abs(heliolon)])
 inter=10.0-2.5*alog10(inter)	; mags/sq deg
 inter=inter+2.5*alog10(3600.0d0^2)	; mags/sq asec
 inter=inter-2.5*alog10(6.67^2)	; mags/pixel on our CCD
 inter=10.0^((15.1-inter)/2.5)	; counts per second per pixel for our Andor camera
 zd=inter
return
end


common sukminkwoon,iflagSMK,delta_lon,delta_lat,zoddata
iflagSMK=1
for jd=julday(1,1,2013,1,1,1),julday(1,1,2014,1,1,1),1.09 do begin
get_zodiacal_SMK,jd,zd
endfor
 end
