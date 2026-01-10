n=500
years=1500+indgen(n)
m=22
proxies=fltarr(m,n)
for i=0,m-1,1 do begin
proxies(i,*)=randomn(seed,n)
endfor
coefs=randomu(seed,m)
print,'Coefficients chosen:',coefs
openw,13,'coefs_4_bo.dat'
printf,13,coefs
close,13
y=coefs#proxies
openw,11,'proxies.dat'
openw,12,'Temp.dat'
for i=0,n-1,1 do begin
printf,11,format='(i5,22(1x,f10.3))',years(i),proxies(*,i)
printf,12,format='(i5,1x,f10.3)',years(i),y(i)
endfor
close,11
close,12
end
