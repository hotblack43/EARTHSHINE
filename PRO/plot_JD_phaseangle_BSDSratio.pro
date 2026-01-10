file='JD_phaseangle_BSDSratio_Moonlambert.dat'
data=get_data(file)
JD=reform(data(0,*))
phase=reform(data(1,*))
ratio=reform(data(2,*))
plot,phase,1.0/ratio,/ylog,xtitle='Phase angle!dE!n',ytitle='Crisium/Grimaldi', $
charsize=1.5,xstyle=1,xrange=[0,180],title='Lunar BRDF Lambert (black) or Hapke * 1.25 (red)',yrange=[3e2,1e6],ystyle=1
plots,180-91,16458,psym=7
plots,180-124,3447,psym=7
plots,180-111,6911,psym=7
plots,180-91,16458*1.1,psym=3
plots,180-124,3447*1.1,psym=3
plots,180-91,16458/1.1,psym=3
plots,180-124,3447/1.1,psym=3
xyouts,20,1000,'Near New',charsize=2,orientation=90
xyouts,170,1000,'Near Full',charsize=2,orientation=90
file='JD_phaseangle_BSDSratio_MoonHapke.dat'
data=get_data(file)
JD=reform(data(0,*))
phase=reform(data(1,*))
ratio=reform(data(2,*))
oplot,phase,1.25/ratio,color=fsc_color('red')
end
