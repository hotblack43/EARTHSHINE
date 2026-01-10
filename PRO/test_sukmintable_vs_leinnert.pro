FUNCTION interpolatezodiacaltable,table,tablelon,tablelat,inlon,inlat
; return ZL in units of our Andor CCD - counts/second/pixel
if (abs(inlat) gt max(abs(tablelat)) or abs(inlat) lt min(abs(tablelat))) then stop
 inter=10^grid_interpol(alog10(table),tablelon,tablelat,[abs(inlon)],[abs(inlat)])
 ;print,'table,lon,lat: ',inter,inlon,inlat
 inter=10.0-2.5*alog10(inter)	; mags/sq deg
 inter=inter+2.5*alog10(3600.0d0^2)	; mags/sq asec
 inter=inter-2.5*alog10(6.67^2)	; mags/pixel on our CCD
 value=10.0^((15.1-inter)/2.5)	; counts per second per pixel for our Andor camera
return,value
end


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
 getmoon_ecliptic_lonfromsun_and_lat,jd,heliolon,eclipticlat
 heliolon=abs(heliolon)
 eclipticlat=abs(eclipticlat)
 if (heliolon gt 180) then heliolon=heliolon-180
 zd=interpolatezodiacaltable(zoddata,delta_lon,delta_lat,heliolon,eclipticlat)
 print,'SMK      zd,lon,lat: ',zd,heliolon,eclipticlat
 return
 end
 
 PRO get_zodiacal,jd,zd
 ; will interpolate in the Leinert et al 1998 Table for Zodiacal light intensity in units of 10th mag stars/deg²
 ; will return counts per second expected on our 6.67x6.67 mu CCD
 common zodiacal,iflag,zoddata,delta_lon,delta_lat
 common otherstuff,heliolon,eclipticlat,phase
 if (iflag ne 314) then begin
     zoddata=float(transpose(get_data('~/idl_tools/zodiacal.txt')))
     delta_lon=[0,5,10,15,20,25,30,35,40,45,60,75,90,105,120,135,150,165,180]
     delta_lat=float([0,5,10,15,20,25,30,45,60,75])
     zoddata=zoddata(1:10,*)
     idx=where(zoddata lt 0)
     zoddata(idx)=-999.
     iflag=314
     endif
 ; get coords from JD
 getmoon_ecliptic_lonfromsun_and_lat,jd,heliolon,eclipticlat
 heliolon=abs(heliolon)
 eclipticlat=abs(eclipticlat)
 if (heliolon gt 180) then heliolon=heliolon-180
 
; interpolate the table in log-space and convert back to linear
 zd=interpolatezodiacaltable(zoddata,delta_lon,delta_lat,heliolon,eclipticlat)
 print,'Leinnert zd,lon,lat: ',zd,heliolon,eclipticlat
 return
 end
 
 common sukminkwoon,iflagSMK,delta_lonSMK,delta_latSMK,zoddataSMK
 common zodiacal,iflag,zoddata,delta_lon,delta_lat
 iflag=1
 iflagSMK=1
 openw,44,'JD_vs_ZL.dat'
 openr,23,'DMI_and_ROLFSVEJ_JDs.txt'
 while not eof(23) do begin
 jd=0.0d0
 readf,23,jd
     get_zodiacal_SMK,jd,zd_SMK
;    get_zodiacal,jd,zd
     printf,44,jd,zd_SMK
print,'----------------------------------------------'
     endwhile
close,23
close,44
 end

