PRO hentedata,file,Y,X
data=read_ascii(file)
pris=data.field01(0,*)
brutto=data.field01(1,*)
netto=data.field01(2,*)
udebtaling=data.field01(3,*)
areal=data.field01(4,*)			; 0
vaerelser=data.field01(5,*)		; 1
plan=data.field01(6,*)			;2
kaelder=data.field01(7,*)		;3
grund=data.field01(8,*)			;4
byggeår=data.field01(9,*)		;5
;
X=data.field01(4:9,*)
Y=reform(data.field01(0,*))
return
end

PRO testsuite,y1,y2,text1,text2
residuals=y1-y2
std=stddev(residuals)
print,'Results from '+text1+':'
print,'mean residual=',mean(residuals)
print,'residuals std=',std
R=correlate(y1,y2)
print,'R=',R, ' R^2=',R^2
plot,y1/1e6,y2/1e6,xtitle='Pris (MKR)',ytitle='Model pris (MKR)',psym=4,title=text2+' data',xrange=[0,8],yrange=[0,8]
xyouts,2.5,4.5,strcompress('STD (MKR):'+strmid(string(fix(std/1e6*1000)/1000.),0,10))+' R='+strmid(string(fix(R*1000)/1000.),0,10),charsize=1
print,"================================"
return
end

!P.MULTI=[0,1,2]
print,"================================"
file='c:\rsi\work\train.txt'
hentedata,file,Y_train,X_train
file='c:\rsi\work\test.txt'
hentedata,file,Y_test,X_test
;==============================
; First the full set of predictors
res_train=regress(x_train,y_train,yfit=yfit,/double,sigma=sigs,const=const_train)
testsuite,y_train,yfit,'full fit træning','Trænings'
;------------------------------
; predicting test from training fit
test_predicted=const_train+res_train#X_test
testsuite,y_test,test_predicted,'full fit test data','Test'
;======================================
;now apply backwards elimination
; first train
res_test=backw_elim(x_train,y_train,0.01,yfit=yfit,/double,sigma=sigs,const=const_train,varlist=varlist)
print,'Varlist=',varlist
testsuite,y_train,yfit,'trænings data, BE','BE: Træning'
;------------------------------
; then predict test from train results
test_predicted=const_train+res_train(0,varlist)#X_test(varlist,*)
testsuite,y_test,test_predicted,'test data, BE','BE: Test'
;================================
; now make logarithmic transform of y

end