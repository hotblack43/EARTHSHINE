file='Chris_list_good_images.txt'
get_lun,uytgvfrtde
openr,uytgvfrtde,file
openw,90,'jd_and_k.dat'
while not eof(uytgvfrtde) do begin
str=''
readf,uytgvfrtde,str
mphase,str,k
printf,90,str,k,long(str)


endwhile
close,uytgvfrtde
free_lun,uytgvfrtde
close,90
;
data=get_data('jd_and_k.dat')
jd=reform(data(0,*))
k=reform(data(1,*))
fixjd=long(jd)
uniqjd=fixjd(sort(fixjd))
uniqjd=uniqjd(uniq(uniqjd))
openw,42,'jdandkintjd.dat'
for i=0,n_elements(uniqjd)-1,1 do begin
idx=where(long(jd) eq uniqjd(i))
printf,42,uniqjd(i),mean(k(idx)),n_elements(idx)
endfor
close,42
data=get_data('jdandkintjd.dat')
jd=reform(data(0,*))
meank=reform(data(1,*))
numb=reform(data(2,*))
histo,meank,/abs,0,1,0.15
end
