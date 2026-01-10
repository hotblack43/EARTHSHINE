FUNCTION findBS,jd
; will return 0 for the JDs thathave fractional part less than  0.5 and 1 for the rest
fracpart=jd-long(jd)
if (fracpart le 0.5) then value=0
if (fracpart gt 0.5) then value=1
return,value
end

PRO gfunct, X, A, F, pder
 F = A[0]*10^(-0.4*a[1]*x)
 ; calculate the partial derivatives.
 pder = [[F/a(0)],[F*(-0.4*alog(10)*x)]]
 END
 
 nlimit=3	; minimum points per filter per night
 jdstrs=['2456063', '2455944', '2456091', '2455943', '2456074', '2456045', '2456061', '2456075', '2456015', '2456046', '2456073', '2456016'] 
 openw,91,'all_bulk_corrected_albedo.dat'
 openw,92,'bulk_nights.dat'
 maxairmass=-1e22
 filternames=['B','V','VE1','VE2','IRCUT']
 !P.charsize=1.8
 for ijd=0,n_elements(jdstrs)-1,1 do begin
     jdstr=jdstrs(ijd)
     for idx_filter=1,5,1 do begin	; USE 1,2,3,4,5 for B V VE1 VE2 and IRCUT
         filtnam=filternames(idx_filter-1)
         ; build the file to read in
         fname=strcompress('plotme_'+string(idx_filter)+'.'+JDstr,/remove_all)
         print,'Trying ',fname
         str="awk '$6 == "+string(idx_filter)+" {print $2,$4,$5,$7,$3,$6}' alldata.dat | grep "+jdstr+" > "+fname
         ;print,str
         spawn,str
         if (file_lines(fname) gt 3) then begin
             data=get_data(fname)
             airma=reform(data(3,*))
             idx=where(airma le 3.5)
             data=data(*,idx)
             jd=reform(data(0,*))
             alb=reform(data(1,*))
             alberr=reform(data(2,*))
             airma=reform(data(3,*))
             phase=reform(data(4,*))
             filter=fix(reform(data(5,*)))
             n=n_elements(airma)
             if (n ge nlimit ) then begin
                 ;
                 weights = 1.0/alberr^2
                 ;Provide an initial guess of the function’s parameters.
                 A = [0.3,0.04]
                 yfit = CURVEFIT(airma, alb, weights, A, SIGMA, FUNCTION_NAME='gfunct',status=stat,/DOUBLE,chisq=chi2)
                 chi2red=chi2/(n_elements(airma)-2)
                 print,'Status: ',stat,' chi2: ',chi2
		 if (stat ne 0) then stop
                 print,'Fits: ',a
                 print,'Sigs: ',sigma
                 gfunct,airma,a,alb_fitted
                 !P.MULTI=[0,1,2]
                 plot,airma,alb,psym=7,xstyle=3,title=JDstr+' '+filtnam,ystyle=3,xtitle='Airmass',ytitle='Observed Alæbedo (X), Fitted (red line)',yrange=[0.15,.5],xrange=[1.0,4]
                 ;plot,airma,alb,psym=7,xstyle=3,title=JDstr+' '+filtnam,ystyle=3,xtitle='Airmass',ytitle='Observed Alæbedo (X), Fitted (red line)',yrange=[min(alb),max(alb*(a(0)/alb_fitted))]
                 oploterr,airma,alb,alberr
                 oplot,airma,yfit,color=fsc_color('red')
                 corrected_albedo=alb*(a(0)/alb_fitted)
                 oplot,airma,corrected_albedo,psym=7,color=fsc_color('red')
                 xyouts,/normal,0.1,0.2,strcompress('Albedo at Z=0: '+string(a(0),format='(f6.4)')+' +/- '+string(sigma(0)/a(0)*100.,format='(f4.2)')+' %, or '+string(sigma(0),format='(f6.4)')),charsize=1.6
                 xyouts,/normal,0.1,0.15,strcompress('!7D!3k: '+string(a(1),format='(f6.4)')+' +/- '+string(sigma(1)/a(1)*100.,format='(f5.2)')+' %, or '+string(sigma(1),format='(f6.4)')),charsize=1.6
                 xyouts,/normal,0.6,0.8,'Chi!u2!n= '+string(chi2,format='(f6.1)')
                 xyouts,/normal,0.6,0.75,'Chi!u2!n!dred!n= '+string(chi2red,format='(f6.1)')
                 printf,92,format='(a10,1x,f7.2,1x,i2,5(1x,f9.4))',jdstr,median(phase),idx_filter,a(0),sigma(0),a(1),sigma(1),chi2red
                 if (max(airma) gt maxairmass) then maxairmass=max(airma)
		 for k=0,n_elements(corrected_albedo)-1,1 do begin
	            BSis=findBS(jd(k))
    	            print,format='(f15.7,1x,f7.2,1x,i2,1x,f9.5,1x,i2)',jd(k),phase(k),filter(k),corrected_albedo(k),BSis
    	            printf,91,format='(f15.7,1x,f7.2,1x,i2,1x,f9.5,1x,i2)',jd(k),phase(k),filter(k),corrected_albedo(k),BSis
		 endfor
                 endif else begin
                 print,'n= ',n,' which is too little'
                 endelse
             endif
         endfor
     endfor
 close,92
 close,91
 print,'MAX airmass is: ',maxairmass
 end
