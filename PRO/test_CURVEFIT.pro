PRO peters, X, pars, F 
print,pars
a=pars(0)
b=pars(1)
c=pars(2)
d=pars(3)
f=a+b*x+c*x^d
return 
END 

PRO make_test_data,n
common data,a,b,c,d
x=randomu(seed,n)
xnoise=randomn(seed,n)/50.
ynoise=randomn(seed,n)/10.
xnoise=xnoise*0.0
a=1.0
b=2.0
c=8.0
d=2.75
y=a+b*x+c*x^d
; add noise to x and y
x=x+xnoise
y=y+ynoise
openw,33,'Data.in'
for i=0,n-1,1 do begin
printf,33,x(i),y(i),stddev(ynoise)
endfor
close,33
plot,x,y,psym=7
return
end


common data,a,b,c,d
n=100
make_test_data,n
inputpars=[1,b,c,d]
data=get_data('Data.in')
x=reform(data(0,*))
idx=sort(x)
x=x(idx)
y=reform(data(1,*))
y=y(idx)
weights=1.0/reform(data(2,*))^2
pars=randomu(seed,4)
afit=[1,1,1,1]
chi2tol=1e-5
;

Result = CURVEFIT( X, Y, Weights, pars , Sigma, /DOUBLE, FITA=afit, FUNCTION_NAME='peters', /NODERIVATIVE, TOL=chi2tol, CHISQ=chi2, STATUS=stat, ITMAX=1000) 
for i=0,3,1 do begin
print,pars(i),' +/- ',sigma(i), ' actual: ',inputpars(i)
endfor
print,' Reduced CHI²: ',chi2
print,' Expected reduced CHI²: ', float(n)/(n-n_elements(pars)-1)
if (stat ne 0) then print,'Iteration was a failure.'
oplot,x,result,color=fsc_color('red')
end
