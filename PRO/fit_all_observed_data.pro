
for offset=0.,0.,1. do begin
!P.MULTI=[0,1,6]
file='all_observed_data.dat'
data=get_data(file)
jd=reform(data(0,*))-julday(1,1,2005)
am=reform(data(1,*))
mag=reform(data(2,*))
am_x_jd=reform(data(3,*))
jd_x_jd=reform(data(4,*))
sinus=shift(reform(data(5,*)),offset)
plot,jd,mag,psym=7,ystyle=1,charsize=1.5,xtitle='JD',ytitle='Observed mag'
y=mag

x=[[am],[jd],[am_x_jd],[jd_x_jd],[sinus],[am*am]]
res=REGRESS(transpose(x),y,/double,const=const,yfit=yhat,sigma=sigs)
plot,jd,yhat,psym=7,ystyle=1,charsize=1.5,xtitle='JD',ytitle='Fitted mag'
print,'m0:',const,' mag'
print,res(0),' +/- ',sigs(0),' mags/airmass'
print,res(1)*365.25,' +/- ',sigs(1)*365.25,' time-trend mags/yr'
print,res(2),' +/- ',sigs(2),' amplitude of cross term'
print,res(3),' +/- ',sigs(3),' amplitude of JD^2'
print,res(4),' +/- ',sigs(4),' amplitude of sinusoid term'
print,res(5),' +/- ',sigs(5),' amplitude of Z^2 term'
residuals=y-yhat
rmse=sqrt(total(residuals^2))/n_elements(y)
print,'RMSE:',rmse,offset
plot,jd,am,psym=7,ystyle=1,charsize=1.5,xtitle='JD',ytitle='Airmass'
plot,jd,sinus*res(4),psym=7,ystyle=1,charsize=1.5,xtitle='JD',ytitle='Sin term'
plot,am,residuals,psym=7,ystyle=1,charsize=1.5,ytitle='Residual mag',xtitle='Airmass'
plot,jd,residuals,psym=7,ystyle=1,charsize=1.5,xtitle='JD',ytitle='Residual mag'
endfor

end
