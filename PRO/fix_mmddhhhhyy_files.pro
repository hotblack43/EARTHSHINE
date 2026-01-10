file='SPE_list_mmddhhhhyear.dat'
data=get_data(file)
mm=reform(data(0,*))
dd=reform(data(1,*))
hhhh=fix(reform(data(2,*))/100.)
yy=reform(data(3,*))
jd=julday(mm,dd,yy,hhhh)
openw,12,'SPE_keydates_JD.dat'
openw,22,'SPE_keydates_yy_doy.dat'
for i=0,n_elements(jd)-1,1 do begin
printf,12,jd(i)
caldat,jd(i),mm,dd,yy
printf,22,yy,jd(i)-julday(1,1,yy)+1
endfor
close,12
close,22
end