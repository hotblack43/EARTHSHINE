PRO get_sunmoonangle,jd,angle
COMPILE_OPT idl2, HIDDEN
; returns the angle between Sun and Moon as seen from Earth
angle=1
MOONPOS, jd, ra_moon, dec_moon, dis
obsname='MLO'
eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
; Where is the Sun in the local sky?
        SUNPOS, jd, ra_sun, dec_sun
        eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  OBSNAME=obsname
; what is the angular distance between Moon and SUn?
u=0     ; radians
gcirc,u,ra_moon*!dtor, dec_moon*!dtor,ra_sun*!dtor, dec_sun*!dtor,dis
angle=dis/!pi*180.
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

 PRO getcoordsfromheader,header,x0,y0,radius,ALFA
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then print,'DISCX0 not in header.'
 x0=float(strmid(header(jdx),15,9))
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then print,'DISCY0 not in header.'
 y0=float(strmid(header(jdx),15,9))
 idx=strpos(header,'DISCRA')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then print,'DISCRA not in header.'
 radius=float(strmid(header(jdx),15,9))
 idx=strpos(header,'ALFA')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then print,'ALFA not in header.'
 alfa=float(strmid(header(jdx),15,9))
 return
 end

files=file_search('/media/SAMSUNG/DARKCURRENTREDUCED/EFMCLEANED/*.fits',count=n)
print,n
obsname='MLO'
openw,33,'data.igtvf'
for i=0,n-1,1 do begin
im=readfits(files(i),h,/silent)
getcoordsfromheader,h,x0,y0,radius,ALFA
get_time,h,JD
get_sunmoonangle,jd,angle
mphase,jd,k
moonpos, JD, RAmoon, DECmoon
eq2hor, ramoon, decmoon, jd, alt_moon, az, ha,  OBSNAME=obsname
sunpos, JD, RAsun, DECsun
eq2hor, RAsun, DECsun, JD, sun_alt, sun_az, ha, OBSNAME=obsname
caldat,jd,mm,dd,yy,hh,mi,se
fmtstr='(f15.7,1x,1x,f7.2)'
angle=abs(angle)
if (ramoon gt RAsun) then angle=-abs(angle)
print,format='(f15.7,2(1x,f9.4))',JD,alfa,angle
printf,33,format='(f15.7,2(1x,f9.4))',JD,alfa,angle
endfor
close,33
data=get_data('data.igtvf')
jd=reform(data(0,*))
alfa=reform(data(1,*))
ph=reform(data(2,*))
!P.MULTI=[0,1,2]
plot,ystyle=3,xstyle=3,jd,alfa,psym=7
plot,ystyle=3,xstyle=3,ph,alfa,psym=7
end

