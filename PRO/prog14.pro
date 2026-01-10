PRO generate_x_and_y,icase,n,noiseAC1,a,b,eta,target,proxy,loctemp,noise
 ;----------------------------------------------------------------------------
 ; INPUTS	: icase - 1 is make proxy noise - 2 is make target noisy . 3 does both
 ;                n - length of series
 ;		  noiseAC1 - the autocorrelation to use
 ;                a,b - the regression intercepts and slope
 ;                eta - the amplitud eof the noise to add to y
 ; OUTPUTS	: target - the temperature to find by reconstruction
 ; 		  proxy - the artificial T proxy from which to make reconstruction
 ;                loctemp - the artificial local temperature
 ;                noise - the AR1 noise added 
 ;----------------------------------------------------------------------------
 dummy=randomu(seed,n) ; this is white noise
 locTemp=pseudo_t_guarantee_ac1(dummy,0.77,1,seed)	; red with ac1=0.77
 ;locTemp=locTemp+(randomu(seed)-0.5)*findgen(n)/float(n/5.) ; add a random linear slope
 locTemp=locTemp+exp((indgen(n)-n*(12./15.))/30.0)	; add an exponential upturn
 noise=pseudo_t_guarantee_ac1(dummy,noiseAC1,1,seed)	; generate the noise as AR1
 if (icase eq 1) then begin
     ; Case 1 - add the noise to the local temperature before generating the proxy
     proxy=a+b*locTemp+eta*noise
     target=locTemp
     endif
 if (icase eq 2) then begin
     ; Case 2 - add the noise to the target
     proxy=a+b*(locTemp)
     target=locTemp+eta*noise
     endif
 if (icase eq 3) then begin
     ; Case 3 - add the noise to the target and the proxy
     noise2=pseudo_t_guarantee_ac1(dummy,noiseAC1,1,seed)	; generate the noise as AR1
     proxy=a+b*(locTemp)+eta*noise
     target=locTemp+eta*noise2
     endif
 return
 end
 
 PRO plot_histo,data,col1,col2,col3,title
 !P.LINESTYLE=0
 x1=reform(data(col1,*))
 x2=reform(data(col2,*))
 x3=reform(data(col3,*))
 histo,x1,-1.,1,0.15,xtitle=title
 !P.LINESTYLE=1
 histo,x2,-1.,1,0.15,/overplot
 !P.LINESTYLE=2
 histo,x3,-1.,1,0.15,/overplot
 ;print,format='(3(1x,f10.3),1x,a)',mean(x1),mean(x2),mean(x3),title
 return
 end
 
 PRO evaluate_skill,y,x,skills,ab_estimated,ab_actual
 ; y is the target
 ; x is the reconstruction
 ; evaluates 6 skills
 skills=fltarr(6)
 
 skills(0)=correlate(y,x)
 
 nsmoo=10
 skills(1)=correlate(smooth(y,nsmoo,/edge_truncate),smooth(x,nsmoo,/edge_truncate))
 
 skills(2)=(mean(x)-mean(y))/mean(y)
 
 sig_rec=stddev(smooth(x,nsmoo,/edge_truncate))
 sig_tar=stddev(smooth(y,nsmoo,/edge_truncate))
 skills(3)=(sig_rec-sig_tar)/sig_tar
 
 dum=linfit(indgen(n_elements(y)),y,/double)
 tau_tar=dum(1)
 dum=linfit(indgen(n_elements(x)),x,/double)
 tau_rec=dum(1)
 skills(4)=(tau_rec-tau_tar)/tau_tar
 
 skills(5)=(ab_estimated(1)-ab_actual(1))/ab_actual(1)
 
 return
 end
 
 
 PRO do_reg,x,y,coefficients,rho,imethod
 common sigs,x_sig_estimated,y_sig_estimated
 rho=911.
 ; imethod = 1 is OLS
 if (imethod eq 1) then begin
     coefficients=linfit(x,y,/double)
     endif
 ; imethod = 2 is Cochrane-Orcutt
 if (imethod eq 2) then begin
     ;     coefficients=co_regress(x,y, /DOUBLE, const=konst,rho=rho)
     ;     coefficients=[konst,coefficients]
     ;---------PTH CO
     x=reform(x)
     ARRAY=[transpose(y),transpose(x)]
     cochraneorcutt,ARRAY,const,res,yfit,BOOT_C_O_sigs
     coefficients=[const,res]
     ;---------end PTH CO
     endif
 ; imethod = 3 is indirect OLS
 if (imethod eq 3) then begin
     coefficients=linfit(y,x,/double)
     a=coefficients(0)
     b=coefficients(1)
     coefficients=[-a/b,1.d0/b]
     endif
 ; imethod = 4 is indirect CO
 if (imethod eq 4) then begin
     ;     coefficients=co_regress(y,x, /DOUBLE, yfit=yhat,const=konst,rho=rho)
     ;     coefficients=[konst,coefficients]
     ;---------PTH CO
     x=reform(x)
     ARRAY=[transpose(x),transpose(y)]
     cochraneorcutt,ARRAY,const,res,yfit,BOOT_C_O_sigs
     coefficients=[const,res]
     ;---------end PTH CO
     a=coefficients(0)
     b=coefficients(1)
     coefficients=[-a/b,1.d0/b]
     endif
 if (imethod eq 5) then begin
	FITEXY, x, y, A, B, X_SIG=x_sig_estimated , Y_SIG=y_sig_estimated 
        coefficients=[a,b]
 endif
 return
 end
 
 ; Version 14
 ; code to test OLS vs CO on recosntruction simulations
 ; has a training set and a validation set
 ; and calculates the 'real' mean T and the 'proxy-based mean T'
 ; and compare these for OLS and CO
 ; Uses a range of AC1s
 ; Can do indirect OLS as well as indirect CO
 ; also estimates skill to reconstruct slope b
 ; makes a time-trend (not linear) in the x
 ; can choose 'add noise to y' or 'add noise to x'
 ; also does FITECY as one of the regression methods
 ;---------------------------------------------------------------------
 openr,25,'experiment.name'
 name_str='_16'	; a string with some sort of name for various files
 readf,25,name_str
 close,25
 
 openw,82,strcompress('Settings'+name_str+'.dat',/remove_all)
 common sigs,x_sig_estimated,y_sig_estimated
 icount=0
 openw,55,strcompress('medianresults'+name_str+'.txt',/remove_all)
 device_name='X'
 device_name='ps'
 set_plot,device_name
 n_worlds=100	;	number of worlds
 n_world_points=100	; number of 'grid points' in each world
 n=150	; length of each series
 nmethods=5	; number of regressionmethods considered (OLS,CO,OLS-I,CO-I, and FITEXY)
 index=indgen(n)
 boundary=0.7
 if_plot=0	; plot every series or not
 test_type=3	; choose whether to test on all contiguous data or mirror-symmetric or
                ; a fractionof contiguous data (i.e. near training interval)
 idx=where(index gt boundary*n)	; training set
 if (test_type eq 1) then jdx=where(index lt boundary*n)	; validation set
 if (test_type eq 2) then jdx=where(index lt (1.-boundary)*n)	; validation set
 if (test_type eq 3) then jdx=where(index lt boundary*n and index gt n-(1-boundary)*2*n)	; validation set
 a=1.0
 b=1.0
 eta=1.0	; amplitude of noise
 icase=3	; 1: add noise to proxy, 2: add noise to target, 3: to both
 if (icase eq 1) then begin
 x_sig_estimated=eta	; estimate the size of error on x
 y_sig_estimated=0.0	; estimate the size of error on y
 endif
 if (icase eq 2) then begin
 x_sig_estimated=0.0	; estimate the size of error on x
 y_sig_estimated=eta	; estimate the size of error on y
 endif
 if (icase eq 3) then begin
 x_sig_estimated=eta	; estimate the size of error on x
 y_sig_estimated=eta	; estimate the size of error on y
 endif
;...........................
 printf,82,'n_worlds :',n_worlds
 printf,82,'n_world_poinys :',n_world_points
 printf,82,'n :',n
 printf,82,'nmethods :',nmethods
 printf,82,'a,b :',a,b
 printf,82,'eta :',eta
 printf,82,'icase,x_sig_estimated,y_sig_estimated :',icase,x_sig_estimated,y_sig_estimated
 printf,82,'(fraction at which to split series for train/test) boundary :',boundary
 printf,82,'test_type (1:contiguous, 2:mirror-symmetric) :',test_type
;...........................
 for noiseAC1=.75,1.00,0.025 do begin	;	AC1 of noise
     print,' AC1=',noiseAC1
     !P.charsize=2
     !P.thick=2
     openw,44,'superstats.dat'
     for world_loop=0,n_worlds-1,1 do begin
         openw,33,'skills.dat'
         for iloop=0,n_world_points-1,1 do begin
             ; generate red x and y(x) series
             generate_x_and_y,icase,n,noiseAC1,a,b,eta,target,proxy,loctemp,noise
             ;---------------------------------------------------------------
             ; peform OLS
             imethod=1	; do OLS
             do_reg,proxy(idx),locTemp(idx),ols,rho,imethod
             recon_OLS=(ols(0)+ols(1)*proxy(jdx))
             evaluate_skill,target(jdx),recon_OLS,skills_OLS,ols,[a,b]
             ;---------------------------------------------------------------
             ; perform CO
             imethod=2	; do CO
             do_reg,proxy(idx),locTemp(idx),co,rho,imethod
             recon_CO=(co(0)+co(1)*proxy(jdx))
             evaluate_skill,target(jdx),recon_CO,skills_CO,co,[a,b]
             ;---------------------------------------------------------------
             ; perform indirect OLS
             imethod=3	; do indirect OLS
             do_reg,proxy(idx),locTemp(idx),ols_indir,rho,imethod
             recon_OLS_indir=(ols_indir(0)+ols_indir(1)*proxy(jdx))
             evaluate_skill,target(jdx),recon_OLS_indir,skills_OLS_indir,ols_indir,[a,b]
             ;---------------------------------------------------------------
             ; perform indirect OLS
             imethod=4	; do indirect CO
             do_reg,proxy(idx),locTemp(idx),co_indir,rho,imethod
             recon_co_indir=(co_indir(0)+co_indir(1)*proxy(jdx))
             evaluate_skill,target(jdx),recon_co_indir,skills_co_indir,co_indir,[a,b]
             ;---------------------------------------------------------------
             ; perform indirect OLS
             imethod=5	; do FITEXY
             do_reg,proxy(idx),locTemp(idx),coeff_fitexy,rho,imethod
             recon_fitexy=(coeff_fitexy(0)+coeff_fitexy(1)*proxy(jdx))
             evaluate_skill,target(jdx),recon_fitexy,skills_fitexy,coeff_fitexy,[a,b]
             ;---------------------------------------------------------------
             ; plotting
             !P.MULTI=[0,1,2]
             
             if ((device_name eq 'Win' and if_plot eq 1)) then begin
                 window,0,xsize=600,ysize=990
                 endif
             if (if_plot eq 1) then begin
                 !P.LINESTYLE=0
                 ; plot the un-noisy local T with yhats on top
                 plot,locTemp,charsize=1.1,ytitle='T and reconstructions',title='T: K, R: OLS, B: CO, G: OLS_indir, Y: CO indir, CY: FITEXY'
                 oplot,locTemp,thick=4
                 !P.thick=2
                 oplot,ols(0)+ols(1)*proxy,color=fsc_color('red')
                 oplot,co(0)+co(1)*proxy,color=fsc_color('blue')
                 oplot,ols_indir(0)+ols_indir(1)*proxy,color=fsc_color('green')
                 oplot,co_indir(0)+co_indir(1)*proxy,color=fsc_color('yellow')
                 oplot,coeff_fitexy(0)+coeff_fitexy(1)*proxy,color=fsc_color('cyan')
                 oplot,[boundary*n,boundary*n],[!Y.CRANGE],linestyle=2
                 endif
             !P.LINESTyLE=0
             ; print the skills into file 33
;             printf,33,format='(24(1x,f15.7))',skills_OLS,skills_CO,skills_OLS_indir,skills_co_indir
             printf,33,format='('+string(6*nmethods)+'(1x,f14.6))',skills_OLS,skills_CO,skills_OLS_indir,skills_co_indir,skills_fitexy
             endfor	; loop over grid point
         close,33
         data=get_data('skills.dat')
         ;data=get_dataXX('skills.dat')
         if (device_name eq 'Win' and if_plot eq 1) then begin
             window,2,xsize=600,ysize=990
             endif
         !P.MULTI=[0,1,4]
         if (if_plot eq 1) then begin
             plot_histo,data,2,8,14,'Rel Bias'
             plot_histo,data,3,9,15,'Lo freq var'
             plot_histo,data,4,10,16,'Rel Trend'
             plot_histo,data,5,11,17,'Slope [b] Bias'
             plots,[0,0],[!Y.crange]
             endif
         ; generate som stats on the stats
         z=fltarr(6*nmethods)
         for ii=0,6*nmethods-1,1 do z(ii)=median(reform(data(ii)))
         printf,44,format='('+string(6*nmethods)+'(1x,f12.5))',z
         endfor	; end of worlds loop
     close,44
     data=get_data('superstats.dat')
     ;data=get_dataXX('superstats.dat')
     tstr=['R','R!dlo!n','RelBias','RelLoVar','RelTrend','SlopeBias']
     if (device_name eq 'Win') then begin
         window,2,xsize=600,ysize=990
         endif
     !P.multi=[0,1,4]
     for k=2,5,1 do begin
         !P.LINESTYLE=0
         minval=-2
         maxval=2
         binsize=0.15
         histo,reform(data(k,*)),minval,maxval,binsize,xtitle=tstr(k),title=strcompress('AC1: '+string(noiseAC1),/remove_all)
         !P.LINESTYLE=1
         histo,reform(data(k+6,*)),minval,maxval,binsize,/overplot
         !P.LINESTYLE=2
         histo,reform(data(k+12,*)),minval,maxval,binsize,/overplot
         minval=-2
         maxval=2
         !P.LINESTYLE=3
         histo,reform(data(k+18,*)),minval,maxval,binsize,/overplot
         !P.LINESTYLE=4
         histo,reform(data(k+24,*)),minval,maxval,binsize,/overplot
         ;
         printf,55,format='(a20,'+string(nmethods+1)+'(1x,f15.7))',tstr(k),noiseAC1,median(reform(data(k,*))),median(reform(data(k+6,*))),median(reform(data(k+12,*))),median(reform(data(k+18,*))),median(reform(data(k+24,*)))
         endfor	; end of k loop
     icount=icount+1    
     endfor	; end loop over noiseAC1
 close,55
 close,82
 end
