!P.MULTI=[0,2,3]
 !P.THICK=2
 !x.THICK=2
 !y.THICK=2
 !P.CHARSIZE=2
 
 filters=['B','V','VE1','VE2','IRCUT']
 openw,6,'plotme.dat'
 for ifilter=0,4,1 do begin
     filter=filters(ifilter)
     print,filter
     file='ERASEMEWHENYOUSEEME.Laplacian_Results_'+filter+'_.dat'
     data=get_data(file)
     jd=reform(data(0,*))
     ph=reform(data(1,*))
     ratio=reform(data(2,*))
     idx=where(ratio lt 2e-4)
     data=data(*,idx)
     jd=reform(data(0,*))
     ph=reform(data(1,*))
     ratio=reform(data(2,*))
;    ratio2=reform(data(3,*))
;    ratio3=ratio/ratio2
     ratio=-2.5*alog10(ratio)
;     ratio2=-2.5*alog10(ratio2)
	plot,yrange=[12,9],title=filter+' Model',ytitle='mags.',xtitle='Lunar phase [FM=0]',abs(ph),ratio,psym=7,xrange=[0,180],xstyle=3
;...............
     idx=where(ph lt 0)
     oplot,abs(ph(idx)),ratio(idx),color=fsc_color('red'),psym=7
     res=robust_linefit(abs(ph(idx)),ratio(idx),yhat)
     print,' Red: ',res
     oplot,abs(ph(idx)),yhat
;...............
     idx=where(ph gt 0)
     oplot,abs(ph(idx)),ratio(idx),color=fsc_color('blue'),psym=7
     res=robust_linefit(abs(ph(idx)),ratio(idx),yhat)
     print,'Blue: ',res
     oplot,abs(ph(idx)),yhat
     endfor
close,6
 end
