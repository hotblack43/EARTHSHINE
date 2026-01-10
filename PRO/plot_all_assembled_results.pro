labels=['Test','No trends, no cycles','Trends in both, cycles in ext.','No trends, cycles in ext.','Trend in sens., cycles in ext.','Trend in ext., cycles in ext.','Slow cycle in ext., no trends','Annual cycle in ext., no trends']
files=['assembled_results.dat','zero_drifts_zero_cycles_assembled_results.dat','imposed_trends_assembled_results.dat','zero_both_drifts_assembled_results.dat','zero_extinction_drift_assembled_results.dat','zero_sensitivity_drift_assembled_results.dat','only_slow_cycle_no_trends_assembled_results.dat','only_annual_cycle_no_trends_assembled_results.dat']
nfiles=n_elements(files)
for ifile=0,nfiles-1,1 do begin
set_plot,'ps
device,filename=strcompress('fig_'+string(ifile)+'.eps',/remove_all),/encapsulated
file=files(ifile)
data=get_data(file)
imposed_sensitivity_trend=reform(data(0,*))
observed_sensitivity_trend=reform(data(1,*))
error_sensitivity_trend=reform(data(2,*))
imposed_extinction_trend=reform(data(3,*))
observed_extinction_trend=reform(data(4,*))
error_extinction_trend=reform(data(5,*))
ploterror,imposed_sensitivity_trend-observed_sensitivity_trend,imposed_extinction_trend-observed_extinction_trend, $
error_sensitivity_trend,error_extinction_trend,title=labels(ifile)	 ,$
xtitle='!7D!3 Sensitivity trend (Actual-Determined)',ytitle='!7D!3 Extinction trend (A-D)',charsize=1.2,psym=7,$
xrange=[-0.003,0.003],yrange=[-0.003,0.003],xstyle=1,ystyle=1
;xrange=[-max(imposed_sensitivity_trend-observed_sensitivity_trend),max(imposed_sensitivity_trend-observed_sensitivity_trend)],yrange=[-max(imposed_extinction_trend-observed_extinction_trend),max(imposed_extinction_trend-observed_extinction_trend)]
plots,[!X.crange],[0,0],linestyle=2
plots,[0,0],[!Y.crange],linestyle=2
device,/close
endfor
end
