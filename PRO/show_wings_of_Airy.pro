FUNCTION int_TABULATED,x,y
 sum=0.0d0
 for i=1,n_elements(x)-2,1 do begin
     dx=x(i+1)-x(i)
     sum=sum+0.5d0*(y(i+1)+y(i))*dx
     endfor
 return,sum
 end
 
 FUNCTION airy,radius,wavelength,theta
 ; INPUT 	radius - of aperture
 ;		wavelength of light
 ;		theta - angle from center in degrees
 arg=2.*!dpi*radius/wavelength*sin(theta*!dtor)
 value=(BESELJ(arg,1)/sin(theta*!dtor))^2
 return,value
 end
 
 
 !P.charsize=2
 !P.thick=2
 !P.charthick=3
 listen1 = []
 listen2 = []
 listen3 = []
 radius1=1.0d0  ; cm
 radius2=0.1d0  ; cm
 radius3=10.d0  ; cm
 wavelength=5000*1e-8  ; cm
 for theta=1e-10,0.2,0.00001d0 do begin
	 listen1=[[listen1],[theta,airy(radius1,wavelength,theta)]]
	 listen2=[[listen2],[theta,airy(radius2,wavelength,theta)]]
	 listen3=[[listen3],[theta,airy(radius3,wavelength,theta)]]
 endfor
 area1=int_TABULATED(listen1(0,*),listen1(1,*))
 area2=int_TABULATED(listen2(0,*),listen2(1,*))
 area3=int_TABULATED(listen3(0,*),listen3(1,*))
!P.MULTI=[0,1,2]
 plot_oo,listen1(0,*),listen1(1,*)/area1,xrange=[1e-5,0.3],yrange=[1e-12,1e5],xtitle="Angle [degrees]",ytitle='Normalized Airy function'
 oplot,listen2(0,*),listen2(1,*)/area2,color=fsc_color('red')
 oplot,listen3(0,*),listen3(1,*)/area3,color=fsc_color('blue')
 xyouts,0.1,1e4,'Red    : 0.1 cm',charsize=0.8
 xyouts,0.1,1e3,'Black  : 1.0 cm',charsize=0.8
 xyouts,0.1,1e2,'Blue   : 10  cm',charsize=0.8
 ; plot normalised at peak
 plot_oo,listen1(0,*),listen1(1,*)/listen1(1,1),xrange=[1e-5,0.3],yrange=[1e-10,1.2],xtitle="Angle [degrees]",ytitle='Normalized Airy function'
 oplot,listen2(0,*),listen2(1,*)/listen2(1,1),color=fsc_color('red')
 oplot,listen3(0,*),listen3(1,*)/listen3(1,1),color=fsc_color('blue')
 xyouts,0.1,1e1,'Red    : 0.1 cm',charsize=0.8
 xyouts,0.1,1e0,'Black  : 1.0 cm',charsize=0.8
 xyouts,0.1,1e-1,'Blue   : 10  cm',charsize=0.8
 end

  
