data=get_data('BBSO_lin_log_DCR_albedos.dat')
jd=reform(data(0,*))
dcr=reform(data(1,*))
d_dcr=reform(data(2,*))
lin=reform(data(3,*))
d_lin=reform(data(4,*))
log=reform(data(5,*))
d_log=reform(data(6,*))
ph=abs(reform(data(7,*)))
k=reform(data(8,*))
pct=(lin-log)/log*100.
; this was wrong d_pct=d_lin+d_log	; conservative case!
;
plot_io,yrange=[0.01,100],xstyle=3,ystyle=3,ph,pct,psym=7,xtitle='Lunar phase [FM=0]',ytitle='Lin/Log difference [%]'
oploterr,ph,pct,d_pct
end
