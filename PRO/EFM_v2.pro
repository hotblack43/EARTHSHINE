PRO gofindDSandBSinboxes,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag
; determine if BS is to the right or the left of the center
; iflag = 1 means position 1
; iflag = 2 means position 2
if (iflag eq 1) then ipos=4./5.
if (iflag eq 2) then ipos=2./3.
if (cg_x gt x0) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*ipos-w:x0-radius*ipos+w,y0-w:y0+w))
endif
if (cg_x lt x0) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*ipos-w:x0+radius*ipos+w,y0-w:y0+w))
endif
return
end

PRO cgfinder,im,cg_x,cg_y
; find c.g.
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
if (cg_x lt 0 or cg_x gt l(0) or cg_y lt 0 or cg_y gt l(1)) then stop
return
end


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
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b,idealbiasinbox
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
 idealbiasinbox=(get_mean_flux_in_box(observed)-get_mean_flux_in_box(trialim))/get_mean_flux_in_box(trialim)*100.
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
 ; version 2 of Empirical Forward Method - will loop over input files
 ;------------------------------------------------------------------------
 !P.CHARSIZE=2
 common ims,ideal,observed,source,residual,ideal_residual,mask,trialim
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b,idealbiasinbox
 common sizes,l
 common cutoff,cuttoffval
 cuttoffval=45
 get_lun,ww
 openw,ww,'collected_output_EFM.txt'
 ;files=file_search('OUTPUT/LunarImg*.fit',count=nfiles)
 files=file_search('/data/pth/RESULTS/INPUT/IDEAL/LunarImg_*',count=nfiles)
 for ifile=0,nfiles-1,1 do begin
 ; get the ideal image
 ideal=readfits(files(ifile),/silent,header)
 ; scale it to something realistic
 ideal=ideal/max(ideal)*55000.0d0
 l=size(ideal,/dimensions)
 writefits,'ideal_used.fits',ideal
 ; generate the fake observed image from that
 seed=fix((systime(/seconds)-long(systime(/seconds)))*1e4)
 spawnstr='./syntheticmoon ideal_used.fits observed.fits 1.8 100 '+string(fix(seed))
 spawn,spawnstr
 print,spawnstr
 ; read in the observed image
 observed=readfits('observed.fits')
 ; find light C.G.
 cgfinder,observed,cg_x,cg_y
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
     a=401.0d0+randomn(seed)/3.
     alfa=1.81d0+randomn(seed)/10.
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
 ; get the 2(3 and 4/5 info
 w=11
 iflag=1
 gofindDSandBSinboxes,observed,ideal_residual,x0,y0,radius,cg_x,cg_y,w,BS,DS23,iflag
 iflag=2
 gofindDSandBSinboxes,observed,ideal_residual,x0,y0,radius,cg_x,cg_y,w,BS,DS45,iflag
 ; print out some results
 gogetjulianday,header,jd
 fmt='(f20.7,2(1x,f14.10),4(1x,f12.6))'
 printf,ww,format=fmt,jd,alfa,a,idealerrorinabox,idealbiasinbox,DS23,DS45
 print,format=fmt,jd,alfa,a,idealerrorinabox,idealbiasinbox,DS23,DS45
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
endfor
close,ww
free_lun,ww
 end
