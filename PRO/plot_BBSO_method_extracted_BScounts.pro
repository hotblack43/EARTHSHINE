!P.MULTI=[0,2,3]
filters=['_B_','_V_','_VE2_','_IRCUT_','_VE1_']
JDstr='2456073'
 print,'Looking for jd ',JDstr
filename='BBSO_method_extracted_BScounts_'+JDstr+'.dat'

for ifilter=0,n_elements(filters)-1,1 do begin
str="grep "+filters(ifilter)+" "+filename+" | awk '{print $1,$2,$3,$4}' > aha.dat" 
spawn,str
if (file_test('aha.dat',/zero_length) ne 1) then begin
data=get_data('aha.dat')
type=reform(data(0,*))
JD=reform(data(1,*))
DS=reform(data(2,*))
BS=reform(data(3,*))
ratio=DS/BS/(mean(DS/BS))*0.3
idx=where(type eq 0)
plot,xstyle=3,psym=-7,xrange=[0.73,0.9],xtitle='fractional day',yrange=[min(ratio),max(ratio)],ystyle=3,jd(idx) mod 1,ratio(idx),ytitle='DS/BS',title=filters(ifilter)
jdx=where(type eq 1)
oplot,psym=-7,jd(jdx) mod 1,ratio(jdx),color=fsc_color('red')
; Now get data from the forward fitting method
 str2="awk '{print $1,$2,$18}' CLEM.testing_JAN_21_2015_underscore.txt | grep 2456075 | grep "+filters(ifilter)+" | awk '{print $1,$2}' > aha2.dat"
 spawn,str2
if (file_test('aha2.dat',/zero_length) ne 1) then begin
	data=get_data('aha2.dat')
JD=reform(data(0,*))
albedo=reform(data(1,*))
 factor=mean(ratio)
 oplot,jd mod 1,albedo/mean(albedo)*factor,psym=7,color=fsc_color('green')
 endif
 endif
;
;res=robust_linefit(ratio(idx),ratio(jdx))
;yhat=res(0)+res(1)*ratio(idx)
;oplot,ratio(idx),yhat
;residuals=ratio(jdx)-yhat
;print,'RMSE     : ',sqrt(total(residuals^2))/n_elements(idx)
;print,'RMSE in %: ',sqrt(total(residuals^2))/n_elements(idx)/mean(yhat)*100.
;
;ra=[min(ratio),max(ratio)]
;ra=xra
;plot,xrange=xra,yrange=yra,xtitle='ratio from linear image',ytitle='ratio from log image',xstyle=3,ystyle=3,/isotropic,ratio(idx),ratio(jdx),psym=7
;oplot,xra,yra,linestyle=1
endfor
end

