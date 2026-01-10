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
X=data.field01(3:9,*)
Y=reform(data.field01(0,*))
return
end


!P.MULTI=[0,1,1]
print,"================================"
file='c:\rsi\work\train_test.txt'
hentedata,file,Y_train,X_train
;==============================
Z=[transpose(Y_train),X_train]

weights = CLUST_WTS(Z, N_CLUSTERS = 3)

result = reform(CLUSTER(Z, weights, N_CLUSTERS = 3))
for icl=0,2,1 do begin

idx=where(result eq icl)
fmt='(8(i10,1x))'
str=strcompress('c:\RSI\WORK\Cluster_'+string(fix(icl))+'.dat',/remove_all)
openw,11,str
print,str
for i=0,n_elements(idx)-1,1 do begin
printf,11,format=fmt,z(*,idx(i))
endfor
close,11
endfor
end