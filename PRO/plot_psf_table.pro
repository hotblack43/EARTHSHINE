spawn,'./plot_psf_from_tables'
data=double(get_data('psf_table.dat'))
r=reform(data(0,*))*6.67/60	; arc minutes
y=reform(data(1,*))
plot_oo,r,y,xrange=[1*6.67/60,sqrt(2)*512*6.67/60],xtitle='Radius [arc min]',ytitle='PSF',charsize=1.8,xstyle=3,ystyle=3
data=get_data('matchpoints.txt')
n=n_elements(data)-1
x=double(reform(data(0:n)))
oplot,x,interpol(y,r,x),psym=7
xx=dindgen(1000)
yy=1d-3/(xx/10)^3.0d0
oplot,xx,yy,color=fsc_color('red')
end
