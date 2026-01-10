data=get_data('table_photometry_0p303.dat')
jd1=reform(data(0,*))
phase1=reform(data(1,*))
ratio1=reform(data(2,*))
data=get_data('table_photometry_0p3.dat')
jd2=reform(data(0,*))
phase2=reform(data(1,*))
ratio2=reform(data(2,*))
plot,phase1,100.*((ratio1-ratio2)/(0.5*(ratio1+ratio2))),$
xtitle='Phase angle',ytitle='PCT. change in ratio',charsize=2,psym=7,ystyle=2,$
title='Actual imposed albedo change: 1%',xstyle=1
end
