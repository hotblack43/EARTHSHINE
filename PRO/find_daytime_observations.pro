PRO gogettheJD,str,jd
bist=strsplit(str,'/',/extract)
jdx=strpos(bist,'245')
substr=strmid(bist(where(jdx eq 0)),0,15)
kdx=strpos(substr,'_')
if (kdx ne -1) then begin
strput,substr,'.',kdx(0)
endif
jd=double(substr)
return
end

; Finds the SOlare altitude for all items on Chris_best_list...
openw,67,'best_altitude.dat'
obsname='mlo'
jd=0.0d0
openr,33,'allfits'
while not eof(33) do begin
str=''
readf,33,str
gogettheJD,str,jd
sunpos, JD, RAsun, DECsun
eq2hor, RAsun, DECsun, JD, sun_altitude, sun_az, ha, lon=-155.0, lat=18
fmt_str='(f15.7,1x,f5.1,1x,a)'
printf,67,format=fmt_str,jd,sun_altitude,str
print,format=fmt_str,jd,sun_altitude,str
endwhile
close,67
close,33
end

