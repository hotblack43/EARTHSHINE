;window,2
!P.MULTI=[0,1,2]
!P.THICK=2
!x.THICK=2
!y.THICK=2
data=get_data('results.dat')
f=reform(data(0,*))
val1=reform(data(1,*))
val2=reform(data(2,*))
val3=reform(data(3,*))
val4=reform(data(4,*))
val1b=reform(data(4,*))
val3b=reform(data(4,*))
plot,psym=-7,xstyle=3,ystyle=3,yrange=[min(data(1:4,*)),max(data(1:4,*))],f,val1,xtitle='Rebin factor',ytitle='Earthshine estimate'
oplot,psym=-6,f,val1b
oplot,psym=-7,f,val2,color=fsc_color('red')
oplot,psym=-7,f,val3,color=fsc_color('blue')
oplot,psym=-6,f,val3b,color=fsc_color('blue')
oplot,psym=-7,f,val4,color=fsc_color('orange')
xyouts,2,3.55,'Jump in OBS'
xyouts,2,3.72,'Signature in Laplacian of OBS'
xyouts,2,3.46,'Jump in EFM'
xyouts,2,3.63,'Signature in Laplacian of EFM'
end
