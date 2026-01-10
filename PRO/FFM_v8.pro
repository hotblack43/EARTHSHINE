@stuf33.pro
 PRO getbasicfilename,namein,basicfilename
 print,namein
 basicfilename=strmid(namein,strpos(namein,'.')-7)
 ;basicfilename=strmid(namein,strpos(namein,'2455'))
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

PRO findafittedlinearsurface,im,mask,thesurface
l=size(im,/dimensions)
 common xsandYs,X,Y
 ;   Nx=l(0)
 ;   Ny=l(1)
 ;   XR = indgen(Nx)
 ;   YC = indgen(Ny)
 ;   X = double(XR # (YC*0 + 1))        ;     eqn. 1
 ;   Y = double((XR*0 + 1) # YC)        ;     eqn. 2
;----------------------------------------
offset=mean(im(0:10,0:10))
thesurface=findgen(512,512)*0.0
mim=mask*im
get_lun,wxy
openw,wxy,'masked.dat'
for i=0,511,1 do begin
for j=0,511,1 do begin
;if (mim(i,j) ne 0.0) then begin
if ((i le 10 or i gt 500) and (j le 10 or j ge 500)) then begin
printf,wxy,i,j,mim(i,j)
;print,i,j,mim(i,j)
endif
endfor
endfor
close,wxy
free_lun,wxy
data=get_data('masked.dat')
res=sfit(data,/IRREGULAR,1,kx=coeffs)
print,coeffs
thesurface=coeffs(0,0)+coeffs(1,0)*y+coeffs(0,1)*x+coeffs(1,1)*x*y
thesurface=thesurface+offset
return
end

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
;x0=median(reform(data(0,*)))
;y0=median(reform(data(1,*)))
;radius=median(reform(data(2,*)))
 x0=mhm(reform(data(0,*)))
 y0=mhm(reform(data(1,*)))
 radius=mhm(reform(data(2,*)))
 writefits,'edgedetected.fits',im
 ; add lines to show center
 im(x0:x0,*)=max(im)
 im(*,y0:y0)=max(im)
 tvscl,hist_equal(im)
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
 
 PRO plot3things,observed,trialim,residual
 common circle,x0,y0,radius
 y1=y0
 delta=100
 !P.MULTI=[0,1,3]
 plot_io,observed(*,y1),yrange=[0.1*min(observed),max(observed)],title=filename,xstyle=3
 oplot,trialim(*,y1),color=fsc_color('red')
 plots,[x0-radius,x0-radius],[100,1e4],linestyle=2
 plots,[x0,x0],[100,1e4],linestyle=4
 plots,[x0+radius,x0+radius],[100,1e4],linestyle=2
 offs=mean(observed(0:10,y1))
 plot,observed(*,y1),yrange=[offs*0.1,offs+30],xstyle=3
 oplot,trialim(*,y1),color=fsc_color('red')
 plots,[x0-radius,x0-radius],[!Y.crange],linestyle=2
 plots,[x0,x0],[!Y.crange],linestyle=4
 plots,[x0+radius,x0+radius],[!Y.crange],linestyle=2
 plot,residual(*,y1),yrange=[-10,10],xstyle=3,ytitle='Relative Residual' & plots,[!X.crange],[0,0],linestyle=2
 plots,[x0-radius,x0-radius],[!Y.crange],linestyle=2
 plots,[x0,x0],[!Y.crange],linestyle=4
 plots,[x0+radius,x0+radius],[!Y.crange],linestyle=2
 ;plot,observed(*,y1)-trialim(*,y1),yrange=[-10,10],xstyle=3 & plots,[!X.crange],[0,0],linestyle=2
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
 ; should return the residual i.e. the observed - (a+b*P.conv.Ideal) thing
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage,cleanup
 common errs,functionvalue,residual2BOX
 common circle,x0,y0,radius
 ; The independent variables are X and Y
 a=p(0)
 alfa=p(1)
 albedo=p(2)
;b=p(3)
 ; set up the ideal image wighted by albedo
 wideal=(1.-albedo)*blackimage + albedo*whiteimage
 writefits,'ideal_in.fits',wideal
 str='./justconvolve ideal_in.fits ideal_folded_out.fits '+string(alfa)
 spawn,str
 ideal_folded=readfits('ideal_folded_out.fits',/silent)
 b=total(observed-a,/double)/total(ideal_folded,/double)
 trialim=a+b*ideal_folded
 cleanup=observed-trialim
;----------------------
 ; set up the removal of a linear fitted surface
;writefits,'cleanup.fits',cleanup
get_mask,x0,y0,radius,mask
;writefits,'mask.fits',mask
findafittedlinearsurface,cleanup,mask,thesurface
trialim=trialim+thesurface
;----------------------
 cleanup=observed-trialim
 residual=cleanup/observed*100.0
 ;residual=cleanup
 ; evaluate fit on whole image
 idx=where(finite(residual) ne 1)
 if (idx(0) ne -1) then residual(idx)=0.0
; a mask is defined
mask=mask*0.0
idx=where(abs(residual) gt 6)
;idx=where(observed-a gt 10)
residual(idx)=0.0
 functionvalue=get_errorINwholeIMAGE(residual)
 ; plot
 plot3things,observed,trialim,residual
 return, residual
 END
 
 ;----------------------------------------------------
 ; version 8 of Full Forward Method
 ; Works on a series of real images
 ;----------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage,cleanup
 common errs,functionvalue,residual2BOX
 common circle,x0,y0,radius
 common sizes,l
 common xsandYs,X,Y
 night='2456004'
 night='2456005'	; done
 night='2456006'	; difficult
 night='2456007'	; difficult
 night='2456000'
 night='2456002'
 night='2456003'
 openw,63,strcompress('results_FFM_onrealimages_'+night+'.dat',/remove_all)
 ; find all images towork on
 lowpath='DARKCURRENTREDUCED/'
 lowpath='/data/pth/DATA/ANDOR/DARKCURRENTREDUCED/'
 outpath=strcompress(lowpath+'/JD'+night+'/FFMCLEANED/',/remove_all)
 spawn,'rm -r '+outpath
 spawn,'mkdir '+outpath
 files=file_search(strcompress(lowpath+'JD'+night+'/245*.fits',/remove_all),count=n)
 print,'Found ',n,' images to clean up!'
 for iim=0,n-1,1 do begin
     print,' Working on : ',files(iim)
 getbasicfilename,files(iim),basicfilename
 print,'Reading ',files(iim)
 print,'basicfilename: ',basicfilename
     ; get the filtername
     getfiltername,files(iim),filtername
     ; run the script that generates the necessary ideal images
     observed=readfits(files(iim),header)
      get_times,header,act,exptime
     ;find c.g. of the image
     bestBSspotfinder,observed,cg_x,cg_y
     ; find radius and center
     gofindradiusandcenter,observed,x0,y0,radius
     radius=radius+16
     get_time,header,jd
     mlo_airmass,jd,am
     ; clean up
     spawn,'rm veryspcialimageSSA0p000.fits veryspcialimageSSA1p000.fits youneedthis.fits'
     ; now run eshine_special_FFM.pro so that a 'black' and 
     ; a 'white' image for that JD are generated
     spawn,'cp '+files(iim)+' youneedthis.fits'
     spawn,'./align_model_to_observation.scr youneedthis.fits'
     ; load up the two special white and black ideal images
     blackimage=readfits('veryspcialimageSSA0p000.fits')
     greyimage=readfits('veryspcialimageSSA0p300.fits')
     whiteimage=readfits('veryspcialimageSSA1p000.fits')
     ; define some real-world effects
     pedestal=50.
     ;pedestal=mean(observed(0:10,0:10))+50.
     ;...............
     l=size(observed,/dimensions) & n=l(0)
     observed=observed+pedestal
     ; Define the starting point:
     if (iim eq 0) then begin
         a=pedestal
         alfa=1.71d0
         albedo=0.30d0
;	 b=total(observed,/double)/total(greyimage,/double)
         endif
     start_parms = [a,alfa,albedo]
     ;start_parms = [a,alfa,albedo,b]
     ; Find best parameters using MPFIT2DFUN method
     l=size(observed,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
     weights=alog10(observed+1)+3.
     weights=observed*0.0+1.0
     z=observed*0.0	; target is a zero plane
     ; set up the PARINFO array - indicate double-sided derivatives (best)
     parinfo = replicate({mpside:2, value:0.D, $
     ;fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-5}, 4)
     fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-5}, 3)
     parinfo[0].fixed = 0
     parinfo[1].fixed = 0
     parinfo[2].fixed = 0
;    parinfo[3].fixed = 0
     ; a
     parinfo[0].limited(0) = 0
     parinfo[0].limits(0)  = 0.0
     parinfo[0].limited(1) = 0
     parinfo[0].limits(1)  = 1000.
     ; alfa
     parinfo[1].limited(0) = 1
     parinfo[1].limits(0)  = 1.5
     parinfo[1].limited(1) = 1
     parinfo[1].limits(1)  = 1.9
     ; albedo
     parinfo[2].limited(0) = 1
     parinfo[2].limits(0)  = 0.0
     parinfo[2].limited(1) = 1
     parinfo[2].limits(1)  = 1.0
;    ; b
;    parinfo[3].limited(0) = 0
;    parinfo[3].limits(0)  = 0.0
;    parinfo[3].limited(1) = 0
;    parinfo[3].limits(1)  = 1.0
    parinfo[*].value = start_parms
     ; print,parinfo
     results = MPFIT2DFUN('minimize_me', X, Y, Z, weights=weights, $
     PARINFO=parinfo,perror=sigs,STATUS=hej,xtol=1e-15)
     ; Print the solution point:
     print,'STATUS=',hej
     PRINT, 'Solution point: ', results(0),' +/- ',sigs(0),' or ',sigs(0)/results(0)*100.,' % error.'
     PRINT, 'Solution point: ', results(1),' +/- ',sigs(1),' or ',sigs(1)/results(1)*100.,' % error.'
     PRINT, 'Solution point: ', results(2),' +/- ',sigs(2),' or ',sigs(2)/results(2)*100.,' % error.'
 ;    PRINT, 'Solution point: ', results(3),' +/- ',sigs(3),' or ',sigs(3)/results(3)*100.,' % error.'
     a=results(0)
     alfa=results(1)
     albedo=results(2)
 ;    b=results(3)
     ; get the DS and BS 
     w=11
     iflag=1
     gofindDSandBSinboxes,observed-a,trialim-a,x0,y0,radius,cg_x,cg_y,w,BS,DS45,iflag
     iflag=2
     gofindDSandBSinboxes,observed-a,trialim-a,x0,y0,radius,cg_x,cg_y,w,BS,DS23,iflag
     ; print out some results
     filternameSTR=strcompress('_'+filtername+'_',/remove_all)
 fmt='(f20.7,2(1x,f14.10),8(1x,f15.5),4(1x,f10.5),1x,a)'
 printf,63,format=fmt,jd,alfa,a,BS,total(observed,/double),total(observed-a,/double),DS23,DS45,act,exptime,am,x0,y0,radius,albedo,strcompress('_'+filtername+'_',/remove_all)
 print,format=fmt,jd,alfa,a,BS,total(observed,/double),total(observed-a,/double),DS23,DS45,act,exptime,am,x0,y0,radius,albedo,strcompress('_'+filtername+'_',/remove_all)
;.....................
; Write out the residuals and the best-fitting trialim as FITS files
 outfilenameRESID='RESID_'+basicfilename
 outfilenameTRIALIM='TRIALIM_'+basicfilename
 writefits,strcompress(outpath+outfilenameRESID,/remove_all),cleanup
 writefits,strcompress(outpath+outfilenameTRIALIM,/remove_all),trialim
print,'Wrote to: ',strcompress(outpath+outfilenameRESID,/remove_all)
print,'Wrote to: ',strcompress(outpath+outfilenameTRIALIM,/remove_all)
;.....................
     endfor	; end of iim loop
 close,63
 end
