common flags_meteoro,mlo_flag,jd,pressure
mlo_flag=0
jd_want=reform(get_data('JDs.dat'))
n=n_elements(jd_want)
openw,33,'jd_p.dat'
for i=0,n-1,1 do begin
extract_p_mlo,reform(jd_want(i)),p_out
print,format='(f15.7,1x,f9.2)',jd_want(i),p_out
printf,33,format='(f15.7,1x,f9.2)',jd_want(i),p_out
endfor
close,33
end
