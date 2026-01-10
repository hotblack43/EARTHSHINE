openw,44,'offset.dat'
for offset=-0.,0.,0.5 do begin	; days
print,'offset of sinusoid:',offset,' days.'
!P.MULTI=[0,1,5]
file='all_observed_data.dat'
data=get_data(file)
jd=reform(data(0,*))
am=reform(data(1,*))
mag=reform(data(2,*))
plot,jd,mag,psym=7,ystyle=1,charsize=1.5,xtitle='JD',ytitle='Observed mag'
y=mag
sinusoid=sin((jd-offset)/365.25d0*!pi*2.)
x=[[am],[jd],[sinusoid]]
res=REGRESS(transpose(x),y,/double,const=const,yfit=yhat,sigma=sigs)
print,'m0:',const,' mag'
print,res(0),' +/- ',sigs(0),' mags/airmass'
print,res(1),' +/- ',sigs(1),' time-trend mags/day',res(1)*365.25,' time-trend mags/year'
print,res(2),' +/- ',sigs(2),' amplitude of sinusoid'
res=co_REGRESS(transpose(x),y,/double,const=const,yfit=yhat,sigma=sigs)
print,'m0:',const,' mag'
print,res(0),' +/- ',sigs(0),' mags/airmass'
print,res(1),' +/- ',sigs(1),' time-trend mags/day',res(1)*365.25,' time-trend mags/year'
print,res(2),' +/- ',sigs(2),' amplitude of sinusoid'
residuals=y-yhat
rmse=sqrt(total(residuals^2))/n_elements(y)
print,'RMSE:',rmse
plot,jd,residuals,psym=7,ystyle=1,charsize=1.5,xtitle='JD',ytitle='Residual mag'
plot,jd,am,psym=7,ystyle=1,charsize=1.5,xtitle='JD',ytitle='Airmass'
plot,jd,sinusoid*res(2),psym=7,ystyle=1,charsize=1.5,xtitle='JD',ytitle='Sinusoidal annual term'
plot,am,residuals,psym=7,ystyle=1,charsize=1.5,ytitle='Residual mag',xtitle='Airmass'
printf,44,offset,RMSE
endfor
close,44
end
