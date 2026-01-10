f='start_stop_observing_times.dat'
data=get_data(f)
jd=reform(data(0,*))
start=reform(data(1,*))
stop=reform(data(2,*))
plot,psym=-4,jd-julday(1,1,2011),24.*(stop-start),xtitle='Doy in 2010',ytitle='Observing duration (hrs)',xstyle=1
end

