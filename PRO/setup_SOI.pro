file='SOI_monthly.dat'
data=get_data(file)
years=reform(data(0,*))
data=reform(data(1:12,*))
openw,33,'SOI.data'
for iy=min(years),max(years),1 do begin
for im=1,12,1 do begin
print,years(iy-1949)+(im-0.5)/12.,data(im-1,iy-1949)
printf,33,years(iy-1949)+(im-0.5)/12.,data(im-1,iy-1949)
endfor
endfor
close,33
end
