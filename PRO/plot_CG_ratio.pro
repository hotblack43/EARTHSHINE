data=get_data('data.dat')
ratio_obs=reform(data(1,*))

days=indgen(n_elements(ratio_obs))/24.
!P.MULTI=[0,1,1]
!P.charsize=3

plot,days,ratio_obs,title='Observed Grimaldi/Crisium ratio',charsize=2,psym=-7 ,xtitle='Days',xstyle=1

end