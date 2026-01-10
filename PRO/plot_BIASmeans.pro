!P.CHARSIZE=3
!P.CHARTHICK=2
data=get_data('BIASmeans.dat')
jd=reform(data(0,*))
meanbias=reform(data(1,*))
Temp=reform(data(2,*))
exptime=reform(data(3,*))
delta=reform(data(4,*))
;
idx=where(abs(delta) gt 0.00002 and abs(delta) lt 1.0/24./60. and meanbias  $
gt 390 and meanbias lt 401 and exptime lt 200)
data=data(*,idx)
jd=reform(data(0,*))
meanbias=reform(data(1,*))
Temp=reform(data(2,*))
exptime=reform(data(3,*))
delta=reform(data(4,*))
!P.MULTI=[0,1,3]
plot,jd,meanbias,psym=7,ystyle=3,xstyle=3,xtitle='JD',ytitle='Mean bias'
COEFF = ROBUST_LINEFIT( jd, meanbias, YFIT, SIG, COEF_SIG)
oplot,jd,yfit,color=fsc_color('red')
print,'---------------------------------------------------'
print,'mean bias vs JD           :',coeff
print,'Units                     : counts/day'
print,'Uncertainties             :',coef_sig
print,'Z on slope                :',abs(coeff(1))/coef_sig(1)
print,'---------------------------------------------------'
;...................
plot_oi,exptime,meanbias,psym=7,ystyle=3,xstyle=3,xtitle='Exposure time [s]',ytitle='Mean bias'
COEFF = ROBUST_LINEFIT( exptime, meanbias, YFIT, SIG, COEF_SIG)
oplot,exptime,yfit,color=fsc_color('red')
print,'mean bias vs exposure time:',coeff
print,'Units                     : counts/s'
print,'Uncertainties             :',coef_sig
print,'Z on slope                :',abs(coeff(1))/coef_sig(1)
print,'---------------------------------------------------'
;...................
plot,abs(delta),meanbias,psym=7,ytitle='Mean bias',xtitle='!7D!3'
COEFF = ROBUST_LINEFIT( abs(delta),meanbias, YFIT, SIG, COEF_SIG)
oplot,abs(delta),yfit,color=fsc_color('red')
print,'mean bias vs abs(delta)   :',coeff
print,'Units                     : counts/day'
print,'Uncertainties             :',coef_sig
print,'Z on slope                :',abs(coeff(1))/coef_sig(1)
print,'---------------------------------------------------'
end
