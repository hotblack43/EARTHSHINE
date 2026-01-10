PRO plot3things,observed,trialim
 y1=256
 delta=100
 !P.MULTI=[0,1,3]
 plot_io,observed(*,y1),yrange=[1,max(observed)],title=filename,xstyle=3
 oplot,trialim(*,y1),color=fsc_color('red')
offs=mean(observed(0:10,y1))
 plot,observed(*,y1),yrange=[offs,offs+70],xstyle=3
 oplot,trialim(*,y1),color=fsc_color('red')
 plot,observed(*,y1)-trialim(*,y1),yrange=[-10,70],xstyle=3 & plots,[!X.crange],[0,0],linestyle=2
return
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
 ; evaluate fit on whole image
 functionvalue=get_errorINwholeIMAGE(residual)
 ; plot
 plot3things,observed,trialim
 return, residual
 END
 
 ;----------------------------------------------------
 ; version 6 of Full Forward Method
 ; Works on single real images
 ;----------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage
 common errs,functionvalue,residual2BOX
 ; load up the two special white and black ideal images
 blackimage=readfits('veryspcialimageSSA0p000.fits')
 whiteimage=readfits('veryspcialimageSSA1p000.fits')
 ; define some real-world effects
 pedestal=0.0
 ;...............
 openw,63,'results_EFM_onrealimages.dat'
 ; get the observed image
 observed=readfits('moon.fits',/silent)
 l=size(observed,/dimensions) & n=l(0)
 observed=observed+pedestal
     ; Define the starting point:
     a=70.0d0
     alfa=1.70d0
     albedo=0.3
     if (file_exist('lastsolution.txt') eq 1) then begin
         dota=get_data('lastsolution.txt')
         a=dota(0)
         alfa=dota(1)
         albedo=dota(2)
         endif
     start_parms = [a,alfa,albedo]
     ; Find best parameters using MPFIT2DFUN method
     l=size(observed,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
     ;err=1./sqrt(observed) & err=err*sqrt(3090.)
     err=observed*0.0+1.0 
     z=observed*0.0	; target is a zero plane
     ; set up the PARINFO array - indicate double-sided derivatives (best)
     parinfo = replicate({mpside:2, value:0.D, $
     fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-4}, 3)
     parinfo[0].fixed = 0
     parinfo[1].fixed = 0
     ; a
     parinfo[0].limited(0) = 0
     parinfo[0].limits(0)  = 0.0
     parinfo[0].limited(1) = 0
     parinfo[0].limits(1)  = 100.
     ; alfa
     parinfo[1].limited(0) = 0
     parinfo[1].limits(0)  = 0.0
     parinfo[1].limited(1) = 0
     parinfo[1].limits(1)  = 0
     ; albedo
     parinfo[2].limited(0) = 0
     parinfo[2].limits(0)  = 0.0
     parinfo[2].limited(1) = 0
     parinfo[2].limits(1)  = 0
     parinfo[*].value = start_parms
     ; print,parinfo
     results = MPFIT2DFUN('minimize_me', X, Y, Z, ERR, $
     PARINFO=parinfo,perror=sigs,STATUS=hej,xtol=1e-15)
     ; Print the solution point:
     print,'STATUS=',hej
     PRINT, 'Solution point: ', results(0),' +/- ',sigs(0),' or ',sigs(0)/results(0)*100.,' % error.'
     PRINT, 'Solution point: ', results(1),' +/- ',sigs(1),' or ',sigs(1)/results(1)*100.,' % error.'
     PRINT, 'Solution point: ', results(2),' +/- ',sigs(2),' or ',sigs(2)/results(2)*100.,' % error.'
 ; print out some results
 fmt='(3(1x,f9.5),1x,g12.1,2(1x,f12.6))'
 print,format=fmt,alfa,a,albedo,999.999,functionvalue,999;residual2BOX
 printf,63,format=fmt,alfa,a,albedo,999.999,functionvalue,999;residual2BOX
 ; save the best solution
 openw,87,'lastsolution.txt'
 printf,87,results(0)
 printf,87,results(1)
 printf,87,results(2)
 close,87
 close,63
 end
