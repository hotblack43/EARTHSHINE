data=get_data('lap_vs_JAN.dat')
l=size(data,/dimensions)
help,data,l
nrows=l(1)
ncols=l(1)-2
print,nrows,ncols
JD=reform(data(0,*))
JDlap=reform(data(1,*))
JANlap=reform(data(2:l(0)-1,*))
help
a=get_kbrd()
for k=0,l(1)-1,1 do begin
print,JD(k),JDlap(k),mean(JANlap(*,k))
endfor

end
