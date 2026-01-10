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

!P.MULTI=[0,1,1]
print,"================================"
file='c:\rsi\work\train.txt'
hentedata,file,Y_train,X_train
file='c:\rsi\work\test.txt'
hentedata,file,Y_test,X_test
;==============================

; Compute the Euclidean distance between each point.
Z=[transpose(Y_train),X_train]
Z_test=[transpose(Y_test),X_test]
;Z=standardize(Z)

DISTANCE=DISTANCE_MEASURE((Z))

; Now compute the cluster analysis.
CLUSTERS = CLUSTER_TREE(distance, linkdistance)

;DENDRO_PLOT, Clusters, Linkdistance , orientation=1

;
 openw,13,'c:\RSI\WORK\plotme.dat'
for nclusters=2,10,1 do begin
 weights = CLUST_WTS(Z, N_CLUSTERS = nclusters)
 l=size(weights,/dimensions)
 nobservables=l(0)
ZZ=Z
 result = reform(CLUSTER(ZZ, weights, N_CLUSTERS = nclusters))
 print,"-------------------------------"
 sum_score2=0
 for icluster=0,nclusters-1,1 do begin
 	str=''

 	for k=0,nobservables-1,1 do begin
		str=str+string(mean(ZZ(k,where(result eq icluster))))+'+/-'+string(stddev(ZZ(k,where(result eq icluster))))+' | '
		score=(mean(ZZ(k,where(result eq icluster)))-weights(k,icluster))/stddev(ZZ(k,where(result eq icluster)))
		sum_score2=sum_score2+score^2
	endfor
	print,icluster,' | ',strcompress(str),'   error score:'
endfor
sum_score2=sqrt(sum_score2)
print,' Total error score:',sum_score2,' and per cluster=',sum_score2/float(nclusters)
printf,13,nclusters,sum_score2,sum_score2/float(nclusters)

endfor
close,13
data=get_data('c:\RSI\WORK\plotme.dat')
plot,reform(data(0,*)),reform(data(1,*)),xtitle='n!dcluster!n',ytitle='Z',yrange=[0,3.4],ystyle=1
oplot,reform(data(0,*)),reform(data(2,*)),linestyle=2
;=================================
; now for test data
 openw,13,'c:\RSI\WORK\plotme_test.dat'
for nclusters=2,10,1 do begin
 weights = CLUST_WTS(Z, N_CLUSTERS = nclusters)
 l=size(weights,/dimensions)
 nobservables=l(0)
ZZ=Z_test
 result = reform(CLUSTER(ZZ, weights, N_CLUSTERS = nclusters))
 print,"-------------------------------"
 sum_score2=0
 for icluster=0,nclusters-1,1 do begin
 	str=''

 	for k=0,nobservables-1,1 do begin
		str=str+string(mean(ZZ(k,where(result eq icluster))))+'+/-'+string(stddev(ZZ(k,where(result eq icluster))))+' | '
		score=(mean(ZZ(k,where(result eq icluster)))-weights(k,icluster))/stddev(ZZ(k,where(result eq icluster)))
		sum_score2=sum_score2+score^2
	endfor
	print,icluster,' | ',strcompress(str),'   error score:'
endfor
sum_score2=sqrt(sum_score2)
print,' Total error score:',sum_score2,' and per cluster=',sum_score2/float(nclusters)
printf,13,nclusters,sum_score2,sum_score2/float(nclusters)

endfor
close,13
data=get_data('c:\RSI\WORK\plotme_test.dat')
oplot,reform(data(0,*)),reform(data(1,*)),psym=-4
oplot,reform(data(0,*)),reform(data(2,*)),linestyle=2,psym=-4
; now select the optimum number of clusters
ncluster=3
DISTANCE=DISTANCE_MEASURE((Z))
; Now compute the cluster analysis.
 weights = CLUST_WTS(Z, N_CLUSTERS = ncluster)
result = reform(CLUSTER(ZZ, weights, N_CLUSTERS = ncluster))
fmt='(7(f10.2,1x))'
nsum=0
for icl=0,ncluster-1,1 do begin
	openw,11,strcompress('c:\RSI\WORK\cluster_'+string(icl+1)+'.dat',/remove_all)
	idx=where(result eq icl)
	n=n_elements(idx)
	nsum=nsum+n
	print,'There are ',n,' members in cluster no.',icl
	printf,11,format=fmt,z(*,idx)
	close,11
endfor
print,'nsum=',nsum
openw,11,strcompress('c:\RSI\WORK\weights_'+string(ncluster)+'.dat',/remove_all)
printf,11,format=fmt,weights(*,0:ncluster-1)
close,11
end