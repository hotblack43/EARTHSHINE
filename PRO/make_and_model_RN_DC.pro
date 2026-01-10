n=10000
RN=1.0
dc=1.9
x=findgen(n)
openw,33,'p.dat'
for meanval=10.0,200.0,2.0 do begin
y=RN*randomn(seed,n)+randomn(seed,n,poisson=meanval)+dc*meanval*randomn(seed,n)
;plot,x,y
printf,33,mean(y),stddev(y)
endfor
close,33
data=get_data('p.dat')
mn=reform(data(0,*))
sd=reform(data(1,*))
plot,xtitle='Mean',ytitle='S.D.',mn,sd,psym=7
xx=[[sqrt(mn)],[mn]]
xx=transpose(xx)
yy=sd
res=regress(xx,yy,const=rn,/double,yfit=yhat,sigma=sigs)
oplot,mn,yhat,color=fsc_color('red')
print,'RN:                 ',rn
print,'factor on sqrt(mu): ',res(0),' +/- ',sigs(0)
print,'Dark Current:       ',res(1),' +/- ',sigs(1)
oplot,mn,mn,color=fsc_color('blue')
end
