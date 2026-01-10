data=get_data('CRU_vs_CERES.dat')
mm=reform(data(0,*))
dd=reform(data(1,*))
yy=reform(data(2,*))
alb_anom=reform(data(3,*))
CRU_anom=reform(data(4,*))
!P.CHARSIZE=2
!P.THICK=4
!Y.THICK=3
!x.THICK=3
plot,psym=7,CRU_anom,alb_anom,xtitle='CRU T anomaly',ytitle='CERES albedo anomaly'
end

