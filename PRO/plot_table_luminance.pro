; plot 
!P.MULTI=[0,1,2]
set_plot,'ps
device,xsize=18,ysize=24.5,yoffset=2
device,/color

data=get_data('best_altitude.dat')
sol=reform(data(0,*))
best=reform(data(1,*))
slope=reform(data(2,*))
plot,sol,best,xtitle='Solar altitude',ytitle='Altitude of point',charsize=2,title='Darkest point in sky'
plot,sol,slope,xtitle='Solar altitude',ytitle='Relative Lum. grad. [% pr deg.]',$
charsize=2,title='Smallest gradient in sky'
device,/close
 end
