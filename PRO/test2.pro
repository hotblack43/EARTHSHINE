PRO test2,mean_global,ntime,nrandom,YEAR_CALIB_START,year_calib_stop,IYEARs,ntest,nlat,nlon,SST
str='Test 2 - reconstructing global temperatures, AC1 proxies, OLS'
target=mean_global

iyears=indgen(ntime)
idx=where(iyears GT YEAR_CALIB_START AND IYEARs LE year_calib_stop)

proxy=dblarr(nrandom,n_elements(idx))
proxy_all=dblarr(nrandom,ntime)
tau=dblarr(ntest)
stdd=dblarr(ntest)
steps=dblarr(ntest)
tau2=dblarr(ntest)
stdd2=dblarr(ntest)
steps2=dblarr(ntest)
for itest=0,ntest-1,1 do begin
ilat=fix(randomu(seed,nrandom)*nlat)
ilon=fix(randomu(seed,nrandom)*nlon)
fix_identical,ilat,ilon
fix_identical,ilat,ilon
ac1=0.8
imethod=1
for irandom=0,nrandom-1,1 do begin
	t=SST(ilon(irandom),ilat(irandom),*)
	pseudoseries=pseudo_t_guarantee_ac1(t,ac1,imethod,seed)
	proxy(irandom,*)=pseudoseries(idx)
	proxy_all(irandom,*)=pseudoseries(*)
endfor
;--
xx=proxy
xxx=proxy_all
yy=target
siglev=0.05
;res=regress(xx,yy(idx),yfit=yfit,/double,sigma=sigs,const=const)
res=backw_elim(xx,yy(idx),siglev,yfit=yfit,/double,sigma=sigs,const=const,varlist=vars)
print,vars
reconstructed=reform(const+xxx(vars,*)##res)
;--
!P.MULTI=[0,1,3]
calib_residuals=yy(idx)-yfit
all_residuals=yy-reconstructed
plot,calib_residuals,xtitle='Year',ytitle='Calib. Residual',charsize=2,ystyle=1,title=str
tau(itest)=a_correlate(calib_residuals,1)
steps(itest)=(1.0+tau(itest))/(1.0-tau(itest))
stdd(itest)=stddev(calib_residuals)
print,'Results for calibration period'
print,format='(1x,f8.4,1x,f8.4,1x,f8.2)',stdd(itest),tau(itest),steps(itest)
;-
plot,target,xtitle='Year',ytitle='T and T_recon',charsize=2,ystyle=1,title=str,thick=8,nsum=12
oplot,target,color=250,nsum=12
oplot,reconstructed,color=25
plots,[year_calib_start,year_calib_start],[!Y.crange]
plots,[year_calib_stop,year_calib_stop],[!Y.crange]
plot,all_residuals,xtitle='Year',ytitle='All Residual',charsize=2,ystyle=1,title=str,yrange=[-max(abs(all_residuals)),max(abs(all_residuals))]
tau2(itest)=a_correlate(all_residuals,1)
steps2(itest)=(1.0+tau2(itest))/(1.0-tau2(itest))
stdd2(itest)=stddev(all_residuals)
print,'Results for whole period'
print,format='(1x,f8.4,1x,f8.4,1x,f8.2)',stdd2(itest),tau2(itest),steps2(itest)
endfor
if (ntest gt 9) then begin
!P.MULTI=[0,3,5]
histo,tau,0,1,0.1,xtitle='!7s!3'
histo,steps,0,5,0.2,xtitle='n'
histo,stdd,0,0.4,0.025,xtitle='!7r!3'
print,'Mean AC1   :',mean(tau)
print,'Mean n_eff :',mean(steps)
print,'Mean sigma :',mean(stdd)
histo,tau2,0,1,0.1,xtitle='!7s!3'
histo,steps2,0,5,0.2,xtitle='n'
histo,stdd2,0,0.4,0.025,xtitle='!7r!3'
print,'Mean AC1 2  :',mean(tau2)
print,'Mean n_eff 2:',mean(steps2)
print,'Mean sigma 2:',mean(stdd2)
endif
return
end
