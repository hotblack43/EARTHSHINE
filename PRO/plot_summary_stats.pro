file='counts.dat'
;
data=get_data(file)
counts=reform(data(0,*))
JD=reform(data(1,*))
caldat,jd,mm,dd,yy
for i=0,n_elements(jd)-1,1 do begin
print,counts(i),jd(i),mm(i)
endfor
end
