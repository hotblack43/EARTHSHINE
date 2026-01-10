FUNCTION HenyeyGreenstein,angle,g
value=(1.-g^2)/(1.+g^2-2.*g*cos(angle*!dtor))^1.5
return,value
end


!P.MULTI=[0,1,2]
angle=findgen(360)/2.+0.1
plot_oo,angle,HenyeyGreenstein(angle,0.999),xstyle=3,ystyle=3,charsize=2,xtitle='Angle [degrees]',ytitle='HG(angle,g)',title='HG for g=0.99999, ... , 0.9 (dashed)'
oplot,angle,HenyeyGreenstein(angle,0.9999)
oplot,angle,HenyeyGreenstein(angle,0.99999)
oplot,angle,HenyeyGreenstein(angle,0.99)
oplot,angle,HenyeyGreenstein(angle,0.9),linestyle=2
angle=findgen(360)/36.*4.+1
plot_oo,angle,HenyeyGreenstein(angle,0.83),xstyle=3,ystyle=3,charsize=2,xtitle='Angle [degrees]',ytitle='HG(angle,g)',linestyle=2,yrange=[0.1,10000],title='HG(g) from Jorge et al Table 1. g=0.83 dashed'
oplot,angle,HenyeyGreenstein(angle,0.947)
oplot,angle,HenyeyGreenstein(angle,0.942)
oplot,angle,HenyeyGreenstein(angle,0.935)
oplot,angle,HenyeyGreenstein(angle,0.905)
end
