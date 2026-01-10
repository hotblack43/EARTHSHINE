numbins=73
RMSElimit=0.63e22
spawn,"awk '$11 < "+string(RMSElimit)+" {print $2}' CLEM.profiles_fitted_results_fan_DSBS_ZLSL.txt > p"
p=get_data('p')
!Y.STYLE=3
histo,/abs,p,min(p),max(p),(max(p)-min(p))/numbins,xtitle='Albedo'
;
spawn,"awk '$11 < "+string(RMSElimit)+" {print $3}' CLEM.profiles_fitted_results_fan_DSBS_ZLSL.txt > p"
p=get_data('p')
!Y.STYLE=3
histo,/abs,p,min(p),max(p),(max(p)-min(p))/numbins,xtitle='Albedo Error'
;
spawn,"awk '$11 < "+string(RMSElimit)+" {print $4}' CLEM.profiles_fitted_results_fan_DSBS_ZLSL.txt > p"
p=get_data('p')
!Y.STYLE=3
histo,/abs,p,min(p),max(p),(max(p)-min(p))/numbins,xtitle='!7a!3'
;
spawn,"awk '$11 < "+string(RMSElimit)+" {print $6}' CLEM.profiles_fitted_results_fan_DSBS_ZLSL.txt > p"
p=reform(get_data('p'))
!Y.STYLE=3
histo,/abs,p,min(p),max(p),(max(p)-min(p))/numbins,xtitle='Pedestal'
;
spawn,"awk '$11 < "+string(RMSElimit)+" {print $7}' CLEM.profiles_fitted_results_fan_DSBS_ZLSL.txt > p"
p=reform(get_data('p'))
!Y.STYLE=3
histo,/abs,p,min(p),max(p),(max(p)-min(p))/numbins,xtitle='!7D!3x'
;
spawn,"awk '$11 < "+string(RMSElimit)+" {print $9}' CLEM.profiles_fitted_results_fan_DSBS_ZLSL.txt > p"
p=alog10(reform(get_data('p')))
!Y.STYLE=3
histo,/abs,p,min(p),max(p),(max(p)-min(p))/numbins,xtitle='log!d10!n Core factor'
;
spawn,"awk '$11 < "+string(RMSElimit)+" {print $10}' CLEM.profiles_fitted_results_fan_DSBS_ZLSL.txt > p"
p=reform(get_data('p'))
!Y.STYLE=3
histo,/abs,p,min(p),max(p),(max(p)-min(p))/numbins,xtitle='Albedo contrast'
;
spawn,"awk '$11 < "+string(RMSElimit)+" {print $11}' CLEM.profiles_fitted_results_fan_DSBS_ZLSL.txt > p"
p=alog10(reform(get_data('p')))
!Y.STYLE=3
histo,/abs,p,min(p),max(p),(max(p)-min(p))/numbins,xtitle='log!d10!n RMSE'
end




; 2455943.0442340   0.28340   0.01014   1.83989   3.00000  -0.00012   1.93291   0.00000   4.33230   0.85091      0.068   386559262.326  0.0000000  0.0000000 /data/pth/DARKCURRENTREDUCED/SELECTED_4/2455943.0442340MOON_V_AIR_DCR.fits  FAN_DSBS_
