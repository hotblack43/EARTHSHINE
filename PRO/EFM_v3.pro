 PRO getbasicfilename,namein,basicfilename
 print,namein
 basicfilename=strmid(namein,strpos(namein,'2455'))
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
 common ims,observed,source,residual,mask,trialim,cleanup
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b,idealbiasinbox
 common cutoff,cuttoffval
 ; The independent variables are X and Y
 a=p(0)
 alfa=p(1)
 ; generate a Source image from the observed image 
 ; subtracting the current guess ofr the offset
 im=observed-a
 ; generate the '1/75th' source image
 factor=cuttoffval
 idx=where(im lt max(smooth(im,3))/factor)
 im(idx)=0
 writefits,'source.fits',im
 ; then use that estimate of the source to fold etc
 str='./justconvolve source.fits source_folded_out.fits '+string(alfa)
 spawn,str
 source_folded=readfits('source_folded_out.fits',/silent)
 b=(total(observed,/double))/total(source_folded+a,/double)
 print,'b=',b
 trialim=a+b*source_folded
 ; get residuals wrt observed image
 cleanup=observed-trialim
 residual=(observed-trialim)/observed*100.0
 idx=where(finite(residual) ne 1)
 if (idx(0) ne -1) then residual(idx)=0.0
 ; evaluate model fit 
 errorwholeimage=get_errorINwholeIMAGE(mask*residual)
 ; print out some results
 print,'----------------->',p,b,errorwholeimage
 !P.MULTI=[0,1,2]
 plot,observed(*,256),/ylog,yrange=[0.1,1e5]
 oplot,trialim(*,256),color=fsc_color('red')
 oplot,[!X.crange],[max(observed(*,256)),max(observed(*,256))],linestyle=2
 oplot,[!X.crange],[max(observed(*,256))/cuttoffval,max(observed(*,256))/cuttoffval],linestyle=2
 plot,observed(*,256),yrange=[0,40]
 oplot,trialim(*,256),color=fsc_color('red')
 return, (residual*mask)
 END
 
 
 ;------------------------------------------------------------------------
 ; version 3 of Empirical Forward Method - will loop over input files
 ; This version intended for real bias-subtracted (and one day flatfielded) images
 ;------------------------------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,source,residual,mask,trialim,cleanup
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b,idealbiasinbox
 common sizes,l
 common cutoff,cuttoffval
 filtername=['B','V','VE1','VE2','IRCUT']
 cuttoffval=75
 ; path for EMF-cleaned DSs
 ;outpath='/media/SAMSUNG/CLEANEDUP2455858/EFMCLEANED/'
 outpath='TEMP2/'
 get_lun,ww
 openw,ww,'collected_output_EFM_realimages_stacked.txt'
 for ifilter=0,4,1 do begin
 files=file_search(strcompress('SPECIAL/aligned_*'+filtername(ifilter)+'_*.fi*',/remove_all),count=nfiles)
 for i=0,nfiles-1,1 do begin
 ; read in the observed image
 getbasicfilename,files(i),basicfilename
 print,'Reading ',files(i)
 observed=readfits(files(i),header)+15
 l=size(observed,/dimensions)
 ; find light C.G.
 bestBSspotfinder,observed,cg_x,cg_y
 ; add some bias
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
 gofindradiusandcenter,im,x0,y0,radius
 radius=radius+6
 get_mask,x0,y0,radius,mask
 writefits,'mask.fits',mask
 imethod=2	; =1 is POWELL =2 is LMFITFUN
 if (imethod eq 2) then begin
     ; Define the starting point:
     a=15.0d0+randomn(seed)/3.
     alfa=1.7d0+randomn(seed)/10.
     start_parms = [a,alfa]
     ; Find best parameters using MPFIT2DFUN method
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
     kdx=where(observed le 0)
     jdx=where(observed gt 0)
     weights=1./sqrt(observed) 
     weights(kdx)=median(1./sqrt(observed(jdx)))
     weights=weights*sqrt(3090.)
     weights=observed*0.0+1.0
     z=observed*0.0	; target is a zero plane
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
     results = MPFIT2DFUN('minimize_me', X, Y, Z, weights=weights, $
     PARINFO=parinfo,perror=sigs,STATUS=hej,xtol=1e-15)
     ; Print the solution point:
     print,'STATUS=',hej
     PRINT, 'Solution point: ', results(0),' +/- ',sigs(0),' or ',sigs(0)/results(0)*100.,' % error.'
     PRINT, 'Solution point: ', results(1),' +/- ',sigs(1),' or ',sigs(1)/results(1)*100.,' % error.'
     endif
 a=results(0)
 alfa=results(1)
 ; get the 2/3 and 4/5 info
 w=11
 iflag=1
 gofindDSandBSinboxes,observed,cleanup,x0,y0,radius,cg_x,cg_y,w,BS,DS45,iflag
 iflag=2
 gofindDSandBSinboxes,observed,cleanup,x0,y0,radius,cg_x,cg_y,w,BS,DS23,iflag
 ; print out some results
;gogetjulianday,header,jd
get_time,header,jd
 fmt='(f20.7,2(1x,f14.10),5(1x,f18.5),1x,a)'
 printf,ww,format=fmt,jd,alfa,a,BS,total(observed,/double),total(observed-a,/double),DS23,DS45,filtername(ifilter)
 print,format=fmt,jd,alfa,a,BS,total(observed,/double),total(observed-a,/double),DS23,DS45,filtername(ifilter)
 ; save the best solution
 openw,87,'lastsolution2.txt'
 printf,87,results(0)
 printf,87,results(1)
 close,87
 ; save the cleaneup image (i.e. just the DS)
 writefits,strcompress(outpath+'DS_'+basicfilename,/remove_all),cleanup,header
endfor
endfor
close,ww
free_lun,ww
 end
