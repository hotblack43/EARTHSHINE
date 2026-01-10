filternames=['B','IRCUT','V','VE1','VE2']
 coln=['blue','orange','green','yellow','red']
 types=['H-X_HIRESscaled', 'H-X_LRO', 'H-X_UVVISnoscale', 'newH-63_HIRESscaled', 'newH-63_LRO', 'newH-63_UVVISnoscale']
 
 ;
 data=get_data('eureqain.noheader')
 idx=sort(abs(data(3,*)))
 data=data(*,idx)
 albedo=reform(data(0,*))
 filter=reform(data(1,*))
 brdf=reform(data(2,*))
 phase=reform(data(3,*))
 airm=reform(data(4,*))
 magn=reform(data(5,*))
 jd=reform(data(6,*))
 set_plot,'ps'
 device,/color
 device,xsize=18,ysize=24.5,yoffset=2
 device,/landscape,filename='dependencies_allfilters.ps'
 for filter_choice=0,4,1 do begin
     print,'------------------------------------------------'
     print,coln(filter_choice)
     print,filternames(filter_choice)
     !P.MULTI=[0,2,2]
     !P.thick=4
     !P.charsize=1.3
     !P.charthick=3
     ; plots panel 1 - albedo vs abs(phase)
     idx=where(jd gt 1)
     plot,/nodata,ystyle=3,psym=1,abs(phase(idx)),albedo(idx),xtitle='|!7u!3|',ytitle='Albedo'
     for ifilter=0,4,1 do begin
         for ibrdf=0,5,1 do begin
             idx=where(filter eq ifilter and brdf eq ibrdf)
             oplot,psym=(ibrdf+1),abs(phase(idx)),albedo(idx),color=fsc_color(coln(ifilter))
             endfor
         endfor
     ; plots panel 2 - for JD2456015 and V (or whatver ispicked) plot against type of BRDF+alb.map
     idx=where(long(jd) eq 2456015)
     ifilter=filter_choice
     plot,/nodata,xstyle=3,ystyle=3,yrange=[min(albedo(idx)),max(albedo(idx))],psym=1,title='JD2456015 '+filternames(ifilter),brdf(idx),albedo(idx),xtitle='BRDF+alb.map',ytitle='Albedo'
     for ibrdf=0,5,1 do begin
         idx=where(filter eq ifilter and brdf eq ibrdf and long(jd) eq 2456015)
         oplot,psym=1,brdf(idx),albedo(idx)
         endfor
     ; plots panel 3 - show airmass dependency
     idx=where(long(jd) eq 2456015)
     ifilter=filter_choice
     plot,/nodata,xstyle=3,ystyle=3,yrange=[min(albedo(idx)),max(albedo(idx))],psym=1,title='JD2456015 '+filternames(ifilter),airm(idx),albedo(idx),xtitle='Airmass',ytitle='Albedo'
     for ibrdf=0,5,1 do begin
         idx=where(filter eq ifilter and brdf eq ibrdf and long(jd) eq 2456015)
         oplot,psym=1,airm(idx),albedo(idx)
         ;res=ladfit(airm(idx),albedo(idx))
         res=robust_linefit(airm(idx),albedo(idx),yhat,sig,coef_sigs)
         yhat=res(0)+res(1)*airm(idx)
         oplot,airm(idx),yhat
         print,format='(a,f7.3,a,f8.4)','Slope: ',res(1),' +/- ',coef_sigs(1)
         endfor
     endfor
 print,'------------------------------------------------'
 device,/close
 end
 
