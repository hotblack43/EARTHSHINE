spawn,'cat LRO.bootstrapperfitting_PSF_allpars_fastercode.txt > p'
data=get_data('p')
l=size(data,/dimensions)
print,'N: ',l(1)
!P.charthick=2
!P.thick=5
!x.thick=5
!y.thick=5
plot,/nodata,xrange=[1.3,2.1],yrange=[0.32,0.47],data(1,*),data(0,*),psym=7,xstyle=3,ystyle=3,xtitle='Alfa',ytitle='Albedo',charsize=2 
oplot,data(1,*),data(0,*),color=fsc_color('red'),psym=7 
res=robust_linefit(data(1,*),data(0,*),yhat)
oplot,data(1,*),yhat,color=fsc_color('red')
print,'Median Albedo: ',median(data(0,*))
listen= [median(data(0,*) )  ]
;----------------
spawn," cat LRO.bootstrapperfitting_PSFisalfa1only_fastercode.txt | awk '{print $2,$4}' > p"
data=get_data('p')                                                               
oplot,data(1,*),data(0,*),psym=7,color=fsc_color('green')
res=robust_linefit(data(1,*),data(0,*),yhat)
oplot,data(1,*),yhat,color=fsc_color('green')
print,'Median Albedo: ',median(data(0,*))
listen= [listen,median(data(0,*)  ) ]
;----------------
spawn," cat LRO.bootstrapperfitting_PSF_allpars_fastercode.txt | awk '{print $2,$4}' > p"
data=get_data('p')                                                               
oplot,data(1,*),data(0,*),psym=7,color=fsc_color('blue')
res=robust_linefit(data(1,*),data(0,*),yhat)
oplot,data(1,*),yhat,color=fsc_color('blue')
print,'Median Albedo: ',median(data(0,*))
listen= [listen,median(data(0,*)  ) ]
;
print,'SD albedos: ',stddev(listen)
print,'SD albedos: ',stddev(listen)/median(listen)*100., ' %'
end

