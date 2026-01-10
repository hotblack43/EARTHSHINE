common zodiacal,iflag,zoddata,delta_lon,delta_lat
openw,33,'zodi_cts.dat'
iflag=1
jd=get_data('DMI_and_ROLFSVEJ_JDs.txt')
for i=0,n_elements(jd)-1,1 do begin
get_zodiacal,jd(i),zd
printf,33,jd(i),zd
endfor
close,33
end
