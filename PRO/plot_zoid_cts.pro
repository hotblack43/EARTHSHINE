 !P.THICK=3
 !x.THICK=4
 !y.THICK=4
 !P.CHARTHICK=3
!P.charsize=2.2
data=get_data('zodi_cts.dat')
plot_oo,data(2,*),data(3,*),xtitle='Step size',ytitle='ZL in % of Step size',psym=7
oplot,[0.1,100],[0.1,0.1],linestyle=2
end
