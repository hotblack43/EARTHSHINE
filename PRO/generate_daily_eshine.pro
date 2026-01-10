file='tab.dat'
data=get_data(file)
jd=reform(data(0,*))
Int=reform(data(1,*))
period=29.53059d0
xx=(jd/period mod 1)
yy=Int
plot,xx,yy
openw,44,'newtab.dat'
for i=0,n_elements(xx)-1,1 do begin
printf,44,xx(i),yy(i)
endfor
close,44
end
