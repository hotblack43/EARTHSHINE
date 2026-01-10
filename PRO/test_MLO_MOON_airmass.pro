jd=get_data('jd')
mlo_airmass,jd,am
plot,jd-long(jd),am,psym=7
openw,33,'JD_airmass_2455858.dat'
for i=0,n_elements(am)-1,1 do begin
printf,33,format='(f20.6,1x,f8.4)',jd(i),am(i)
endfor
close,33
end
