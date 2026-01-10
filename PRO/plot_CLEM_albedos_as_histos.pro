spawn,"cat CLEM.profiles_fitted_results_3treatments_multipatch.txt | awk '{print $2}' > p.dat"
data=get_data('p.dat')
alb=reform(data(0,*))
!P.COLOR=fsc_color('white')
histo,/abs,alb,0.25,0.45,0.005,xtitle='Albedo'
;
spawn,"cat CLEM.profiles_fitted_results_3treatments_multipatch_rlim_fixed.txt | awk '{print $2}' > p.dat"
data=get_data('p.dat')
alb=reform(data(0,*))
!P.COLOR=fsc_color('red')
histo,/overplot,/abs,alb,0.25,0.45,0.006
;
spawn,"cat CLEM.profiles_fitted_results_3treatments_multipatch_rlim_fixed_smoo.txt | awk '{print $2}' > p.dat"
data=get_data('p.dat')
alb=reform(data(0,*))
!P.COLOR=fsc_color('orange')
histo,/overplot,/abs,alb,0.25,0.45,0.007
end
