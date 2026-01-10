n=100
x=randomn(seed,n)
idx=sort(x)
x=x(idx)
y=1.0+2.0*x^2+randomn(seed,n)
for Degree=1,4,1 do begin
Result = POLY_FIT( X, Y, Degree,sigma=sigs,yband=yband,yfit=yhat)
print,Degree
for i=0,Degree,1 do begin
print,Result(i),' +/- ',sigs(i)
endfor
plot,x,y,psym=7,xstyle=1,ystyle=1
oplot,x,yhat,color=fsc_color('red')
oplot,x,yhat+yband,linestyle=2
oplot,x,yhat-yband,linestyle=2
endfor
end
