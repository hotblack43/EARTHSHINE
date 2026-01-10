!P.CHARSIZE=2
!P.THICK=2
!X.THICK=2
!Y.THICK=2
data=get_data('fluxes_m_r.dat')
time=reform(data(0,*))
measuredflux=reform(data(1,*))
requestedflux=reform(data(2,*))
plot_io,xstyle=3,ystyle=3,time,measuredflux,xtitle='Lower exposure limit [ms]',ytitle='SD of flux in %',title='Black: M, Red: R'
oplot,time,requestedflux,color=fsc_color('red')
end
