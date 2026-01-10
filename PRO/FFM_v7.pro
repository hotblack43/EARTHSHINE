PRO getfiltername,filename,filtername
;/media/SAMSUNG/CLEANEDUP2455945/2455945.0716098MOON_VE2_AIR_DCR.fits
bit1=strmid(filename,strpos(filename,'_')+1,strlen(filename))
filtername=strmid(bit1,0,strpos(bit1,'_'))
return
end

PRO gofindradiusandcenter,im_in,x0,y0,radius
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 im=laplacian(im,/CENTER)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 ; remove specks
 im=median(im,3)
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 openw,49,'trash14.dat'
 for i=0,ntries-1,1 do begin 
     irnd=randomu(seed)*nels
     x1=reform(coords(0,irnd))
     y1=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x2=reform(coords(0,irnd))
     y2=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x3=reform(coords(0,irnd))
     y3=reform(coords(1,irnd))
     fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
     printf,49,x0,y0,radius
     endfor
 close,49
 data=get_data('trash14.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 return
 end
PRO bestBSspotfinder,im,cg_x,cg_y
; find the coordinates of a spot near the brightest part of the BS
 l=size(im,/dimensions)
smooim=median(im,5)
idx=where(smooim eq max(smooim))
coo=array_indices(smooim,idx)
cg_x=coo(0)
cg_y=coo(1)
if (cg_x lt 0 or cg_x gt l(0) or cg_y lt 0 or cg_y gt l(1)) then stop
return
end

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

 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

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
 ; version 7 of Full Forward Method
 ; like version 6
 ; Works on a series of real images
 ;----------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage
 common errs,functionvalue,residual2BOX
 openw,63,'results_EFM_onrealimages.dat'
 ; find all images towork on
 night='2455917'	; seems difficult
 night='2455923'
 files=file_search(strcompress('/media/SAMSUNG/CLEANEDUP'+night+'/2455*.fits',/remove_all),count=n)
 print,'Found ',n,' images to clean up!'
 for iim=0,n-1,1 do begin
 print,'File: ',files(iim)
 ; get the filtername
 getfiltername,files(iim),filtername
 ; run the script that generates the necessary ideal images
 observed=readfits(files(iim),header)
 ;find c.g. of the image
 bestBSspotfinder,observed,cg_x,cg_y
 ; find radius and center
 gofindradiusandcenter,observed,x0,y0,radius
 get_time,header,jd
 ; clean up
 spawn,'rm veryspcialimageSSA0p000.fits veryspcialimageSSA1p000.fits youneedthis.fits'
 spawn,'cp '+files(iim)+' youneedthis.fits'
 spawn,'./align_model_to_observation.scr youneedthis.fits'
 ; load up the two special white and black ideal images
 blackimage=readfits('veryspcialimageSSA0p000.fits')
 whiteimage=readfits('veryspcialimageSSA1p000.fits')
 ; define some real-world effects
 pedestal=abs(min(observed))*1.01
 ;...............
 l=size(observed,/dimensions) & n=l(0)
 observed=observed+pedestal
     ; Define the starting point:
     a=pedestal+2.0d0
     alfa=1.71d0
     albedo=0.30d0
     start_parms = [a,alfa,albedo]
     ; Find best parameters using MPFIT2DFUN method
     l=size(observed,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
     weights=alog(observed^2);*0.0+1.0 
     weights=weights/total(weights)*12.0*12.0*4.0
     z=observed*0.0	; target is a zero plane
     ; set up the PARINFO array - indicate double-sided derivatives (best)
     parinfo = replicate({mpside:2, value:0.D, $
     fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-4}, 3)
     parinfo[0].fixed = 0
     parinfo[1].fixed = 0
     parinfo[2].fixed = 0
     ; a
     parinfo[0].limited(0) = 1
     parinfo[0].limits(0)  = 0.0
     parinfo[0].limited(1) = 1
     parinfo[0].limits(1)  = 1000.
     ; alfa
     parinfo[1].limited(0) = 1
     parinfo[1].limits(0)  = 0.0
     parinfo[1].limited(1) = 1
     parinfo[1].limits(1)  = 2.0
     ; albedo
     parinfo[2].limited(0) = 1
     parinfo[2].limits(0)  = 0.0
     parinfo[2].limited(1) = 1
     parinfo[2].limits(1)  = 1.0
     parinfo[*].value = start_parms
     ; print,parinfo
     results = MPFIT2DFUN('minimize_me', X, Y, Z, weights=weights, $
     PARINFO=parinfo,perror=sigs,STATUS=hej,xtol=1e-15)
     ; Print the solution point:
     print,'STATUS=',hej
     PRINT, 'Solution point: ', results(0),' +/- ',sigs(0),' or ',sigs(0)/results(0)*100.,' % error.'
     PRINT, 'Solution point: ', results(1),' +/- ',sigs(1),' or ',sigs(1)/results(1)*100.,' % error.'
     PRINT, 'Solution point: ', results(2),' +/- ',sigs(2),' or ',sigs(2)/results(2)*100.,' % error.'
     a=results(0)
     alfa=results(1)
     albedo=results(2)
; gett he DS and BS 
w=11
iflag=1
gofindDSandBSinboxes,observed-a,trialim-a,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag
 ; print out some results
 fmt='(f20.7,11(1x,g15.9),1x,a)'
 print,format=fmt,jd,alfa,a,albedo,BS,total(observed-a),DS,x0,y0,radius,cg_x,cg_y,filtername
 printf,63,format=fmt,jd,alfa,a,albedo,BS,total(observed-a),DS,x0,y0,radius,cg_x,cg_y,filtername
 endfor	; end of iim loop
 close,63
 end
