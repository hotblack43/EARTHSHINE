; test the Moon positions from JPL against MOONPOS
data=get_data('m.tab')
jd=reform(data(0,*))
hh=reform(data(1,*))
mm=reform(data(2,*))
ss=reform(data(3,*))
deg=reform(data(4,*))
mi=reform(data(5,*))
se=reform(data(6,*))
MOONPOS,jd,ra1,dec1
openw,1,'d.dat'
for i=0,n_elements(jd)-1,1 do begin
ra=ten(hh(i),mm(i),ss(i))*15.
dec=ten(deg(i),mi(i),se(i))
printf,1,i,ra-ra1(i),dec-dec1(i)
endfor
close,1
d=get_data('d.dat')
!P.MULTI=[0,2,2]
plot,reform(d(0,*)),reform(d(1,*)),yrange=[-1,1]
plot,reform(d(0,*)),reform(d(2,*)),yrange=[-1,1]
plot,reform(d(1,*)),reform(d(2,*)),yrange=[-1,1],xrange=[-1,1]
end
