PRO gobootstrapthebootstrapresults,array,strout,medianquantity
; will bootstrap the array and print out the text string along with the median and its uncertainty
nMC=1000
listen=[]
n=n_elements(array)
for i=0,nMC-1,1 do begin
idx=fix(randomu(seed,n)*n)
medianquantity=median(array(idx))
listen=[listen,median(array(idx))]
endfor
print,strout,median(listen),robust_sigma(listen)
return
end

;===================================================
spawn," cat LRO.bootstrapperfitting_PSFisalfa1only.txt | awk '{print $2,$4}' > p"
pars=[]
data=get_data('p')
data(1,*)=data(1,*)*1.601890	; 1.601890 is the far-field halo-slope
l=size(data,/dimensions)
!P.charthick=2
!P.thick=5
!x.thick=5
!y.thick=5
!P.multi=[0,1,2]
print,'---------------------------------------'
plot,/nodata,xrange=[2.1,5.1],yrange=[0.3,0.65],data(1,*),data(0,*),psym=7,xstyle=3,ystyle=3,xtitle='Alfa',ytitle='Albedo',charsize=2 
oplot,data(1,*),data(0,*),color=fsc_color('red'),psym=7 
res=robust_linefit(data(1,*),data(0,*),yhat)
print,'d Albedo/d alfa : ',res(0)
oplot,data(1,*),yhat,color=fsc_color('red')
gobootstrapthebootstrapresults,data(0,*),'Median Albedo, +/- : ',medianalbedo
listen= [median(data(0,*) )  ]
gobootstrapthebootstrapresults,data(1,*),'Median Alfa,   +/- : ',medianalfa
pars=[medianalbedo,medianalfa]
print,'---------------------------------------'
;----------------
spawn," cat LRO.bootstrapperfitting_PSFisalfa1only_fastercode.txt | awk '{print $2,$4}' > p"
data=get_data('p')                                                               
data(1,*)=data(1,*)*1.601890	; 1.601890 is the far-field halo-slope
oplot,data(1,*),data(0,*),psym=7,color=fsc_color('green')
res=robust_linefit(data(1,*),data(0,*),yhat)
print,'d Albedo/d alfa : ',res(0)
oplot,data(1,*),yhat,color=fsc_color('green')
gobootstrapthebootstrapresults,data(0,*),'Median Albedo, +/- : ',medianalbedo
listen= [median(data(0,*) )  ]
gobootstrapthebootstrapresults,data(1,*),'Median Alfa,   +/- : ',medianalfa
pars=[[pars],[medianalbedo,medianalfa]]
print,'---------------------------------------'
;----------------
spawn," cat LRO.bootstrapperfitting_PSF_allpars_fastercode.txt | awk '{print $2,$4}' > p"
data=get_data('p')                                                               
data(1,*)=data(1,*)*1.601890	; 1.601890 is the far-field halo-slope
oplot,data(1,*),data(0,*),psym=7,color=fsc_color('blue')
res=robust_linefit(data(1,*),data(0,*),yhat)
print,'d Albedo/d alfa : ',res(0)
oplot,data(1,*),yhat,color=fsc_color('blue')
gobootstrapthebootstrapresults,data(0,*),'Median Albedo, +/- : ',medianalbedo
listen= [listen,median(data(0,*)  ) ]
gobootstrapthebootstrapresults,data(1,*),'Median Alfa,   +/- : ',medianalfa
pars=[[pars],[medianalbedo,medianalfa]]
print,'---------------------------------------'
;
print,'SD albedos: ',stddev(listen)
print,'SD albedos: ',stddev(listen)/median(listen)*100., ' %'
print,'---------------------------------------'
; detailed plot wo regression lines:
spawn," cat LRO.bootstrapperfitting_PSFisalfa1only.txt | awk '{print $2,$4}' > p"
data=get_data('p')
data(1,*)=data(1,*)*1.601890	; 1.601890 is the far-field halo-slope
l=size(data,/dimensions)
plot,/nodata,xrange=[2.3,3.25],yrange=[0.34,0.44],data(1,*),data(0,*),psym=7,xstyle=3,ystyle=3,xtitle='Alfa',ytitle='Albedo',charsize=2 
oplot,data(1,*),data(0,*),color=fsc_color('red'),psym=7 
oplot,[3.0,3.0],[!Y.crange],linestyle=1
;----------------
spawn," cat LRO.bootstrapperfitting_PSFisalfa1only_fastercode.txt | awk '{print $2,$4}' > p"
data=get_data('p')                                                               
data(1,*)=data(1,*)*1.601890	; 1.601890 is the far-field halo-slope
oplot,data(1,*),data(0,*),psym=7,color=fsc_color('green')
;----------------
spawn," cat LRO.bootstrapperfitting_PSF_allpars_fastercode.txt | awk '{print $2,$4}' > p"
data=get_data('p')                                                               
data(1,*)=data(1,*)*1.601890	; 1.601890 is the far-field halo-slope
oplot,data(1,*),data(0,*),psym=7,color=fsc_color('blue')
;
oplot,[(pars(1,0)),(pars(1,0))],[!Y.crange],color=fsc_color('red')
oplot,[!x.crange],[(pars(0,0)),(pars(0,0))],color=fsc_color('red')
oplot,[(pars(1,1)),(pars(1,1))],[!Y.crange],color=fsc_color('green')
oplot,[!x.crange],[(pars(0,1)),(pars(0,1))],color=fsc_color('green')
oplot,[(pars(1,2)),(pars(1,2))],[!Y.crange],color=fsc_color('blue')
oplot,[!x.crange],[(pars(0,2)),(pars(0,2))],color=fsc_color('blue')
oplot,[median(pars(1,*)),median(pars(1,*))],[!Y.crange]
oplot,[!x.crange],[median(pars(0,*)),median(pars(0,*))]
end

