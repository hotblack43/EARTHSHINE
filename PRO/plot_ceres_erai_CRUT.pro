data=get_data('ceres_erai_CRUT.dat')
mm=reform(data(0,*))
yy=reform(data(1,*))
ceres_anom=reform(data(2,*))
erai_anom=reform(data(3,*))
CRUT_anom=reform(data(4,*))
; relative
ceres_anom=ceres_anom/0.3*100.
erai_anom=erai_anom/0.3*100.
!P.CHARSIZE=1.7
!P.CHARTHICK=2
!P.THICK=3
!x.THICK=3
!y.THICK=3
plot,xrange=[-2.,2.],yrange=[-2.,2.],/isotropic,ceres_anom,erai_anom,psym=7,xtitle='CERES albedo anom [%]',ytitle='ERAI albedo anom [%]',title='Monthly means'
plots,[!x.crange],[!y.crange],linestyle=2
res2=ladfit(ceres_anom,erai_anom)
yhat=res2(0)+res2(1)*ceres_anom
oplot,ceres_anom,yhat,color=fsc_color('red')
res=linfit(ceres_anom,erai_anom,sigma=sigs)
yhat=res(0)+res(1)*ceres_anom
oplot,ceres_anom,yhat,color=fsc_color('blue')
print,'Robust Slope: ',res2(1)
print,'OLS    Slope: ',res(1),' +/- ',sigs(1)
r=correlate(ceres_anom,erai_anom)
print,'R: ',r
xyouts,/normal,0.3,0.55,'R = '+string(r,format='(f4.2)')
r=correlate(ceres_anom,CRUT_anom)
print,'R(CERES,CRU T): ',r
r=correlate(erai_anom,CRUT_anom)
print,'R(ERAI,CRU T): ',r
end
