; first an autocorrelated but not i(1) example
rho=1.0
N=201
x=fltarr(n)
s=randomn(seed,n)
for i=1,n-1,1 do begin
x(i)=rho*x(i-1)+randomn(seed)
endfor
x=x(1:n-1)
n=n_elements(x)
plot,x,xtitle='Time'
; generate Y
a=1.0
b=3.1415
eta=0.5
y=a+b*x+eta*randomn(seed)
oplot,y,color=fsc_color('red')
; save
openw,1,'examples.csv'
printf,1,' time , x_i0  ,  y_i0'
for i=0,n-1,1 do begin
printf,1,i,',',x(i),',',y(i)
endfor
close,1
print,'Now run Gretl'
end
