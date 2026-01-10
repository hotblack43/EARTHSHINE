data=get_data('stats_N_vs_observability.dat')
n=reform(data(0,*))
Jan=reform(data(1,*))
Jul=reform(data(2,*))
!P.CHARSIZE=1.6
!P.thick=2
!x.thick=2
!y.thick=2
plot,yrange=[20,100],xstyle=3,ystyle=3,/nodata,n,Jan,psym=-7,xtitle='N',ytitle='% coverage'
oplot,n,Jan,psym=-7,color=fsc_color('blue')
oplot,n,Jul,psym=-7,color=fsc_color('red')
end
