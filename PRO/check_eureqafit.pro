FUNCTION eureqa,airm,filter,phase,itype
 ; fit by EUREQA of phase, airmass and filter number to BS magnitudes
 ; itype=4 is best
 if (itype eq 1) then magnitude = 1.239*filter + 4.385*(1.231+filter*0 lt filter) + 0.0002383*phase^2 - 26.08 - 4.019*(filter < 2.721+0*filter)
 if (itype eq 2) then magnitude = 0.1354*airm + 0.0001775*phase*airm + 0.0002318*phase^2 + 1.038*cos(3.037e5*filter) - 27.31 - 0.7801*(1.366+0*filter < filter)
 if (itype eq 3) then magnitude = 1.319*filter + 0.1434*airm + 0.0002316*phase + 0.0002316*phase^2 + 0.001457*phase*(2.961+0*airm lt airm) + 4.479*(1.319+0*filter lt 1.319*filter) - 26.28 - 4.151*(filter < 2.727+0*filter)
 if (itype eq 4) then magnitude = 1.334*filter + 0.1372*airm + 0.0002714*phase*airm + 4.472*(1.334+0*filter lt filter) + 0.0002327*phase^2 - 26.28 - 0.0002714*phase - 4.16*(2.729+0*filter < filter)
 term=1.262+0*filter
 idx=where(filter lt airm)
 term(idx)=airm(idx)
 if (itype eq 5) then magnitude = 1.302*filter + 0.1809*airm + 0.0003297*phase + 4.393*(1.302+0*filter lt filter) + 0.0002351*phase^2 - 26.3 - 4.055*(2.739+0*filter < filter) - 0.08054*term; if(filter, airm, 1.262)
 if (itype eq 6) then magnitude = 4.801*filter + 0.1387*airm + 0.0002822*phase*airm + 0.0002321*phase^2 - 26.28 - 0.0002609*phase - 7.623*sqrt(filter) - 1.361*filter*(2.305+0*filter lt filter)
 return,magnitude
 end
 
 filternames=['B','IRCUT','V','VE1','VE2']
 coln=['blue','orange','green','yellow','red']
 types=['H-X_HIRESscaled', 'H-X_LRO', 'H-X_UVVISnoscale', 'newH-63_HIRESscaled', 'newH-63_LRO', 'newH-63_UVVISnoscale']
 !P.CHARSIZE=2
 !P.THICK=4
 !P.charthick=3
;for itype=1,6,1 do begin
 for itype=3,3,1 do begin
     print,'----------------------------------------'
     print,'itype= ',itype
     data=get_data('eureqain.noheader')
     ;   A,        filter,   brdf,    phase,     airm, magnitude,jd
     albedo=reform(data(0,*))
     filter=reform(data(1,*))
     ; jumble the filter number to see effect
     ;jdx=long(randomu(seed,n_elements(filter))*n_elements(filter))
     ;filter=filter(jdx)
     ;-------------------------------
     brdf=reform(data(2,*))
     phase=reform(data(3,*))
     airm=reform(data(4,*))
     mags=reform(data(5,*))
     jd=reform(data(6,*))
     magni=eureqa(airm,filter,phase,itype)
     !P.MULTI=[0,2,3]
     for ifil=0,4,1 do begin
         idx=where(filter eq ifil)
         plot,mags(idx),magni(idx),psym=7,/isotropic,xtitle='Observed BS mag',ytitle='EUREQA model #'+string(itype)
         endfor
     !P.MULTI=[0,1,2]
     plot,xstyle=3,ystyle=3,mags,magni,psym=7,/isotropic,xtitle='Observed BS mag',ytitle=strcompress('EUREQA model #'+string(itype))
     for ifil=0,4,1 do begin
         idx=where(filter eq ifil)
         oplot,mags(idx),magni(idx),psym=7,color=fsc_color(coln(ifil))
         relfluxerr=(10^(mags(idx)/(-2.5))-10^(magni(idx)/(-2.5)))/10^(magni(idx)/(-2.5))*100.
	 print,'SD of relflux at '+filternames(ifil)+', in pct ',ifil,(stddev(relfluxerr))
         endfor
     print,'R(mag,model): ',correlate(mags,magni)
     residuals=mags-magni
     print,'s.d. of residuals, robust same: ',stddev(residuals),robust_sigma(residuals)
     print,'RMSE of magnitudes: ',sqrt(total(residuals^2)/n_elements(residuals))
     print,'relative RMSE on magns: ',sqrt(total((residuals/mags)^2)/n_elements(residuals))*100.,' %'
     histo,residuals,min(residuals),max(residuals),$
     0.01,xtitle='Residual',/abs
     endfor
 print,'----------------------------------------'
 end
