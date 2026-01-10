!P.MULTI=[0,2,3]
!P.CHARSIZE=1.3
filters=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
for ifilter=0,4,1 do begin
filter=filters(ifilter)
file=strcompress('alfas'+filter+'.dat',/remove_all)
print,file
data=get_data(file)
jd=reform(data(0,*))
alfa=reform(data(1,*))
;idx=where(alfa gt 1.5 and alfa lt 2.0)
;data=data(*,idx)
;jd=reform(data(0,*))
;alfa=reform(data(1,*))
;
file2=strcompress('FORHANS/Nightly_Extinction_in_'+filter+'.txt',/remove_all)
data2=get_data(file2)
JDk=reform(data2(4,*))
k1=reform(data2(0,*))
k2=reform(data2(1,*))
k3=reform(data2(2,*))
nk=reform(data2(3,*))
openw,33,'jhfgcjhfg.txt'
for i=0,n_elements(JDk)-1,1 do begin
idx=where(long(jd) eq JDk(i) and nk(i) gt 3 and stddev([k1(i),k2(i),k3(i)]) lt 0.02)
;print,JDk(i),' vs ',jd(idx)
if (idx(0) ne -1) then begin
print,JDk(i),mean([k1(i),k2(i),k3(i)]),mean(alfa(idx))
printf,33,JDk(i),mean([k1(i),k2(i),k3(i)]),mean(alfa(idx))
endif
endfor
close,33
data=get_data('jhfgcjhfg.txt')
JD=reform(data(0,*))
mean_k=reform(data(1,*))
mean_alfa=reform(data(2,*))
plot,ystyle=3,xstyle=3,mean_k,mean_alfa,psym=7,xtitle='Mean extinction k',ytitle='Mean alfa',title=filter
res=ladfit(mean_k,mean_alfa)
yhat=res(0)+res(1)*mean_k
oplot,mean_k,yhat,color=fsc_color('red')
endfor
end
