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
angle=abs(dis/!pi*180.)
if (ra_moon gt ra_sun) then angle=-angle
return
end

 PRO gogetjulianday,header,jd
 idx=strpos(header,'JULIAN')
 str=header(where(idx ne -1))
 jd=double(strmid(str,15,15))
 return
 end

openw,33,'tab.dat'
files=file_search('OUTPUT/IDEAL/ideal*',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i),h,/sil)
gogetjulianday,h,jd
get_sunmoonangle,jd,ang
print,format='(1x,f17.7,1x,g20.15,1x,f9.2)',jd,total(im,/double),ang
printf,33,format='(1x,f17.7,1x,g20.15,1x,f9.2)',jd,total(im,/double),ang
endfor
close,33
data=get_data('tab.dat')
jd=reform(data(0,*))
fl=reform(data(1,*))
angle=reform(data(2,*))
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
; plot the old table
data=get_data('moonbrightness.tab')
day=reform(data(0,*))
old=reform(data(2,*))
plot_io,/nodata,day,old,xtitle='Days',ytitle='Flux',title='Disc-integrated flux from models (red is old)'
oplot,day,old,color=fsc_color('red'),psym=1
fl=1.3*fl/mean(fl)*mean(old)	; 1.3 is fudge - to match previous results
fullmoon=2456113.6489048d0
oplot,(jd-fullmoon),fl,psym=7
openw,44,'other.new.moonbrightness.tab'
for i=0,n_elements(fl)-1,1 do begin
printf,44,format='(f16.7,1x,f17.3,1x,g10.6)',jd(i)-fullmoon,angle(i),fl(i)
print,format='(f16.7,1x,f17.3,1x,g10.6)',jd(i)-fullmoon,angle(i),fl(i)
endfor
close,44
print,'New moonbrightness table generated.'
end
