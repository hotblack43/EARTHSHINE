
PRO COCHRANEURCUTT,ARRAY
;
; Will perform the CO algorithm on an array ARRAY, using the first column as the 'y' vector
; and the rest as 'x' vectors.
; Will return the coefficients b in Y = b0 + b1*X1 + b2*X2+... after the CO transformation
;
; Repack the data in ARRAY;
l=size(array,/dimensions)
ncol=fix(l(0))
fmt_str=strcompress('(a,'+string(ncol+1)+'(1x,f11.3))',/remove_all)
nrow=l(1)
Y=reform(ARRAY(0,*))
X=fltarr(ncol-1,nrow)
for i=1,ncol-1,1 do x(i-1,*)=reform(array(i,*))
;
; Step 1. Do OLS and get residuals
;
res=regress(x,y,yfit=yfit,const=const)
print,'Step 1 coefficients:',format=fmt_str,const,res
residuals=y-Yfit
;
; Step 2, estimate rho from AR model of residuals
;
if_rhoestmethod=1
if (if_rhoestmethod eq 1) then begin
	rho=a_correlate(residuals,1)
endif
if (if_rhoestmethod eq 2) then begin
	res=linfit(shift(residuals,-1),residuals)
	rho=res(1)
endif
print,'Rho estimate:',rho
;
; Step 3. New variables
;
k=1.0-rho
Ystar=Y-replicate(rho,nrow)*shift(Y,-1)
Xstar=X
for i=1,ncol-1,1 do xstar(i-1,*)=xstar(i-1,*)-replicate(rho,nrow)*shift(transpose(x(i-1,*)),-1)
;
; Step 4, Regress on new variables
;

	res=regress(xstar,ystar-mean(ystar),yfit=yfit,const=const)
	residuals=(ystar-mean(ystar))-Yfit
	const=const/k
   print,'Step 4 coefficients:',format=fmt_str,const,res
;
; Step 5
;
if_rhoestmethod=1
if (if_rhoestmethod eq 1) then begin
	rho=a_correlate(residuals,1)
endif
if (if_rhoestmethod eq 2) then begin
	res=linfit(shift(residuals,-1),residuals)
	rho=res(1)
endif
print,'Rho estimate:',rho
return
end
