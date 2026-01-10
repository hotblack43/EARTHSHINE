file='albedo.dat'
data=get_data(file)
doy=reform(data(0,*))
global=reform(data(1,*))
tropics=reform(data(2,*))
SH=reform(data(3,*))
NH=reform(data(4,*))
; select series to analyse
series=SH
;---------------------------
plot,doy,series,psym=7,ystyle=1
;sinseries=sin((doy-95)/365.25*!pi*2.)
;sinseries=sin((doy-125)/365.25*!pi*2.)
sinseries=sin((doy-105)/365.25*!pi*2.)
dummy=linfit(sinseries,series,yfit=yhat)
oplot,doy,yhat,thick=3
residuals=series-yhat
print,'S.D: of global residuals=',stddev(residuals)/mean(series)*100.0,' % of mean'
print,'S.D: of global residuals=',stddev(residuals)/stddev(series)*100.0,' % of total S.D.'
print,(stddev(residuals)^2)/(stddev(series)^2)*100.0
end