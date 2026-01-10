FUNCTION int_TABULATED,x,y
 sum=0.0
 for i=1,n_elements(x)-2,1 do begin
     dx=x(i+1)-x(i)
     sum=sum+0.5*(y(i+1)+y(i))*dx
     endfor
 return,sum
 end
 
 
 FUNCTION airy,wavelength,q,N
 ;		wavelength of light in nm
 ;		q - distance in the frame from beam centre
 ;		N - the f-number of the system
 x=!dpi*q*6.67e-6/(wavelength/1e9)/N
 value=(BESELJ(x,1)/x)^2
 return,value
 end
 
 
 
 !P.charsize=2
 !P.charthick=3
 !P.thick=4
 !x.thick=4
 !y.thick=4
 !X.style=3
 q=(findgen(2560)+1)/10.
 N=10
 sum=0.0
 for wavelength=450.,550.,.1 do begin	; in nm
     sum=sum+airy(wavelength,q,N)/int_TABULATED(q,airy(wavelength,q,N))
     endfor
 plot_oo,q,sum,xtitle='q [pixels]',ytitle='PSF',title='Over 100-nm band',/nodata
 oplot,q,sum,color=fsc_color('red')
 psf10=sum
 N=12
 sum=0.0
 for wavelength=450.,550.,.1 do begin	; in nm
     sum=sum+airy(wavelength,q,N)/int_TABULATED(q,airy(wavelength,q,N))
     endfor
 oplot,q,sum,color=fsc_color('green')
 psf12=sum
 N=14
 sum=0.0
 for wavelength=450.,550.,.1 do begin	; in nm
     sum=sum+airy(wavelength,q,N)/int_TABULATED(q,airy(wavelength,q,N))
     endfor
 oplot,q,sum,color=fsc_color('orange')
 psf14=sum
 ;---
 oplot,q,1000./q^3
 help,psf10,psf12,psf14,q
 end
