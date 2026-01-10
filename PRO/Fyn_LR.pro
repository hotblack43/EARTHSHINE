PRO fixit,list
print,n_elements(list)
list=list(sort(list))
list=list(uniq(list))
print,n_elements(list)
return
end

PRO hentedata,file,Y,X
data=read_ascii(file,data_start=1)
;
X=data.field01(4:9,*)
Y=reform(data.field01(0,*))
print,'There were ',n_elements(y),' data points'
if_mix=0
if (if_mix eq 1) then begin
; cross products of variables
X=[X,X(0,*)*X(1,*)]
endif
return
end

PRO testsuite,y1,y2,text1,text2,subtit
!P.subtitle=subtit
residuals=y1-y2
std=stddev(residuals)
print,'Results from '+text1+':'
print,'mean residual=',mean(residuals)
print,'residuals std=',std
R=correlate(y1,y2)
print,'R=',R, ' R^2=',R^2
plot,y1/1e6,y2/1e6,xtitle='Pris (MKR)',ytitle='Model pris (MKR)',psym=4,title=text2+' data',xrange=[0,8],yrange=[0,8]
xyouts,1.0,7,strcompress('STD (MKR):'+strmid(string(fix(std/1e6*1000)/1000.),0,10)+'. R='+strmid(string(fix(R*1000)/1000.),0,10)),charsize=1
print,"================================"
return
end

!P.MULTI=[0,2,2]
print,"================================"
file='C:\Programmer\r\R-2.2.1\Work\train_noheader.txt'
varnames=['Areal','Værelser','Plan','Kælder','Grund','Byggeår','A*B']
hentedata,file,Y_train,X_train
file='C:\Programmer\r\R-2.2.1\Work\test_noheader.txt'
varnames=['Areal','Værelser','Plan','Kælder','Grund','Byggeår','A*B']
hentedata,file,Y_test,X_test
;==============================
subtitle=' '
; First the full set of predictors
res_train=regress(x_train,y_train,yfit=yfit,/double,sigma=sigs,const=const_train)
testsuite,y_train,yfit,'full fit træning','Trænings',subtitle
;------------------------------
; predicting test from training fit
test_predicted=const_train+res_train#X_test
testsuite,y_test,test_predicted,'full fit test data','Test',subtitle
;======================================
;now apply backwards elimination
; first train
res_test=backw_elim(x_train,y_train,0.05,yfit=yfit,/double,sigma=sigs,const=const_train,varlist=varlist)

for k=0,n_elements(varlist)-1,1 do begin
	print,varnames(varlist(k)),res_test(k),' +/- ',sigs(k)
	subtitle=subtitle+' '+varnames(varlist(k))
endfor
subtitle=strcompress(subtitle)
testsuite,y_train,yfit,'trænings data, BE','BE: Trænings',subtitle
;------------------------------
; then predict test from train results
test_predicted=const_train+res_train(0,varlist)#X_test(varlist,*)
testsuite,y_test,test_predicted,'test data, BE','BE: Test',subtitle
;================================
end