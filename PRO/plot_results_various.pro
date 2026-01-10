;device,/color
;device,xsize=18,ysize=24.5,yoffset=2

window,xsize=400,ysize=800
data=get_data('results_various_alignmethods.dat')
!P.multi=[0,1,2]
!P.thick=4
!P.charsize=2
!P.charthick=2
plot,data(1,*),data(2,*),psym=7,/ylog,xtitle='Iteration',ytitle='Shifts'
idx=where(data(0,*) eq 0)
oplot,data(1,idx),data(2,idx),psym=-7,color=fsc_color('green')
idx=where(data(0,*) eq 1)
oplot,data(1,idx),data(2,idx),psym=-7,color=fsc_color('red')
idx=where(data(0,*) eq 2)
oplot,data(1,idx),data(2,idx),psym=-7,color=fsc_color('orange')
idx=where(data(0,*) eq 3)
oplot,data(1,idx),data(2,idx),psym=-7,color=fsc_color('blue')
;idx=where(data(0,*) eq 4)
;oplot,data(1,idx),data(2,idx),psym=-7,color=fsc_color('grey')
;---------------
f=0.5
xyouts,/normal,0.5,f*0.8, '  linear Green',charsize=1.7
xyouts,/normal,0.5,f*0.77,'    sqrt Red',charsize=1.7
xyouts,/normal,0.5,f*0.74,'squared Orange',charsize=1.7
xyouts,/normal,0.5,f*0.71,'   log10 Blue',charsize=1.7
;xyouts,/normal,0.5,f*0.68,'   HEQ Grey',charsize=1.7
;---------------------
plot,ystyle=3,yrange=[4e8,3e9],data(1,*),data(4,*),psym=7,/ylog,xtitle='Iteration',ytitle='Residuals'
idx=where(data(0,*) eq 0)
oplot,data(1,idx),data(4,idx),psym=-7,color=fsc_color('green')
idx=where(data(0,*) eq 1)
oplot,data(1,idx),data(4,idx),psym=-7,color=fsc_color('red')
idx=where(data(0,*) eq 2)
oplot,data(1,idx),data(4,idx),psym=-7,color=fsc_color('orange')
idx=where(data(0,*) eq 3)
oplot,data(1,idx),data(4,idx),psym=-7,color=fsc_color('blue')
;---------------
;if (dev eq 'ps') then device,/close

end

