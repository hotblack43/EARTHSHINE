data=get_data('plot_threeDSdeterminations_EFM.pro
DScorr=reform(data(0,*))
DStrue=reform(data(1,*))
DSobs=reform(data(2,*))
daynum=reform(data(3,*))
daynum=daynum/3.
diff=(DStrue-DScorr)/DStrue*100.
!P.CHARSIZE=1.2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,2]
wstr='SOmething'
plot_io,yrange=[.1,20],title='Black:DSobs. Blue:DStrue. Red:DScorrected',xstyle=3,ystyle=3,daynum,DSobs,xtitle='Day',psym=7
xyouts,/data,14,1.0,'New Moon',orientation=90,charsize=2
xyouts,/data,1,1.0,'Full Moon',orientation=90,charsize=2
xyouts,/data,25,1.0,'Full Moon',orientation=90,charsize=2
!P.CHARSIZE=1.2
oplot,daynum,DStrue,color=fsc_color('blue'),psym=5
oplot,daynum,DScorr,color=fsc_color('red'),psym=6
oplot,daynum,DSobs,psym=7
xyouts,/normal,0.1,1.01,wstr,charsize=1.0
!P.CHARSIZE=1.2
;----------------------------------------
;--------
plot,xrange=[!x.crange],xstyle=3,daynum,(diff),xtitle='Day',psym=7,ytitle='% difference True vs. Corr.',yrange=[-15,5]
oplot,[!x.crange],[1,1],linestyle=2
oplot,[!x.crange],[-1,-1],linestyle=2
;print,'Mean abs err in pct: ',mean(abs(diff))
;print,'Median abs err in pct: ',median(abs(diff))
;xyouts,/normal,0.2,0.4,'Mean abs err in pct: '+string(mean(abs(diff)),format='(f5.2)')
;xyouts,/normal,0.2,0.35,'Median abs err in pct: '+string(median(abs(diff)),format='(f5.2)')
end
