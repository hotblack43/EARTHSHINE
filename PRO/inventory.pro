PRO get_sunmoonangle,jd,angle
; returns the angle between Sun and Moon as seen from Earth
angle=1
MOONPOS, jd, ra_moon, dec_moon, dis
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

PRO gogitJD,bit,JD
str=strmid(bit,0,15)
JD=double(str)
return
end

PRO goparsename,str,JD
stra=strsplit(str,'/',/extract)
n=n_elements(stra)
for k=0,n-1,1 do begin
bit=stra(k)
if (strmid(bit,0,3) eq '245') then begin
gogitJD,bit,JD
return
endif
endfor
stop
return
end

; code that will find the MOON images ina  locationand deduce the JD from
; the filename, and then calculate interesting things, like the SEM angle.
path='/media/SAMSUNG/MOONDROPBOX/'
files=file_search(path,'*MOON*.fit*',count=n)
print,'Found ',n,' files.'
openw,1,'SEM.data'
for i=0,n-1,1 do begin
goparsename,files(i),JD
get_sunmoonangle,jd,angle
printf,1,format='(f9.3,1x,f15.7)',angle,jd
;print,format='(f9.3,1x,f15.7)',angle,jd
endfor
close,1
;
data=get_data('SEMdmi.data')
angle=reform(data(0,*))
n=n_elements(angle)
!X.style=3
!Y.style=3
;histo,angle,min(angle),max(angle),3,xrange=[0,180],xtitle='SEM angle [degrees]',title='Earthshine Moon observations as of '+systime()
histo,angle,min(angle),max(angle),1,xrange=[42-6,42+6],xtitle='SEM angle [degrees]',title='Earthshine Moon observations as of '+systime()
plots,[0,0],[!Y.CRANGE(0),0.3],linestyle=2
plots,[0,0],[0.5,!Y.CRANGE(1)],linestyle=2
xyouts,2.5,0.33,'New Moon',charsize=1.2,orientation=90
plots,[180,180],[!Y.CRANGE(0),0.3],linestyle=2
plots,[180,180],[0.5,!Y.CRANGE(1)],linestyle=2
xyouts,182.5,0.33,'Full Moon',charsize=1.2,orientation=90
plots,[!X.crange],[0,0],linestyle=1
xyouts,/normal,0.1,0.9,string(n)+' observations.'
end
