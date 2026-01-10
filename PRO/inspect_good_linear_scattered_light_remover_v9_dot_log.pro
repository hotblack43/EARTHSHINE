 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

PRO get_airmass,jd,am
;
; Calculates the airmass of the observed Moon as seen from MLO
;
; INPUT:
;   jd  -   julian day
; OUTPUT:
;   am  -   the required airmass
;
    lat=19.5d0
    lon=155.12d0
    MOONPOS,jd,ra,dec
    eq2hor,ra,dec,jd,alt,az,lon=lon,lat=lat
    ra=degrad(ra)
    dec=degrad(dec)
    lat=degrad(lat)
    lon=degrad(lon)
    am = airmass(jd,ra,dec,lat,lon)
    return
end

FUNCTION SUNEARTHMOON_ANGLE,jd_in
; returns the angle (in DEGREES) between Sun-Earth-Moon - i.e. as seen from Earth
; code taken from a VB script at http://www.paulsadowski.com/WSH/moonphase.htm
;     ' Calculate illumination (synodic) phase
jd=jd_in+29.530588853/2.d0
V=(jd-2451550.1)/29.530588853
V=V-fix(V)
if (V lt 0) then  V=V+1
V=V*360. ; this is the angle as seen from the Moon between Sun and Earth
; V=360.-V    ; this is the angle as seen from Earth between Sun and Moon, i.e. the 'phase angle'
V = V - 180.0  ; nu blir det fasvinkeln sett från jorden
return,V
end

PRO get_filtername,header,name
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strmid(str,29,8)
 return
 end

 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

PRO determineFLIP,JD,refimFLIPneeded,alt_moon, az_moon
refimFLIPneeded=0
MOONPOS, jd, ramoon, DECmoon, dis
obsname='MLO'
eq2hor, ramoon, decmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
print,'az:',az_moon
if (az_moon gt 180.) then refimFLIPneeded=1
print,'refimFLIPneeded:',refimFLIPneeded
return
end

PRO getheaderinfo,h,jd,az,moonphase,airmass,exptime,filtername
get_time,h,JD
get_filtername,h,filtername
determineFLIP,JD,refimFLIPneeded,alt_moon, az
moonphase=SUNEARTHMOON_ANGLE(jd)
get_EXPOSURE,h,exptime
get_airmass,jd,airmass
return
end

file='good_linear_scattered_light_remover_v9.log'
file='best_linear_scattered_light_remover_v9b.log'	; COADD removed
openr,1,file
openw,31,'logOUT_B.dat'
openw,32,'logOUT_V.dat'
openw,33,'logOUT_VE1.dat'
openw,34,'logOUT_VE2.dat'
openw,35,'logOUT_IRCUT.dat'
while not eof(1) do begin
fname=''
x=fltarr(9)
readf,1,x,fname
fname=strcompress(fname,/remove_all)
;349.530      249.991      126.052      339.860      252.981      120.372      51237.4  3.31793e+08      0.00000
x0=x(3)
y0=x(4)
radius=x(5)
totflux=x(7)
im=readfits(fname,h)
getheaderinfo,h,jd,az,moonphase,airmass,exptime,filtername
filtername=strcompress(filtername,/remove_all)
fmt='(f15.7,3(1x,f9.3),1x,e20.10,2(1x,f9.4),1x,a)'
if (filtername eq 'B') then printf,31,format=fmt,jd,az,moonphase,airmass,totflux,exptime,radius,fname
if (filtername eq 'V') then printf,32,format=fmt,jd,az,moonphase,airmass,totflux,exptime,radius,fname
if (filtername eq 'VE1') then printf,33,format=fmt,jd,az,moonphase,airmass,totflux,exptime,radius,fname
if (filtername eq 'VE2') then printf,34,format=fmt,jd,az,moonphase,airmass,totflux,exptime,radius,fname
if (filtername eq 'IRCUT') then printf,35,format=fmt,jd,az,moonphase,airmass,totflux,exptime,radius,fname
endwhile
close,1
close,31
close,32
close,33
close,34
close,35
end
