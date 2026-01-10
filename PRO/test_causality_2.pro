n=1000
F=randomn(seed,n)
F=pseudo_t_guarantee_ac1(F,0.77,1,seed)
fa=0.1*F
fb=f-fa
;-------------------
m1=1
m2=10
k=.7
c1=1
c2=10.0
;------------------------
t2=0.0
t1=0.0
openw,23,'Tair_Tsea.dat'
for i=0,n-1,1 do begin
t1new=(fa(i)+k*(t2-t1))/m1/c1
t2new=(fb(i)-k*(t2-t1))/m2/c2
weight1=0.005
weight2=0.05
t1=t1new
t2=t2new
t2=(t2new*(1.-weight2)+t2*weight2)
t1=(t1new*(1.-weight1)+t1*weight1)
if (i eq 0) then x=t1
if (i gt 0) then x=[x,t1]

if (i eq 0) then y=t2
if (i gt 0) then y=[y,t2]
printf,23,i,fa(i)+fb(i),t1,t2
endfor
y=smooth(y,3)
close,23
plot,x
oplot,y,thick=3
print,correlate(x,y)
print,correlate(x,shift(y,-1))
print,correlate(x,shift(y,1))
print,''
print,correlate(fb,y)
print,correlate(fb,shift(y,-1))
print,correlate(fb,shift(y,1))
print,''
print,correlate(fa,x)
print,correlate(fa,shift(x,-1))
print,correlate(fa,shift(x,1))
end