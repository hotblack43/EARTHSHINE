file='BminusVishorisontalonDS.dat'
data=get_data(file)
jd=reform(data(0,*))
phase=reform(data(1,*))
alfa=reform(data(2,*))
BmV=reform(data(3,*))
BmVerr_3s_lo=reform(data(4,*))
BmVerr_3s_hi=reform(data(5,*))
BmVerr_1s_lo=reform(data(6,*))
BmVerr_1s_hi=reform(data(7,*))
idx=where(phase lt 0 and BmVerr_1s_lo lt 0.05)
ytit_str='(B-V)!dBS-DS!n'
xtit_str=' Lunar phase [FM=0]'
!P.charsize=1.7
!P.thick=3
!x.thick=2
!y.thick=2
!P.MULTI=[0,1,2]
plot,ytitle=ytit_str,xtitle=xtit_str,xrange=[min(phase(idx)),max(phase(idx))],xstyle=3,phase(idx),BmV(idx),psym=7
oploterr,phase(idx),BmV(idx),BmVerr_1s_hi(idx)
res=ladfit(phase(idx),BmV(idx))
yhat=res(0)+res(1)*phase(idx)
;
ytit_str='(B-V)!dBS-DS!n'
xtit_str=' !7a!3'
plot,ytitle=ytit_str,xtitle=xtit_str,xstyle=3,alfa(idx),BmV(idx),psym=7
end
