file='eshine_out_MoonHapke_MoonClementine_nolib_nodist.dat'
data=get_data(file)
jd=reform(data(0,*))
Sun=reform(data(1,*))
Earth=reform(data(2,*))
phase=reform(data(3,*))
ratio=Sun/Earth
mphase,jd,illum_frac
!P.MULTI=[0,1,4]
plot_io,jd-jd(0),ratio,charsize=2,xtitle='Day',ytitle='I!dSun!n/I!dEarth!n'
plot,jd-jd(0),illum_frac,charsize=2,xtitle='Day',ytitle='Illuminated fraction'
plot_io,illum_frac,ratio,psym=3,xtitle='Illuminated fraction',ytitle='I!dSun!n/I!dEarth!n',charsize=2
plot,phase,illum_frac,charsize=2,xtitle='Phase',ytitle='Illuminated fraction'
plot_io,phase,ratio,charsize=2,xtitle='phase',ytitle='I!dSun!n/I!dEarth!n',psym=7
plot,phase,illum_frac,charsize=2,xtitle='phase',ytitle='Illuminated fraction',psym=7
end
