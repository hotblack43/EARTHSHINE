data=get_data('darkies.dat')
jd=reform(data(0,*))
medi=reform(data(1,*))
expt=reform(data(2,*))
T=reform(data(3,*))
!P.MULTI=[0,1,2]
!P.CHARSIZE=2
!P.CHARTHICK=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
plot,yrange=[380,520],xstyle=3,ystyle=3,jd-min(jd),medi,$
xtitle='day',ytitle='Median bias values',psym=2
idx=where(T ne -999)
plot,xstyle=3,ystyle=3,T(idx),medi(idx),$
ytitle='Median bias values',xtitle='CCD temperature [deg F]',psym=2
x=findgen(100)-80
oplot,x,401+0.0675*x,color=fsc_color('red')
end

