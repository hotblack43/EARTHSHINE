;--------------------------------------------------
limes=0.2
file='albedo_ZLSL_noZLSL.dat'
data=get_data(file)
err_albedo_ZLSL=reform(data(2,*))
err_albedo_noZLSL=reform(data(4,*))
idx=where(err_albedo_ZLSL lt limes and err_albedo_noZLSL lt limes)
data=data(*,idx)
JD=reform(data(0,*))
albedo_ZLSL=reform(data(1,*))
albedo_noZLSL=reform(data(3,*))
err_albedo_ZLSL=reform(data(2,*))
err_albedo_noZLSL=reform(data(4,*))
dA=albedo_noZLSL-albedo_ZLSL
!Y.STYLE=3
pct=dA/albedo_ZLSL*100.
histo,pct,-1.0,1.5,.03,xtitle='!7D!3 Albedo [%]',/abs
oplot,[0,0],[!Y.crange],linestyle=1
oplot,[median(pct),median(pct)],[!Y.crange],linestyle=2
print,limes,n_elements(idx),min(pct),max(pct)
print,'Median change: ',median(pct)
idx=float(where(pct gt 0))
print,'% with positive change: ',float(n_elements(idx))/n_elements(pct)*100.

end
