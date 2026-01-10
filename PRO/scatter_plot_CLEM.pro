spawn,"cat CLEM.profiles_fitted_results_fan_yesnoZLSL_DSBS_TEST3.txt | awk '$11 < 0.25 {print $2,$3,$4,$6,$7,$9,$10,$11,$13,$14}' > data.ytjfv"
tstr=['Alb','!7D!3Alb','!7a!3','pedestal','!7D!3x','cf','contrast','RMSE','ZL','SL']
data=get_data('data.ytjfv')
help,data
spawn,'rm data.ytjfv'
l=size(data,/dimension)
ncol=l(0)
nrows=l(1)
for icol=0,ncol-2,1 do begin
for irow=icol+1,ncol-1,1 do begin
;plot_oo,data(icol,*),data(irow,*),psym=7,xstyle=3,ystyle=3,xtitle=tstr(icol),ytitle=tstr(irow)
plot,data(icol,*),data(irow,*),psym=7,xstyle=3,ystyle=3,xtitle=tstr(icol),ytitle=tstr(irow)
print,format='(a8,a5,a8,a4,1x,f9.4)',tstr(icol),' vs. ',tstr(irow),' R= ',correlate(data(icol,*),data(irow,*))
endfor
endfor
plot_io,data(2,*),data(5,*),psym=7,xstyle=3,ystyle=3,xtitle=tstr(2),ytitle=tstr(5)
end
