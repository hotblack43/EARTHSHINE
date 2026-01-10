FUNCTION int_TABULATED,x,y
 sum=0.0
 for i=1,n_elements(x)-2,1 do begin
     dx=x(i+1)-x(i)
     sum=sum+0.5*(y(i+1)+y(i))*dx
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
 fstr=['B','V','VE1','VE2','IRCUT']
 ; get transmission curve
 for radius=0.25,4.25,1.0 do begin
 for ifltr=0,4,1 do begin
     filterstr=fstr(ifltr)
     transmission=get_data('./SYSINFO/TRANS/'+filterstr+'_transmission.dat')
     ; Get ANDOR QE curve
     andor=get_data('QE_Andor_897.txt')
     ; get Wehrli's solar spectrum
     data=get_data('./wehrli85.txt')        
     wavelength=data(0,*)	; in nm
     flux=data(1,*)
     nW=n_elements(wavelength)
     fun_sum=0.0
     theta=findgen(1000)/100000.	; angle in degrees
     for nwave=1,nW-1,1 do begin
         wavel=wavelength(nwave)/1e9*100.	; also in cm
         qe=interpol(reform(andor(1,*)),reform(andor(0,*)),wavelength(nwave))
         trans=interpol(reform(transmission(1,*)),reform(transmission(0,*)),wavelength(nwave))
         fun=airy(radius,wavel,theta)
         summand=trans*qe*flux(nwave)*fun*(wavelength(nwave)/1e9*100.-wavelength(nwave-1)/1e9*100.)
         fun_sum=fun_sum+summand	; flux-weighted sum of Airy fn
;        print,wavel,qe*flux(nwave)*(wavelength(nwave)/1e9*100.-wavelength(nwave-1)/1e9*100.)
         plot_oo,theta*3600.,fun_sum,xtitle='!7s!3 [arc seconds]'
         hm=max(fun_sum,/NaN)/2.0
         hwhm=interpol(theta*3600.,fun_sum,hm)
         endfor
     xx=theta*3600.
     print,'FWHM: ',2.*hwhm,' asec'
     oplot,[0.1,10],[hm,hm],linestyle=1
     outname=strcompress(filterstr+'_airy_'+string(radius,format='(f4.2)')+'cm.dat',/remove_all)
     print,outname
     openw,3,outname
     norm=int_tabulated(xx,fun_sum)
     for i=1,n_elements(fun_sum)-1,1 do begin
         printf,3,xx(i),fun_sum(i)/norm
         endfor
     close,3
     endfor
     endfor
 end
