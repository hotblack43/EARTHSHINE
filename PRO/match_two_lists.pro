!P.CHARSIZE=1.9
list1='Star_17_photometry.dat'
data1=get_data(list1)
list2='Star_27_photometry.dat'
data2=get_data(list2)
jd1=reform(data1(0,*))
jd2=reform(data2(0,*))
fi1=reform(data1(6,*))
fi2=reform(data2(6,*))
openw,66,'matches.dat'
for i=0,n_elements(JD1)-1,1 do begin
idx=where(jd2 eq jd1(i))
if (idx(0) ne -1) then begin
if (n_elements(idx) ne 1) then stop
print,format='(f15.7,2(1x,f9.4))',jd1(i),data1(1,i),data2(1,idx),fi1(i),fi2(idx)
printf,66,format='(f15.7,4(1x,f20.10),2(1x,i2))',jd1(i),data1(1,i),data2(1,idx),data1(3,i),data2(3,idx),fi1(i),fi2(idx)
endif
endfor
close,66
data=get_data('matches.dat')
plot,data(1,*),data(2,*),psym=1,/isotropic,    $
xtitle='Mag of a star  in several images',$
ytitle='Mag other star in several images',charsize=1.7
end
