PRO COCHRANEURCUTT,ARRAY,const,res,yfit,BOOT_CO_sigs
BOOT_CO_sigs=-911.
niter=100
;
; Will perform the CO algorithm on an array ARRAY, using the first column as the 'y' vector
; and the rest as 'x' vectors.
; Will return the coefficients b in Y = b0 + b1*X1 + b2*X2+... after the CO transformation
;
; Repack the data in ARRAY;
l=size(array,/dimensions)
ncol=fix(l(0))
nVAR=ncol-1
fmt_str=strcompress('(a,'+string(ncol+1)+'(1x,f12.5))',/remove_all)
fmt_str2=strcompress('(a,'+string(ncol+2)+'(1x,f12.5))',/remove_all)
nrow=l(1)
Y=reform(ARRAY(0,*))
X=array(1:ncol-1,*)
;
iter=0
old_rho=314
old_res=dblarr(ncol-1)*0.0+1e33
drho=1e6
dres=replicate(1e6,nVar)
convergence_limit=1.0d-7
while (max([drho,dres]) gt convergence_limit and iter lt niter) do begin
print,'CO iteration # ',iter
;
; Step 1. Do OLS and get residuals
;
if (iter eq 0) then begin
    res=regress(x,y,yfit=yfit,const=const,/double)
    residuals=y-Yfit
    OLSresiduals=residuals
    OLSfit=Yfit
endif
if (iter gt 0) then begin
    yfit=yfit*0.0
    for icol=0,ncol-1-1,1 do yfit=yfit+res(icol)*x(icol,*)
    yfit=reform(yfit)
    yfit=yfit+const
    residuals=y-Yfit
endif
;
; Step 2, estimate rho from AR model of residuals
;
    shifted_residuals=shift(residuals,1)
    shifted_residuals(0)=residuals(0)
    res=linfit(shifted_residuals,residuals)
    rho=res(1)
;
; Step 3. New variables
;
k=1.0-rho
shifted_Y=shift(Y,1)
shifted_Y(0)=Y(0)
Ystar=Y-rho*shifted_Y
Xstar=X

for i=1,ncol-1,1 do begin
    shifted_X=shift(transpose(x(i-1,*)),1)
    shifted_X(0)=x(i-1,0)
    xstar(i-1,*)=xstar(i-1,*)-rho*shifted_X
endfor
;
; Step 4, Regress on new variables
;

;   res=regress(xstar,ystar-mean(ystar),yfit=yfit,const=const,/double)
    res=regress(xstar,ystar,yfit=yfit,const=const,/double)
;             BOOT_2VAR,xstar,ystar,BOOT_CO_sigs
    residuals=ystar-Yfit
    const=const/k
;
; Step 5
;
drho=abs((rho-old_rho)/old_rho)
if (nVar eq 1) then dres=abs((old_res-res)/old_res)
if (nVar gt 1) then for ivar=0,nvar-1,1 do dres(ivar)=abs((old_res(ivar)-res(ivar))/old_res(ivar))
old_res=res
old_rho=rho
iter=iter+1
endwhile
yfit=yfit*0.0
    for icol=0,ncol-1-1,1 do yfit=yfit+res(icol)*x(icol,*)
    yfit=reform(yfit)
    yfit=yfit+const
a_c=a_correlate(residuals,1)
print,format='(a,f10.3,a,f10.3)','CO: AC1 residuals:',a_c,' tau_d=',(1.0+a_c)/(1.0-a_c)
print,format='(a,f10.3,a,f10.3,a,f10.3)','CO R=',correlate(y,yfit),' SS:',total((y-yfit)^2),' rho=',rho
print,format='(a,4(1x,f10.3))',' CO const,coeff:',const,res
print,format='(a,4(1x,f10.3))',' CO    bootstrap      sigs:',BOOT_CO_sigs

print,'======================================================================='

return
end
