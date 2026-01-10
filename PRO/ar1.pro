;!P.MULTI=[0,1,1]
;N=10000
;x=fltarr(n)
;x(0)=randomn(seed)
;alfa=0.29
;for i=0,n-2,1 do begin
;x(i+1)=alfa*x(i)+randomn(seed)
;endfor
;plot,x
;
file='C:\RSI\WORK\TN_LOCID000102.txt'
data=read_ascii(file)
x=data.field1(1,*)
res=linfit(indgen(n_elements(x)),x,/double,yfit=yfit)
x=x-yfit
dx=shift(x,1)-x
plot,x,dx,psym=3,/isotropic,xtitle='x!di!n',ytitle='!7D!3!di+1!n'
oplot,x,yfit
res=linfit(x,dx,/double,sigma=sigs,yfit=yfit)
alfa_hat=res(1)+1
print,'estimated alfa:',alfa_hat,'+/-',sigs(1)
print,'intercept:',res(0),'+/-',sigs(0)
end