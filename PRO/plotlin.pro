filters=['IRCUT','VE2','V','B','VE1']
for ifilter=0,4,1 do begin
filter=filters(ifilter)
adu=1.0
adu=3.78
data=get_data(strcompress('variance_level'+filter+'.dat',/remove_all))
level=reform(data(0,*))
variance=reform(data(1,*))
exposure=reform(data(2,*))
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.CHARSIZE=1.1
!P.MULTI=[0,2,3]
;!P.MULTI=[0,1,4]
level=level/adu
variance=variance/adu
idx=sort(level)
level=level(idx)
variance=variance(idx)
exposure=exposure(idx)

maxrange=55000L;min([66000,max([max(level),max(variance)])])
;..............
plot,/isotropic,xtitle='Counts',ytitle='Variance',level,variance,psym=7,xrange=[0,maxrange],yrange=[0,maxrange],xstyle=3,ystyle=3,title=filter
idx=where(level le 55000L and level ge 1000L)
level=level(idx)
variance=variance(idx)
exposure=exposure(idx)
res=linfit(level,variance,/double,yfit=yhat)
print,'Linfit: ',res
oplot,level,yhat
res=POLY_FIT(level,variance, 2,/double,yfit=parabola,yband=deltay)
print,'Parabolic coffecicients: ',res
xyouts,/normal,0.1,0.97,'2nd order fit coeffs:'
xyouts,/normal,0.1,0.95,'c0: '+string(res(0),format='(g14.8)')
xyouts,/normal,0.1,0.93,'c1: '+string(res(1),format='(g14.8)')
xyouts,/normal,0.1,0.91,'c2: '+string(res(2),format='(g14.8)')
oplot,level,parabola,color=fsc_color('red')
plots,[0,maxrange],[0,maxrange],linestyle=2
;..............
plot,xtitle='Counts',ytitle='Variance Residuals',level,variance-yhat,psym=4,xrange=[0,maxrange],xstyle=3,ystyle=3,title=filter
oplot,[!X.crange],[0,0],linestyle=1
oplot,level,variance-parabola,psym=4,color=fsc_color('red')
;..............
plot,level,exposure,psym=7,ytitle='Exposure time [s]',xtitle='Counts',xrange=[0,maxrange],xstyle=3,ystyle=3
res=linfit(level,exposure,/double,yfit=yhat2)
oplot,level,yhat2,color=fsc_color('red')
res2=POLY_FIT(level,exposure, 2,/double,yfit=parabola2,yband=deltay2)
xyouts,/normal,0.1,0.63,'2nd order fit coeffs:'
xyouts,/normal,0.1,0.61,'c0: '+string(res2(0),format='(g14.8)')
xyouts,/normal,0.1,0.59,'c1: '+string(res2(1),format='(g14.8)')
xyouts,/normal,0.1,0.57,'c2: '+string(res2(2),format='(g14.8)')
;..............
plot,level,exposure-yhat2,psym=7,ytitle='Residual Exp time',xtitle='Counts',xrange=[0,maxrange],xstyle=3,ystyle=3
oplot,level,exposure-parabola2,psym=7,color=fsc_color('red')
;..............
plot,xstyle=3,level,deltay/level*100.,/ylog,xtitle='Counts',ytitle='Pct y uncertainty (2nd roder)'
oplot,[!X.CRANGE],[0.1,0.1],linestyle=2
;..............
a=get_kbrd()
endfor
end
