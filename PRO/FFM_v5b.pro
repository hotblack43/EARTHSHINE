PRO gostripthename,str,name
 xx=strpos(str,'Lu')
 name=strmid(str,xx,strlen(str)-xx)
 return
 end

 PRO getfilenamefrompath,path,filename
 gostripthename,path,filename
 return
 end

 FUNCTION get_mean_flux_in_box,im
 xl=283
 xr=309
 yd=309
 yu=326
 subim=im(xl:xr,yd:yu)
 idx=where(finite(subim) eq 1)
 ; RMSE
 res=sqrt(mean(subim(idx)^2))
 ; abs mean error
 ;res=abs(mean(subim(idx)))
 return,res
 end
 
 
 FUNCTION get_errorINwholeIMAGE,im
 idx=where(finite(im) eq 1)
 ; RMSE
 res=sqrt(mean(im(idx)^2))
 return,res
 end

 FUNCTION minimize_me, X, Y, P
 l=size(x,/dimensions)
 n=l(0)
 ; should return the model i.e. the a+b*P.conv.Ideal thing
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage
 common errs,functionvalue,residual2BOX
 ; The independent variables are X and Y
 a=p(0)
 alfa=p(1)
 albedo=p(2)
; set up the ideal image wighted by albedo
 wideal=(1.-albedo)*blackimage + albedo*whiteimage
 writefits,'ideal_in.fits',wideal
 str='./justconvolve ideal_in.fits ideal_folded_out.fits '+string(alfa)
 spawn,str
 ideal_folded=readfits('ideal_folded_out.fits',/silent)
 b=(total(observed,/double)-a*float(n)*float(n))/total(ideal_folded,/double)
 trialim=a+b*ideal_folded
 residual=(observed-trialim)/observed*100.0
 ; evaluate model fit in a box
 ;functionvalue=get_mean_flux_in_box(residual)
 ; or on whole image
 functionvalue=get_errorINwholeIMAGE(residual)
 ; get ideal error inside BOX
 residual2=((b*ideal)-idealused)/idealused*100.0
 residual2BOX=get_mean_flux_in_box(residual2)
 ; print out some results
 print,'----------------->',p,functionvalue,residual2BOX
 return, residual
 END
 
 FUNCTION petersfunc2,par
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage
 common errs,functionvalue,residual2BOX
 l=size(observed,/dimensions) & n=l(0)
 a=par(0)
 alfa=par(1)
 albedo=p(2)
; set up the ideal image wighted by albedo
 wideal=(1.-albedo)*blackimage + albedo*whiteimage
 writefits,'ideal_in.fits',wideal
 str='./justconvolve ideal_in.fits ideal_folded_out.fits '+string(alfa)
 spawn,str
 ideal_folded=readfits('ideal_folded_out.fits',/silent)
 b=(total(observed,/double)-a*float(n)*float(n))/total(ideal_folded,/double)
 trialim=a+b*ideal_folded
 residual=(observed-trialim)/observed*100.0
 ; evaluate model fit in a box
 functionvalue=get_mean_flux_in_box(residual)
 ; or on whole image
 functionvalue=get_errorINwholeIMAGE(residual)
 ; get ideal error inside BOX
 residual2=((b*ideal)-idealused)/idealused*100.0
 residual2BOX=get_mean_flux_in_box(residual2)
 ; print out some results
 print,'----------------->',par,functionvalue,residual2BOX
 ; plot some curves
 !P.MULTI=[0,1,4]
 plot_io,ytitle='Observed and Trial observed',xstyle=3,observed(*,256),thick=2,color=fsc_color('red'),yrange=[1,1e5]
 oplot,trialim(*,256)
 plot,xstyle=3,ytitle='Rel. Diff Observed and Trial observed',$
 ystyle=3,(observed(*,256)-trialim(*,256))/observed(*,256)*100.0,$
 thick=2,color=fsc_color('blue')
 ;
 plot_io,ytitle='Ideal and Trial ideal',xstyle=3,idealused(*,256),thick=2,color=fsc_color('red'),yrange=[1,1e5]
 oplot,b*ideal(*,256),thick=1
 ;oplot,a+b*ideal(*,256),thick=1
 plot,xstyle=3,yrange=[-2,2],(idealused(*,256)-(b*ideal(*,256)))/idealused(*,256)*100.0,thick=2,color=fsc_color('blue'),psym=7
 ;plot,xstyle=3,yrange=[-2,2],(ideal(*,256)-(a+b*ideal(*,256)))/ideal(*,256)*100.0,thick=2,color=fsc_color('blue'),psym=7
 plots,[!X.crange],[0,0],linestyle=2
 ;
 return,functionvalue
 end
 
 
 
 ;----------------------------------------------------
 ; version 5b of Full Forward Method
 ; will loop over many images
 ; Like version 5 but uses version of syntheticmoon that requires a seed
 ;----------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage
 common errs,functionvalue,residual2BOX
 path='/data/pth/RESULTS/'
 path='/media/SAMSUNG/'
 openw,82,'allresults_FFM_v5.txt'
 files=file_search(path+'INPUT/IDEAL/SCA_0p297/Lu*',count=nfiles)
 print,' Found ',nfiles,' files.'
 for ifil=0,nfiles-1,1 do begin
 getfilenamefrompath,files(ifil),filename
 ; load up the two special white and black ideal images
 blackimage=readfits(path+'INPUT/IDEAL/SCA_0p000/'+filename)
 whiteimage=readfits(path+'INPUT/IDEAL/SCA_1p000/'+filename)
 ; define some real-world effects
 factor=3.78
 pedestal=400.0
 ; generate a synthetic observed image
 spawn,'cp '+path+'/INPUT/IDEAL/SCA_0p297/'+filename+' ideal_in.fits'
 ideal=readfits('ideal_in.fits')
 idealused=ideal*factor
 writefits,'usethisidealimage.fits',idealused
 ;spawn,'./syntheticmoon usethisidealimage.fits synth_observed_1p6.fits 1.6 100 8745'
 ;spawn,'./syntheticmoon usethisidealimage.fits synth_observed_1p7.fits 1.7 100 8745'
 spawn,'./syntheticmoon usethisidealimage.fits synth_observed_1p8.fits 1.7 100 8745'
;..........
;seed=long((systime(/seconds)/1e9-1)*1e8)
;spawnstr='./syntheticmoon usethisidealimage.fits synth_observed_1p8.fits 1.8 1 '+string(seed)
;spawn,spawnstr
;print,'spawned:',spawnstr
;..........
 ; get the observed image
 ;observed=readfits('synth_observed_1p6.fits',/silent)+pedestal
 ;observed=readfits('synth_observed_1p7.fits',/silent)+pedestal
 observed=readfits('synth_observed_1p8.fits',/silent)+pedestal
 l=size(observed,/dimensions) & n=l(0)
 obsBOX=get_mean_flux_in_box(observed)
 ; get the ideal image for time of observation
 ideal=readfits('ideal_in.fits',/silent)
 idealBOX=get_mean_flux_in_box(ideal)
 imethod=2	; =1 is POWELL =2 is LMFITFUN
 if (imethod eq 1) then begin
stop	; not modified for 3 parameters yet
     ; select starting values of the parameters
     a=mean(observed(0:20,0:20))	; base starting guess on corner value
     alfa=1.6
     par=[a,alfa]
     ;par=[a,alfa,b]
     xi=[[0,1],[1,0]]
     ;xi=[[0,0,1],[0,1,0],[1,0,0]]
     ftol=1.e-6
     POWELL,par,xi,ftol,fmin,'petersfunc2'
     print,'Done. pars: ',par
     print,'ftol,fmin:',ftol,fmin
     a=par(0)
     alfa=par(1)
     endif
 if (imethod eq 2) then begin
     ; Define the starting point:
     a=400.0d0+randomn(seed)
     alfa=1.60d0+randomn(seed)/10.
     albedo=0.3+randomn(seed)/3.
     start_parms = [a,alfa,albedo]
     ; Find best parameters using MPFIT2DFUN method
     l=size(ideal,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
     err=1./sqrt(observed) & err=err*sqrt(3090.*0.0099)
     z=ideal*0.0	; target is a zero plane
     ; set up the PARINFO array - indicate double-sided derivatives (best)
     parinfo = replicate({mpside:2, value:0.D, $
     fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-4}, 3)
     parinfo[0].fixed = 0
     parinfo[1].fixed = 0
     parinfo[2].fixed = 0
     ; offset
     parinfo[0].limited(0) = 0
     parinfo[0].limits(0)  = 300
     parinfo[0].limited(1) = 0
     parinfo[0].limits(1)  = 500.
     ; alfa
     parinfo[1].limited(0) = 0
     parinfo[1].limits(0)  = 1.2
     parinfo[1].limited(1) = 0
     parinfo[1].limits(1)  = 2.0
     ; albedo
     parinfo[2].limited(0) = 0
     parinfo[2].limits(0)  = 0.1
     parinfo[2].limited(1) = 0
     parinfo[2].limits(1)  = 0.4
     parinfo[*].value = start_parms
     ; print,parinfo
     results = MPFIT2DFUN('minimize_me', X, Y, Z, ERR, $
     PARINFO=parinfo,perror=sigs,STATUS=hej,xtol=1e-15)
     ; Print the solution point:
     print,'STATUS=',hej
     PRINT, 'Solution point: ', results(0),' +/- ',sigs(0),' or ',sigs(0)/results(0)*100.,' % error.'
     PRINT, 'Solution point: ', results(1),' +/- ',sigs(1),' or ',sigs(1)/results(1)*100.,' % error.'
     PRINT, 'Solution point: ', results(2),' +/- ',sigs(2),' or ',sigs(2)/results(2)*100.,' % error.'
     endif
 ; print out some results
 fmt='(3(1x,f9.5),1x,g12.1,2(1x,f12.6))'
 fmt2='(6(1x,f11.7),2(1x,f12.6),2(1x,i3))'
 print,format=fmt2,results(0),sigs(0),results(1),sigs(1),results(2),sigs(2),functionvalue,residual2BOX,ifil,hej
 printf,82,format=fmt2,results(0),sigs(0),results(1),sigs(1),results(2),sigs(2),functionvalue,residual2BOX,ifil,hej
 endfor	; end of loop over files
 close,82
 end
