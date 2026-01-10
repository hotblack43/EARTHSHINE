tstep=60.d0
for latitude=0.,90.,10. do begin
longitude=0.0
jdstart=double(julday(1,1,2007))
jdstop=double(julday(1,1,2008))
timeup=0.0
timedn=0.0
for jd=jdstart,jdstop,tstep/3600./24. do begin
        SUNPOS, jd, ra_sun, dec_sun
        eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha, lat=latitude,lon=longitude
if (alt_sun gt 0) then timeup=timeup+tstep/3600./24.
if (alt_sun le 0) then timedn=timedn+tstep/3600./24.
endfor
print,'lat:',latitude,' % up=',timeup/(jdstop-jdstart)*100.,' %dn=',timedn/(jdstop-jdstart)*100.,' Sum:',(timeup+timedn)/(jdstop-jdstart)*100.
endfor
end
