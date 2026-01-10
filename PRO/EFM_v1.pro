PRO get_mask,x0,y0,radius,mask
 ; build a 1/0 mask that is a circle (center x0,y0) and radius r with 1's outside radius and 0's inside
 common sizes,l
 nx=l(0) & ny=l(1) & mask=fltarr(nx,ny)
 for i=0,nx-1,1 do begin
     for j=0,ny-1,1 do begin
         rad=sqrt((i-x0)^2+(j-y0)^2)
         if (rad ge radius) then mask (i,j)=1 else mask(i,j)=0.0
         endfor
     endfor
 return
 end
 
 PRO gogetjulianday,header,jd
 idx=strpos(header,'JULIAN')
 str=header(where(idx ne -1))
 jd=double(strmid(str,15,15))
 return
 end
 
 
 FUNCTION get_mean_flux_in_box,im_in
 im=im_in
 im=smooth(im,7,/edge_truncate)
 xl=362
 xr=385
 yd=220
 yu=304
 subim=im(xl:xr,yd:yu)
 idx=where(finite(subim) eq 1)
 ; RMSE
 res=sqrt(mean(subim(idx)^2))
 return,res
 end
 
 
 FUNCTION get_errorINwholeIMAGE,im_in
 im=im_in
 im=smooth(im,7,/edge_truncate)
 idx=where(finite(im) eq 1)
 ; RMSE
 res=sqrt(mean(im(idx)^2))
 return,res
 end
 
 FUNCTION minimize_me, X, Y, P
 l=size(x,/dimensions)
 n=l(0)
 ; should return the error model - i.e. the image of the residuals
 common ims,ideal,observed,source,residual,ideal_residual,mask,trialim
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b
 common cutoff,cuttoffval
 ; The independent variables are X and Y
 a=p(0)
 alfa=p(1)
 ; generate a Source image from the observed image 
 ; subtracting t5he current guess ofr the offset
 im=observed-a
 ; generate the '1/75th' source image
 factor=cuttoffval
 idx=where(im lt max(smooth(im,3))/factor)
 im(idx)=0
 writefits,'source.fits',im
 ; then use that estimate of the source to fold etc
 str='./justconvolve source.fits ideal_folded_out.fits '+string(alfa)
 spawn,str
 ideal_folded=readfits('ideal_folded_out.fits',/silent)
 b=(total(observed,/double))/total(ideal_folded+a,/double)
 trialim=a+b*ideal_folded
 ; get residuals wrt observed image
 residual=(observed-trialim)/observed*100.0
 idx=where(finite(residual) ne 1)
 residual(idx)=0.0
 ; get residuals wrt ideal image
 ideal_residual=((observed-trialim)-b*ideal)/(b*ideal)*100.0
 idx=where(finite(ideal_residual) ne 1)
 ideal_residual(idx)=0.0
 ; evaluate model fit 
 errorwholeimage=get_errorINwholeIMAGE(mask*residual)
 errorinabox=get_mean_flux_in_box(residual)
 idealerrorinabox=get_mean_flux_in_box(ideal_residual)
 ; print out some results
 print,'----------------->',p,b,errorwholeimage
 !P.MULTI=[0,1,4]
 plot,observed(*,256),/ylog
 oplot,trialim(*,256),color=fsc_color('red')
 oplot,[!X.crange],[max(observed(*,256)),max(observed(*,256))],linestyle=2
 oplot,[!X.crange],[max(observed(*,256))/cuttoffval,max(observed(*,256))/cuttoffval],linestyle=2
 plot,observed(*,256),yrange=[390,600]
 oplot,trialim(*,256),color=fsc_color('red')
 plot,observed(*,256)-trialim(*,256),yrange=[-5,30]
 oplot,b*ideal(*,256),color=fsc_color('blue')
 plot,(observed(*,256)-trialim(*,256)-b*ideal(*,256))/b*ideal(*,256)*100.,yrange=[-10,10]
 return, residual*mask
 END
 
 
 ;------------------------------------------------------------------------
 ; version 1 of Emprirical Forward Method
 ;------------------------------------------------------------------------
 !P.CHARSIZE=2
 common ims,ideal,observed,source,residual,ideal_residual,mask,trialim
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b
 common sizes,l
 common cutoff,cuttoffval
 cuttoffval=65
 ; get the ideal image
 ideal=readfits('ideal_in.fits',/silent,header)
 ; scale it to something realistic
 ideal=ideal/max(ideal)*55000.0d0
 l=size(ideal,/dimensions)
 writefits,'ideal_used.fits',ideal
 ; generate the fake observed image from that
 spawn,'./syntheticmoon ideal_used.fits observed.fits 1.8 100 7654'
 ; read in the observed image
 observed=readfits('observed.fits')
 ; add some bias
 observed=observed+400.0
 writefits,'observed.fits',observed
 ; generate a Source image from the observed image 
 ; generate the '1/75th' source image
 im=observed
 factor=cuttoffval
 idx=where(im lt max(smooth(im,3))/factor)
 im(idx)=0
 writefits,'source.fits',im
 source=readfits('source.fits')
 ; generate the 1/0 mask
 x0=256.
 y0=256.
 radius=150
 get_mask,x0,y0,radius,mask
 writefits,'mask.fits',mask
 imethod=2	; =1 is POWELL =2 is LMFITFUN
 if (imethod eq 2) then begin
     ; Define the starting point:
     a=400.0d0
     alfa=1.61d0
     if (file_exist('lastsolution2.txt') eq 1) then begin
         dota=get_data('lastsolution2.txt')
         a=dota(0)+randomn(seed)
         alfa=dota(1)+randomn(seed)/15.
         endif
     start_parms = [a,alfa]
     ; Find best parameters using MPFIT2DFUN method
     l=size(ideal,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
     err=1./sqrt(observed) & err=err*sqrt(3090.)
     z=ideal*0.0	; target is a zero plane
     ; set up the PARINFO array - indicate double-sided derivatives (best)
     parinfo = replicate({mpside:0, value:0.D, $
     fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-4}, 2)
     parinfo[0].fixed = 0
     parinfo[1].fixed = 0
     ; a
     parinfo[0].limited(0) = 0
     parinfo[0].limits(0)  = 100.0
     parinfo[0].limited(1) = 0
     parinfo[0].limits(1)  = 0.
     ; alfa
     parinfo[1].limited(0) = 0
     parinfo[1].limits(0)  = 0.0
     parinfo[1].limited(1) = 0
     parinfo[1].limits(1)  = 0
     parinfo[*].value = start_parms
     
     ; print,parinfo
     results = MPFIT2DFUN('minimize_me', X, Y, Z, ERR, $
     PARINFO=parinfo,perror=sigs,STATUS=hej,xtol=1e-15)
     ; Print the solution point:
     print,'STATUS=',hej
     PRINT, 'Solution point: ', results(0),' +/- ',sigs(0),' or ',sigs(0)/results(0)*100.,' % error.'
     PRINT, 'Solution point: ', results(1),' +/- ',sigs(1),' or ',sigs(1)/results(1)*100.,' % error.'
     endif
 a=results(0)
 alfa=results(1)
 ; print out some results
 gogetjulianday,header,jd
 fmt='(f20.7,2(1x,f14.10),2(1x,f12.6))'
 print,format=fmt,jd,alfa,a,errorwholeimage,errorinabox
 print,'Errors wrt observed image'
 print,'-------------------------'
 print,'Per pixel error in pct on wholeimage:',errorwholeimage
 print,'Per pixel error in pct in a box     :',errorinabox
 print,'Errors wrt ideal image'
 print,'----------------------'
 print,'Per pixel error in pct in a box     :',idealerrorinabox
 ; save the best solution
 openw,87,'lastsolution2.txt'
 printf,87,results(0)
 printf,87,results(1)
 close,87
 writefits,'resiual_wrt_observed.fits',residual
 writefits,'resiual_wrt_ideal.fits',ideal_residual
 writefits,'best_trial_model.fits',trialim
 ;...........................
set_plot,'ps'
device,/color
device,xsize=18,ysize=24.5,yoffset=2
 !P.MULTI=[0,1,4]
 !P.THICK=2
 !x.THICK=2
 !y.THICK=2
 plot,observed(*,256),/ylog
 oplot,trialim(*,256),color=fsc_color('red')
 oplot,[!X.crange],[max(observed(*,256)),max(observed(*,256))],linestyle=2
 oplot,[!X.crange],[max(observed(*,256))/75.,max(observed(*,256))/75.],linestyle=2
 plot,observed(*,256),yrange=[390,600]
 oplot,trialim(*,256),color=fsc_color('red')
 plot,observed(*,256)-trialim(*,256),yrange=[-5,30]
 oplot,b*ideal(*,256),color=fsc_color('red')
 plot,(observed(*,256)-trialim(*,256)-b*ideal(*,256))/b*ideal(*,256)*100.,yrange=[-10,10]
device,/close
set_plot,'x'
;....................
;DSremnant=observed-trialim
;DS4real=b*ideal
;DSerr=(DSremnant-DS4real)/DS4real
;print,'Other error in box:',get_mean_flux_in_box(DSerr)
 end
