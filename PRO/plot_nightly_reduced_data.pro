data=get_data('nightly_reduced.data')
jd=reform(data(0,*))*1.0d0
mag0=reform(data(1,*))*1.0d0
k=reform(data(2,*))*1.0d0
!P.MULTI=[0,1,2]
plot,jd,mag0,xtitle='JD',ytitle='m!d0!n',charsize=1.5,ystyle=1,xstyle=1,psym=2
res=linfit(jd,mag0,/double,yfit=yhat,sigma=sigs)
oplot,jd,yhat
print,format='(a,f10.6,a,f10.6,a)','slope of m0 is   :',res(1)*365.25,' +/- ',sigs(1)*365.25,' magnitudes per year.'
print,format='(a,f10.6,a,f10.6,a)','slope of f(m0) is:',-res(1)*365.25/1.08574,' +/- ',sigs(1)*365.25/1.08574,'  flux change per year.'
plot,jd,k,xtitle='JD',ytitle='extinction coefficient',charsize=1.5,ystyle=1,xstyle=1,psym=2
; estiamtethe slope of k vs jd
idx=where(jd le jd(0)+365.25)
x1=mean(jd(idx))
y1=mean(k(idx))
idx=where(jd le jd(n_elements(jd)-1)-365.25)
x2=mean(jd(idx))
y2=mean(k(idx))
slope=(y2-y1)/(x2-x1)
print,'slope of k is   :',slope*365.25,' magnitudes per airmass per year.'
oplot,[jd(0),jd(n_elements(jd)-1)],[k(0),k(0)+slope*(jd(n_elements(jd)-1)-jd(0))],thick=2
end
