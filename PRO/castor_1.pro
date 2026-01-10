n=100
x=randomu(seed,n)
x=pseudo_t_guarantee_ac1(x,0.77,1,seed)
y=shift(x,1)+randomn(seed)*0.1
plot,x,thick=3
oplot,y
openw,3,'c:\castor1.dat'
printf,3,'X                 Y'
for i=0,n-1,1 do  printf,3,x(i),y(i)
close,3
print,'Done'
end