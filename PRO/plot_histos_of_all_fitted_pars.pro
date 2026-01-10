file='CLEM.profiles_fitted_results_fan_yesnoZLSL_DSBS_TEST3.txt'
str="cat "+file+"| grep _B_ | awk '{print $1,$2,$3}'  > albedos_B_tohist.dat" 
spawn,str
str="cat "+file+"| grep _B_  | awk '{print $1,$4,$5,$6,$7,$8,$9,$10}' > parameters_B_tohist.dat" 
spawn,str

str="cat "+file+"| grep _V_ | awk '{print $1,$2,$3}'  > albedos_V_tohist.dat" 
spawn,str
str="cat "+file+"| grep _V_  | awk '{print $1,$4,$5,$6,$7,$8,$9,$10}' > parameters_V_tohist.dat" 
spawn,str
;
str="cat "+file+"| grep _VE1_ | awk '{print $1,$2,$3}'  > albedos_VE1_tohist.dat" 
spawn,str
str="cat "+file+"| grep _VE1_  | awk '{print $1,$4,$5,$6,$7,$8,$9,$10}' > parameters_VE1_tohist.dat" 
spawn,str
;
str="cat "+file+"| grep _VE2_ | awk '{print $1,$2,$3}'  > albedos_VE2_tohist.dat" 
spawn,str
str="cat "+file+"| grep _VE2_  | awk '{print $1,$4,$5,$6,$7,$8,$9,$10}' > parameters_VE2_tohist.dat" 
spawn,str
;
str="cat "+file+"| grep _IRCUT_ | awk '{print $1,$2,$3}'  > albedos_IRCUT_tohist.dat" 
spawn,str
str="cat "+file+"| grep _IRCUT_  | awk '{print $1,$4,$5,$6,$7,$8,$9,$10}' > parameters_IRCUT_tohist.dat" 
spawn,str
;
binwidth=0.028765
data=get_data('albedos_B_tohist.dat')
data=data(*,where(data(1,*) gt 0.0 and data(2,*) lt 0.03))
jd=reform(data(0,*))
albedo=reform(data(1,*))
erralbedo=reform(data(2,*))
print,format='(a,f6.4,a,f6.4)','B     :',median(albedo),' +/- ',mean(erralbedo)
histo,albedo,0,1,binwidth,xtitle='Albedo',/abs,yrange=[0,40]
colornow=!P.color
!P.color=fsc_color('blue')
histo,/overplot,albedo,0,1,binwidth,/abs
data=get_data('albedos_V_tohist.dat')
data=data(*,where(data(1,*) gt 0.0 and data(2,*) lt 0.03))
jd=reform(data(0,*))
albedo=reform(data(1,*))
erralbedo=reform(data(2,*))
print,format='(a,f6.4,a,f6.4)','V     :',median(albedo),' +/- ',mean(erralbedo)
!P.color=fsc_color('green')
histo,/overplot,albedo,0,1,binwidth,/abs
data=get_data('albedos_VE1_tohist.dat')
data=data(*,where(data(1,*) gt 0.0 and data(2,*) lt 0.03))
jd=reform(data(0,*))
albedo=reform(data(1,*))
erralbedo=reform(data(2,*))
print,format='(a,f6.4,a,f6.4)','VE1   :',median(albedo),' +/- ',mean(erralbedo)
!P.color=fsc_color('yellow')
histo,/overplot,albedo,0,1,binwidth,/abs
data=get_data('albedos_VE2_tohist.dat')
data=data(*,where(data(1,*) gt 0.0 and data(2,*) lt 0.03))
jd=reform(data(0,*))
albedo=reform(data(1,*))
erralbedo=reform(data(2,*))
print,format='(a,f6.4,a,f6.4)','VE2   :',median(albedo),' +/- ',mean(erralbedo)
!P.color=fsc_color('red')
histo,/overplot,albedo,0,1,binwidth,/abs
data=get_data('albedos_IRCUT_tohist.dat')
data=data(*,where(data(1,*) gt 0.0 and data(2,*) lt 0.03))
jd=reform(data(0,*))
albedo=reform(data(1,*))
erralbedo=reform(data(2,*))
print,format='(a,f6.4,a,f6.4)','IRCUT :',median(albedo),' +/- ',mean(erralbedo)
!P.color=fsc_color('orange')
histo,/overplot,albedo,0,1,binwidth,/abs
;
!P.color=colornow
end
