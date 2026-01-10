PRO hentedata,file,Y,X
data=read_ascii(file,data_start=1)
;
X=data.field1(2:7,*)
Y=reform(data.field1(0,*))
;Y=reform(data.field01(0,*))
;idx=where(Y lt 3.0e6)
;X=data.field01(4:9,idx)
;Y=Y(idx)

return
end

print,"================================"
file='c:\RSI\WORK\Cluster_2.dat'
varnames=['Areal','Værelser','Plan','Kælder','Grund','Byggeår']
hentedata,file,Y_train,X_train
file='c:\RSI\WORK\test_Cluster_2.dat'
varnames=['Areal','Værelser','Plan','Kælder','Grund','Byggeår']
hentedata,file,Y_test,X_test
;==============================
l=size(x_train,/dimensions)
n_pat=l(1)
n_in=l(0)
n_hid=9
n_out=1


; noramlize x and y
for icol=0,n_in-1,1 do begin
X_train(icol,*)=(X_train(icol,*)-min(X_train(icol,*)))/(max(X_train(icol,*))-min(X_train(icol,*)))
endfor
train_set=X_train
;
minY=min(Y_train)
rangeY=max(Y_train)-min(Y_train)
classes=fix((Y_train-minY)/rangeY*10)
TRAIN_NNET, n_pat, n_in, n_hid, n_out, $
		train_set, classes, bias_hid, $
		w_hid, bias_out, w_out,outfile='C:\RSI\WORK\outfile'

end