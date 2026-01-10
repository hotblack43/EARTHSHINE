FUNCTION instantaneous_albedo,days
 ; generate list of albedos plucked from a sine-curve function with noise added
 n=n_elements(days)
 period=366.
 meanalbedo=0.3
 albedonoise=0.1
 annualamplitude=0.01*meanalbedo
 for i=0,n-1,1 do begin
     noise=albedonoise*meanalbedo*randomn(seed)
     albedo=meanalbedo+annualamplitude*sin(days(i)/period*!pi*2.)+noise
     if (i eq 0) then value=albedo
     if (i gt 0) then value=[value,albedo]
     endfor
 return,value
 end
 ; Asuume that we can observe for 10 years
 ; Assume we can have 100 nights a year, but always some monthly mean
 ; then which limits can be set on Nul Hypothesis: "no albedo change"
 ;
 
 ; Monthly data
 data=get_data('monthly_CERES_climatology.dat')
 mo=reform(data(0,*))
 alb=reform(data(1,*))
 sd=reform(data(2,*))
 ;
 nyears=10	; observinmg for this many years
 nightsperyear=50*2 ; getthi smany goo dnights per year - but always good values each month!
 nMC=5000
 for iMC=0,nMC-1,1 do begin
     nmo=10*12
     openw,33,'p.dat'
     for imo=0,nmo-1,1 do begin
         idx=imo mod 12
         albedo=alb(idx)+randomn(seed)*sd(idx)
         printf,33,imo,albedo
         endfor
     close,33
     data=get_data('p.dat')
     x=reform (data(0,*))
     y=reform (data(1,*))
     ; get the climatology
     iptr=x mod 12
     climat=fltarr(12)
     for ijk=0,11,1 do begin
         idx=where(iptr eq ijk)
         climat(ijk)=mean(y(idx))
         endfor 
     climato=climat
     for i=1,9,1 do begin
         climato=[climato,climat]
         endfor
     ;plot,x,y-climato,ystyle=3
     res=linfit(x,y-climato,/double,yfit=yhat,sigma=sigs)
     pctchangeover10yeasr=(yhat(nmo-1)-yhat(0))/mean(y)*100.
     if (iMC eq 0) then liste=pctchangeover10yeasr
     if (iMC gt 0) then liste=[liste,pctchangeover10yeasr]
     endfor
 histo,xtitle='% of mean',title='MC sims for CERES-type data',liste,min(liste),max(liste),(max(liste)-min(liste))/33.
 liste=liste(sort(liste))
 fifthpercentile=liste(0.05*nMC)
 ninetyfifthpercentile=liste(0.95*nMC)
 print,format='(3(a,f9.4))','5 th: ',fifthpercentile,' median: ',median(liste),' 95 th: ',ninetyfifthpercentile
 signature,'model_selection_effects_albedo.pro'
 plots,[fifthpercentile,fifthpercentile],!Y.crange,linestyle=2
 plots,[ninetyfifthpercentile,ninetyfifthpercentile],!Y.crange,linestyle=2
 xpos=!x.crange(0)+0.1*(!x.crange(1)-!x.crange(0))
 ypos=!y.crange(0)+0.9*(!y.crange(1)-!y.crange(0))
 txt='N!dyears!n='+string(fix(nyears))
 xyouts,xpos,ypos,txt
 ;
 ; Next, model instantaneous measurements with e.g. 10% S.D.
 ;
 nobs=nightsperyear*nyears	; 100 nights per year for ten years
 ndays=366*nyears
 nMC=5000
 for iMC=0,nMC-1,1 do begin
     days=randomu(seed,nobs)*ndays	; pointers to the days we can observe in
     albedos=instantaneous_albedo(days)
     ;plot,days mod 366,albedos,psym=7,ystyle=3
     res=linfit(days,albedos,yfit=yhat,/double,sigma=sigs)
     pctchange=(yhat(nobs-1)-yhat(0))/mean(albedos)*100.0
     if (iMC eq 0) then liste=pctchange
     if (iMC gt 0) then liste=[liste,pctchange]
     endfor
 histo,title='MC sims of Instantaneous observations',xtitle='% of mean',liste,min(liste),max(liste),(max(liste)-min(liste))/33.
 liste=liste(sort(liste))
 fifthpercentile=liste(0.05*nMC)
 ninetyfifthpercentile=liste(0.95*nMC)
 print,format='(3(a,f9.4))','5 th: ',fifthpercentile,' median: ',median(liste),' 95 th: ',ninetyfifthpercentile
 signature,'model_selection_effects_albedo.pro'
 plots,[fifthpercentile,fifthpercentile],!Y.crange,linestyle=2
 plots,[ninetyfifthpercentile,ninetyfifthpercentile],!Y.crange,linestyle=2
 xpos=!x.crange(0)+0.1*(!x.crange(1)-!x.crange(0))
 ypos=!y.crange(0)+0.9*(!y.crange(1)-!y.crange(0))
 txt='N!dgood!n='+string(fix(nightsperyear))
 xyouts,xpos,ypos,txt
 ypos=!y.crange(0)+0.85*(!y.crange(1)-!y.crange(0))
 txt='N!dyears!n='+string(fix(nyears))
 xyouts,xpos,ypos,txt
 end
