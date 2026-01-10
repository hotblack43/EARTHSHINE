file='C:\Documents and Settings\Daddyo\Skrivebord\ASTRO\ROLO\ROLO_765nm_Vega_psf.dat'
data=get_data(file)
r=reform(data(0,*))
psf=reform(data(1,*))
plot,r,psf,/xlog,/ylog,xtitle='Radius (arc seconds)',ytitle='Profile',title='Tom Stone work for Vega in 765 nm band',xrange=[0.1,500],xstyle=1,yrange=[1e-4,1e3],ystyle=1
x=findgen(5.*60*60.)+10
b=4.2e2
y=b/x^2.275
oplot,x,y,color=FSC_color('red')
end