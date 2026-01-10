data=get_data('yesZLSL_noZLSL.dat')

albedoyes=reform(data(1,*))
albedono=reform(data(5,*))
ZL=reform(data(2,*))
SL=reform(data(3,*))

deltapct=(albedoyes-albedono)/(0.5*(albedoyes+albedono))*100.
!X.STYLE=3
!Y.STYLE=3
histo,/abs,deltapct,-2,2.,0.07,xtitle='!7D!3Albedo [%]'
;
plot,ZL+SL,deltapct,psym=7
end
