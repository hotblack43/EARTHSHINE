n=1000
F=randomn(seed,n)
F=pseudo_t_guarantee_ac1(F,0.77,1,seed)
fa=0.1*F
fb=f-fa
;-------------------
m1=1
m2=10
k=.1
c1=0.1
c2=10.0
;------------------------
t2=0.0
for i=0,n-1,1 do begin
t1=(-fa(i)*(m2*c2+k)-k*fb(i))/(k*k-(m1*c1+k)*(m2*c2+k))
t2old=t2
t2=((fb(i)+k*t1)/(m2*c2+k)+t2old)/2.
;print,i,t1,t2,fa(i),fb(i)
if (i eq 0) then x=t1
if (i gt 0) then x=[x,t1]

if (i eq 0) then y=t2
if (i gt 0) then y=[y,t2]
endfor
plot,x
oplot,y,thick=3
end