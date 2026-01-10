







FUNCTION f,r,coeffs
a=coeffs(0)
b=coeffs(1)
c=coeffs(2)
d=coeffs(3)
e=coeffs(4)
f=a+b/r^c+d/r^e
f=f/total(f,/nan)
return,f
end

pwr1=1
pwr2=2
pwr3=3
x=findgen(512*3)
!P.CHARSIZE=1.8
coeffs=[0.,1.,pwr1,50.,pwr2]
plot_oo,yrange=[0.0000001,10],x,f(abs(x),coeffs),xrange=[0.1,1600]
coeffs=[0.,1.,pwr1,50.,pwr3]
oplot,x,f(abs(x),coeffs),color=fsc_color('red')
end
