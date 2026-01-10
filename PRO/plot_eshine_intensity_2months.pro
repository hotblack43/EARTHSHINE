data=get_data('eshine_intensity_2months.dat')
jd=reform(data(0,*))
eshine=reform(data(1,*))
!P.CHARSIZE=2
!P.thick=2
!x.thick=2
!y.thick=2
!P.MULTI=[0,1,2]
jd=jd-long(jd(0))
plot,jd,eshine,xtitle='days',ytitle='earthshine intensity [W/m!u2!n]'
end
