FUNCTION broyfunc, X
common passed,alfa
   RETURN, [cos(x(1))-(cos(x(0))-cos(alfa))/2./cos(x(0)),$
   2.*sin(x(0))*sin(x(1))-sin(alfa)+sin(x(0))]
END

;=====================
common passed,alfa
n=100
xx=fltarr(n+1)
yy=fltarr(n+1)
i=0
for set_alfa_degrees=1.,89.,(89.-1.)/100. do begin
alfa=set_alfa_degrees/180.*!pi
;Provide an initial guess as the algorithm's starting point:
X = [0,1]
xx(i)=set_alfa_degrees
;Compute the solution:
result = BROYDEN(X, 'BROYFUNC')
beta=result(0)
gamma=result(1)
yy(i)=beta*180./!pi
i=i+1
;Print the result:
n=sin(beta)/sin(alfa)
m=(cos(beta)-cos(alfa))/sin(alfa)/cos(gamma)/2.
PRINT,format='(f8.2,2(1x,f8.2),2(1x,f8.3))', set_alfa_degrees,result*180./!pi,n,m
endfor
plot,xx,yy,yrange=[0,90],xtitle='!7a!3',ytitle='!7b!3',xrange=[0,90],xstyle=1
plots,[0,90],[0,90]
polyfill,[0,90,90,0,0],[0,90,100,100,0],/line_fill,orientation=60
end