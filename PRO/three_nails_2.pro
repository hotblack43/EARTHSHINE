FUNCTION broyfunc, X
common passed,alfa,width,l1
t=x(0)
n=x(1)
beta=x(2)
gamma=x(3)
delta=x(4)
l2=x(5)
h1=x(6)
h2=x(7)
   RETURN, [1./2.-t*sin(alfa)-n*sin(gamma),$
   			n-2.*t*sin(beta),$
   			t*(cos(beta)-cos(alfa))-n*cos(delta),$
   			t*(sin(beta)-sin(alfa))+n*sin(delta),$
   			t*cos(alfa)-n*cos(gamma),$
   			h1/l1-tan(alfa),$
   			h2/l2-tan(alfa/3.),$
   			h1+h2-0.2*width]
END

;=====================
common passed,alfa,width,l1

width=1.0
l1=0.1*width
n=100
xx=fltarr(n+1)
yy=fltarr(n+1)
zz=fltarr(n+1)
i=0
for set_alfa_degrees=10.,89.,(89.-10.)/100. do begin
alfa=set_alfa_degrees/180.*!pi
;Provide an initial guess as the algorithm's starting point:
if (i eq 0) then X = [0.4d0/2.,0.7/2.,alfa/3.d0,alfa*0.28,alfa/3.d0,0.4,0.1,0.1]

xx(i)=set_alfa_degrees
;Compute the solution:
result = BROYDEN(X, 'BROYFUNC',/double,check=check,tolx=1e-9,itmax=1000)
t=result(0)
n=result(1)
beta=result(2)
gamma=result(3)
delta=result(4)
l2=result(5)
h1=result(6)
h2=result(7)
yy(i)=beta*180./!pi
zz(i)=delta*180./!pi
i=i+1
;Print the result:
fmt='(10(1x,f8.3),1x,i1)'
PRINT,format=fmt, t,n,set_alfa_degrees,result(2:4)*180./!pi,h1,h2,l1,l2,check
endfor
plot,xx,yy,yrange=[0,90],xtitle='!7a!3',ytitle='!7b!3',xrange=[0,90],xstyle=1,psym=4
;oplot,xx,zz
plots,[0,90],[0,90]
polyfill,[0,90,90,0,0],[0,90,100,100,0],/line_fill,orientation=60
end