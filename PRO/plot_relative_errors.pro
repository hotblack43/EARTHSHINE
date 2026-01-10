data=get_data('data.dat')
t=reform(data(0,*))
type=reform(data(1,*))
err1=reform(data(2,*))
err2=reform(data(3,*))
err3=reform(data(4,*))
err4=reform(data(5,*))
!P.CHARSIZE=2
idx=where(type eq 1)
plot_oi,t(idx),err1(idx),psym=-7,xtitle='Exposure time [s]',ytitle='Relative Error Contrib. [%]',xstyle=1
oplot,t(idx),err2(idx),psym=-6
oplot,t(idx),err3(idx),psym=-5
oplot,t(idx),err4(idx),psym=-4
; Legend
vstep=+.055
xyouts,/normal,0.67,0.6,'O' & plots,/normal,[0.65,0.6],[0.6,0.6],psym=-7 
xyouts,/normal,0.67,0.6-1.*vstep,'F' & plots,/normal,[0.65,0.6],[0.6-1.*vstep,0.6-1.*vstep],psym=-6 
xyouts,/normal,0.67,0.6-2.*vstep,'D' & plots,/normal,[0.65,0.6],[0.6-2.*vstep,0.6-2.*vstep],psym=-5 
xyouts,/normal,0.67,0.6-3.*vstep,'t' & plots,/normal,[0.65,0.6],[0.6-3.*vstep,0.6-3.*vstep],psym=-4 
end
;t,itype,(dIdO*delO)^2/dI2*100.0,
; (dIDF*delF)^2/dI2*100.0,
; (dIdD*delD)^2/dI2*100.0,(dIdt*delT)^2/dI2*100.0
