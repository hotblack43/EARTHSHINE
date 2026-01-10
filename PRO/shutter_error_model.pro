AC=0.3	; rise time of shutter in msec
AC_error=0.02	; fractional error on AC
x=findgen(10000)+1.0	; exposure time in msec
error_exp_time=AC_error*AC
fractional_error_exp_time=error_exp_time/(AC/2.+x)
plot_oo,x,fractional_error_exp_time,charsize=2,ystyle=1,yrange=[1e-5,1e-2] ,$
xtitle='Exposure time (msec)',ytitle='Fractional error on exp. time',xstyle=1,title='CS25 shutter'
plots,[10,1000],[1e-3,1e-3],linestyle=2
fractional_error_filter=0.001
total_fractional_error=sqrt(fractional_error_filter^2+ fractional_error_exp_time^2)
oplot,x,total_fractional_error,thick=3
end