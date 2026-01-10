file='regression_results_Model1.dat'
openr,1,file
count=0
while not eof(1) do begin
a=0.0
asigma=0.0
b=0.0
bsigma=0.0
c=0.0
csigma=0.0
rmse=0.0
rmsedummy=0.0
readf,1,a,asigma
readf,1,b,bsigma
readf,1,c,csigma
readf,1,rmse,rmsedummy
if (count eq 1) then begin
	acoeff=a
	bcoeff=b
	ccoeff=c
	rmseval=rmse
	aerr=asigma
	berr=bsigma
	cerr=csigma
endif
if (count gt 1) then begin
	acoeff=[acoeff,a]
	bcoeff=[bcoeff,b]
	ccoeff=[ccoeff,c]
	rmseval=[rmseval,rmse]
	aerr=[aerr,asigma]
	berr=[berr,bsigma]
	cerr=[cerr,csigma]
endif
count=count+1
endwhile
close,1
!P.MULTI=[0,1,4]
!P.CHARSIZE=2
!P.thick=2
!x.thick=2
!y.thick=2
imo=indgen(n_elements(acoeff))+5
plot,imo,acoeff,ytitle='Intercept',xtitle='Month number',title=file
plot,imo,bcoeff,ytitle='Coeff to SAL',xtitle='Month number'
oploterr,imo,bcoeff,berr
plot,imo,ccoeff,ytitle='Coeff to CFC',xtitle='Month number'
oploterr,imo,ccoeff,cerr
plot,imo,rmseval,ytitle='RMSE',xtitle='Month number'
; plot modlu 12
plot,imo mod 12,acoeff,ytitle='Intercept',xtitle='Month number',title=file,psym=4
plot,imo mod 12,bcoeff,ytitle='Coeff to SAL',xtitle='Month number',psym=4
oploterr,imo mod 12,bcoeff,berr
plot,imo mod 12,ccoeff,ytitle='Coeff to CFC',xtitle='Month number',psym=4
oploterr,imo mod 12,ccoeff,cerr
plot,imo mod 12,rmseval,ytitle='RMSE',xtitle='Month number',psym=4
end
