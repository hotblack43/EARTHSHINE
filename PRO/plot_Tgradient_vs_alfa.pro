file='Tgradient_vs_alfa.dat'
file='Tgradient_vs_alfa_VE2.dat'
data=get_data(file)
jd=reform(data(0,*))
alfa=reform(data(1,*))
Tgradient=reform(data(2,*))
rel_hum=reform(data(3,*))
pressure=reform(data(4,*))
wind_speed=reform(data(5,*))
;
;!P.MULTI=[0,1,1]
!P.MULTI=[0,2,3]
!P.CHARSIZE=2
!X.THICK=3
!P.THICK=3
!Y.THICK=3
plot,xrange=[1.5,1.76],xstyle=3,ystyle=3,alfa,Tgradient,psym=1,xtitle='!7a!3',ytitle='Vertical T gradient'
oplot,[median(alfa),median(alfa)],[!Y.crange],linestyle=2
;plot,xstyle=3,ystyle=3,alfa,rel_hum,psym=1,xtitle='!7a!3',ytitle='Relative Humidity [%]'
;oplot,[median(alfa),median(alfa)],[!Y.crange],linestyle=2
plot,xrange=[1.5,1.76],xstyle=3,ystyle=3,alfa,rel_hum,psym=1,xtitle='!7a!3',ytitle='Relative Humidity [%]'
oplot,[median(alfa),median(alfa)],[!Y.crange],linestyle=2
plot,xrange=[1.5,1.76],xstyle=3,ystyle=3,alfa,pressure,psym=1,xtitle='!7a!3',ytitle='Pressure'
oplot,[median(alfa),median(alfa)],[!Y.crange],linestyle=2
plot,xrange=[1.5,1.76],xstyle=3,ystyle=3,alfa,wind_speed,psym=1,xtitle='!7a!3',ytitle='Wind Speed'
oplot,[median(alfa),median(alfa)],[!Y.crange],linestyle=2
end
