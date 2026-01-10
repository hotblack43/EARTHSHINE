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
 rho=911.
 ; imethod = 1 is OLS
 if (imethod eq 1) then begin
     coefficients=linfit(x,y,/double)
     endif
 ; imethod = 2 is Cochrane-Orcutt
 if (imethod eq 2) then begin
     coefficients=co_regress(x,y, /DOUBLE, const=konst,rho=rho)
     coefficients=[konst,coefficients]
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
     coefficients=co_regress(y,x, /DOUBLE, yfit=yhat,const=konst,rho=rho)
     coefficients=[konst,coefficients]
     a=coefficients(0)
     b=coefficients(1)
     coefficients=[-a/b,1.d0/b]
     endif
 return
 end
 
 ; Version 10
 ; code to test OLS vs CO on recosntruction simulations
 ; has a training set and a validation set
 ; and calculates the 'real' mean T and the 'proxy-based mean T'
 ; and compare these for OLS and CO
 ; Uses a range of AC1s
 ; Can do indirect OLS as well as indirect CO
 ; also estimates skill to reconstruct slope b
;---------------------------------------------------------------------
 openw,55,'medianresults.txt'
 device_name='X'
 device_name='ps'
 set_plot,device_name
 n_worlds=150	;	number of worlds
 n_world_points=150	; number of 'grid points' in each world
 n=150	; length of each series
 index=indgen(n)
 boundary=0.7
 if_plot=0	; plot every series or not
 idx=where(index gt boundary*n)	; training set
 ;jdx=where(index lt boundary*n)	; validation set
 jdx=where(index lt (1.-boundary)*n)	; validation set
 eta=1.0	; amplitude of noise
 for noiseAC1=.75,1.00,0.025 do begin	;	AC1 of noise
     print,' AC1=',noiseAC1
     printf,55,' AC1=',noiseAC1
     a=1.0
     b=1.0
     !P.charsize=2
     !P.thick=2
     openw,44,'superstats.dat'
     for world_loop=0,n_worlds-1,1 do begin
         ;print,'World #: ',world_loop,' AC1=',noiseAC1
         openw,33,'skills.dat'
         for iloop=0,n_world_points-1,1 do begin
             ; generate red series
             dummy=randomu(seed,n) ; this is white noise
             locTemp=pseudo_t_guarantee_ac1(dummy,0.77,1,seed)	; now it is red with ac1=0.77
             locTemp=locTemp+(randomu(seed)-0.5)*findgen(n)/float(n/5.) ; now it also has a random linear slope
             noise=pseudo_t_guarantee_ac1(dummy,noiseAC1,1,seed)	; this is red noise     ; now generate the proxy from the local Temperature
             proxy=a+b*(locTemp+eta*noise)
             target=locTemp(jdx)
             ;---------------------------------------------------------------
             ; peform OLS
             imethod=1	; do OLS
             do_reg,proxy(idx),locTemp(idx),ols,rho,imethod
             recon_OLS=(ols(0)+ols(1)*proxy(jdx))
             evaluate_skill,target,recon_OLS,skills_OLS,ols,[a,b]
             ;---------------------------------------------------------------
             ; perform CO
             imethod=2	; do CO
             do_reg,proxy(idx),locTemp(idx),co,rho,imethod
             recon_CO=(co(0)+co(1)*proxy(jdx))
             evaluate_skill,target,recon_CO,skills_CO,co,[a,b]
             ;---------------------------------------------------------------
             ; perform indirect OLS
             imethod=3	; do indirect OLS
             do_reg,proxy(idx),locTemp(idx),ols_indir,rho,imethod
             recon_OLS_indir=(ols_indir(0)+ols_indir(1)*proxy(jdx))
             evaluate_skill,target,recon_OLS_indir,skills_OLS_indir,ols_indir,[a,b]
             ;---------------------------------------------------------------
             ; perform indirect OLS
             imethod=4	; do indirect CO
             do_reg,proxy(idx),locTemp(idx),co_indir,rho,imethod
             recon_co_indir=(co_indir(0)+co_indir(1)*proxy(jdx))
             evaluate_skill,target,recon_co_indir,skills_co_indir,co_indir,[a,b]
             ;---------------------------------------------------------------
             ; plotting
             
             if (device_name eq 'Win' and if_plot eq 1) then begin
                 !P.MULTI=[0,1,2]
                 window,0,xsize=600,ysize=990
                 endif
             if (if_plot eq 1) then begin
                 !P.LINESTYLE=0
                 plot,noise,charsize=2,ytitle='Noise'
                 oplot,[boundary*n,boundary*n],[!Y.CRANGE],linestyle=2
                 ; plot the un-noisy local T with yhats on top
                 plot,locTemp,charsize=2,ytitle='T and reconstructions',title='T: black, red: OLS, blue: CO, green: OLS_indir, yellow: CO indir'
                 oplot,ols(0)+ols(1)*proxy,color=fsc_color('red')
                 oplot,co(0)+co(1)*proxy,color=fsc_color('blue')
                 oplot,ols_indir(0)+ols_indir(1)*proxy,color=fsc_color('green')
                 oplot,co_indir(0)+co_indir(1)*proxy,color=fsc_color('yellow')
                 oplot,[boundary*n,boundary*n],[!Y.CRANGE],linestyle=2
                 endif
             !P.LINESTyLE=0
             ; print the skills into file 33
             printf,33,format='(24(1x,f15.7))',skills_OLS,skills_CO,skills_OLS_indir,skills_co_indir
             endfor	; loop over grid point
         close,33
         data=get_data('skills.dat')
         ;data=get_dataXX('skills.dat')
         if (device_name eq 'Win' and if_plot eq 1) then begin
             window,2,xsize=600,ysize=990
             endif
         if (if_plot eq 1) then begin
             !P.MULTI=[0,1,4]
             plot_histo,data,2,8,14,'Rel Bias'
             plot_histo,data,3,9,15,'Lo freq var'
             plot_histo,data,4,10,16,'Rel Trend'
             plot_histo,data,5,11,17,'Slope [b] Bias'
             endif
         ; generate som stats on the stats
         z=fltarr(24)
         for ii=0,23,1 do z(ii)=median(reform(data(ii)))
         printf,44,format='(24(1x,f12.5))',z
         endfor	; end of worlds loop
     close,44
     data=get_data('superstats.dat')
     ;data=get_dataXX('superstats.dat')
     !P.multi=[0,1,4]
     tstr=['R','R!dlo!n','RelBias','RelLoVar','RelTrend','SlopeBias']
     if (device_name eq 'Win') then begin
         window,2,xsize=600,ysize=990
         endif
     
     for k=2,5,1 do begin
         !P.LINESTYLE=0
             minval=-3
             maxval=3
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
         ;
         printf,55,tstr(k),median(reform(data(k,*))),median(reform(data(k+6,*))),median(reform(data(k+12,*))),median(reform(data(k+18,*)))
         endfor	; end of k loop
     
     endfor	; end loop over noiseAC1
 close,55
 end
