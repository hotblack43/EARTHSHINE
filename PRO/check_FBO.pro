err=get_data('Tobsstdofthemean.txt')
x=get_data('Tobs.txt')
x=reform(x(0,*))
y_arr=get_data('Tbias.txt')
;
help
;
for i=0,10,1 do begin
print,'------------------------------------------'
print,' Set #: ',i
y=reform(y_arr(i,*))
;y=randomu(seed,n_elements(y))
res=linfit(yfit=yhat,x,y,sigma=sigs,/double,chisqr=chi2,prob=p,measure_errors=err)
plot,x,y,psym=7
oplot,x,yhat
print,'P=',p,' Chi2= ',chi2
print,' coeffs: ',res
print,'   +/- : ',sigs,' Z_slope: ',abs(res(1))/sigs(1)
endfor
print,'------------------------------------------'
end
