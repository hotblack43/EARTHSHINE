!P.MULTI=[0,3,3]
npoints=40
scale=1.
a=0.1
b=1.0
noise_ampl=0.4
openw,45,'bias.dat'
for offset=1.0,2.5,0.05 do begin
noise=randomn(seed,npoints)*noise_ampl
x=randomu(seed,npoints)*scale+offset
y=a+b*x+noise
plot,x,y,psym=7,xrange=[0,4],xstyle=1
res=linfit(x,y,/double,sigma=sigs,yfit=yhat)
print,res(0),sigs(0),res(1),sigs(1)
oplot,x,yhat,thick=3
printf,45,offset,res(0)-a,sigs(0)
endfor
close,45
data=get_data('bias.dat')
x=reform(data(0,*))
y=reform(data(1,*))
dy=reform(data(2,*))
res=linfit(x,y,/double,measure_errors=dy,yfit=yhat)
print,'Estimate of bias:',res(1),' +/- ',sigs(1)
!P.MULTI=[0,1,1]
plot,x,y,psym=7,ystyle=1,xtitle='offset',ytitle='Bias in intercept'
oplot,x,yhat,thick=3
print,'Mean bias:',mean(y),' +/- ',stddev(y)/sqrt(n_elements(y)-1)
end

