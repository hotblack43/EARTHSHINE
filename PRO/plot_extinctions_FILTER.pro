!P.MULTI=[0,2,3]
!P.CHARSIZE=2.1
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.CHARTHICK=2
filters=['B','V','VE1','VE2','IRCUT']
for ifilter=0,4,1 do begin
filter=filters(ifilter)
file=strcompress('extinctions_'+filter+'.dat',/remove_all)
data=get_data(file)
k=reform(data(0,*))
sig=reform(data(1,*))
jd=reform(data(2,*))
idx=where(sig/k*100. lt 10. and k gt 0)
data=data(*,idx)
k=reform(data(0,*))
sig=reform(data(1,*))
jd=reform(data(2,*))
print,min(jd)
jd=jd-julday(1,1,2011)
plot,ystyle=3,xrange=[250,550],yrange=[0,0.25],psym=7,jd,k,xtitle='Day since 1.1.2011',ytitle='k!d'+filter+'!n'
plots,[365,365],[!Y.crange],linestyle=2
oploterr,jd,k,sig
endfor
end
