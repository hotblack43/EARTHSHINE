PRO eachday1,jd,am,phase,corrmagn
 fixJDs=long(jd)
 uniqJD=fixJDs(sort(fixJDs))
 uniqJDs=fixJDs(uniq(fixJDs))
 n=n_elements(uniqJDs)
 openw,44,'k.dat'
 for i=0,n-1,1 do begin
     idx=where(long(jd) eq uniqJDs(i))
     if (n_elements(idx) gt 6) then begin
         res=robust_linefit(am(idx),corrmagn(idx),/double,yfit=yhat)
         if (abs(res(1)) lt 1) then begin
             printf,44,res(1)
             oplot,am(idx),yhat,color=fsc_color('red')
             endif
         endif
     endfor
 close,44
 data=get_data('k.dat')
 print,'Median slope: ',median(data)
 return
 end
 
 PRO plotnstuff,jd,phase,am,magn,k
 itype=2
 corrmagn=magn-k*am
 if (itype eq 1) then begin
     plot,am,corrmagn,psym=7
     eachday1,jd,am,phase,corrmagn
     endif
 if (itype eq 2) then begin
stop
 endif
 if (itype eq 3) then begin
 plot,phase,magn-k*am,psym=7,ystyle=3,xstyle=3
stop
 endif
 return
 end
 
 filename='fluxcurve_B.dat'
 filename='fluxcurve_V.dat'
 filename='fluxcurve_VE1.dat'
 filename='fluxcurve_VE2.dat'
 filename='fluxcurve_IRCUT.dat'
 data=get_data(filename)
 help,data
 jd=reform(data(0,*))
 phase=reform(data(1,*))
 am=reform(data(2,*))
 flux=reform(data(3,*))
 magn=-2.5*alog10(flux)
 idx=where(am le 3)
 am=am(idx)
 magn=magn(idx)
 jd=jd(idx)
 phase=phase(idx)
 k=0.15
 a=''
 while (a ne 'q') do begin
     a=get_kbrd()
     plot,title=filename,am,-2.5*alog10(flux)-k*am,psym=7
     plotnstuff,jd,phase,am,magn,k
     ;plot,jd mod 1,-2.5*alog10(flux)-k*am,psym=7
     ;plot,phase,magn-k*am,psym=7,ystyle=3,xstyle=3
     if (a eq 'u') then k=k*1.01
     if (a eq 'd') then k=k/1.0100454d0
     print,'k=',k,stddev(magn-k*am)/mean(magn-k*am)
     endwhile
 end
