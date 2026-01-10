PRO getstats,toppoint,med,toppoint_sig,med_sig
data=get_data('temporary.removeme')
toppoint=median(data(0,*))
toppoint_sig=stddev(data(0,*));/sqrt(n_elements(data(0,*))-1)
med=median(data(1,*))
med_sig=stddev(data(1,*));/sqrt(n_elements(data(1,*))-1)
return
end

PRO gogetalbedoformresidualsim1im2,im1,im2,raw,residuals,x0,y0,radius,imnum,filter,JD
common ifviz,ifviz
 idelatester=(im1+im2)/2.0d0
 determineFLIP2,idelatester,raw,x0,y0,flipneed,flopneeded
 if (flipneed eq 1) then begin
     im1=reverse(im1,1)
     im2=reverse(im2,1)
     endif
 if (flopneeded eq 1) then begin
     im1=reverse(im1,2)
     im2=reverse(im2,2)
     endif
; also shift to x0,y0
w=11
im1=shift(im1,x0-256,y0-256)
im2=shift(im2,x0-256,y0-256)
!P.MULTI=[0,1,2]
ratio=residuals/(im2/total(im2,/double)*total(raw,/double))
if (ifviz eq 1) then begin
plot,residuals(*,y0),yrange=[-1,10],ystyle=3                     
oplot,0.35*im2(*,y0)/total(im2)*total(raw),color=fsc_color('red'),thick=5
plot,ratio(*,y0),yrange=[0,1],ystyle=3,ytitle='Albedo'                     
endif
; select points on DS disc
 l=size(raw,/dimensions)
 radii=fltarr(l)
 theta=fltarr(l)
 xline=intarr(l)
 yline=intarr(l)
 for icol=0,l(0)-1,1 do begin
     for irow=0,l(1)-1,1 do begin
         xline(icol,irow)=icol
         yline(icol,irow)=irow
         radii(icol,irow)=sqrt((icol-x0)^2+(irow-y0)^2)
         theta(icol,irow)=atan((irow-y0)/(icol-x0))/!dtor
         endfor
     endfor
; select
idx=where(raw lt max(raw)/500 and finite(ratio) eq 1 and radii lt radius)
med=median(ratio(idx))
print,'Median: ',med
minval=0.0
maxval=1.0
bins=0.002
array_in=ratio(idx)
nmembers=n_elements(array_in)
nloops=1000
openw,62,'temporary.removeme'
for iloop=0,nloops,1 do begin
; get the boostrap sample
kdx=randomu(seed,nmembers)*nmembers
array=array_in(kdx)
;
h=histogram(array,min=minval,max=maxval,binsize=bins)
n=(maxval-minval)/bins+1
xx=findgen(n)/float(n)*(maxval-minval)+minval
if (ifviz eq 1) then plot,xx,h,psym=10
degree=2
kdx=where(smooth(h,11,/edge_truncate) eq max(smooth(h,11,/edge_truncate)))
idx=where(xx gt mean(xx(kdx))-0.05 and xx lt mean(xx(kdx))+0.05)
res=poly_fit(xx(idx),h(idx),degree,yfit=yhat)
if (ifviz eq 1) then oplot,xx(idx),yhat,color=fsc_color('red')
toppoint=-res(1)/2.0d0/res(2)
print,'Top at: ',toppoint
if (ifviz eq 1) then oplot,[toppoint,toppoint],[!Y.crange],linestyle=0
printf,62,toppoint,med
endfor ; end of iloop
close,62
getstats,toppoint,med,toppoint_sig,med_sig
openw,33,'albedo_estimated_from_his.dat',/append
printf,33,format='(f15.7,1x,a,2(1x,f10.6,a,f10.6))',JD,filter,toppoint,' +/- ',toppoint_sig,med,' +/- ',med_sig
close,33
print,format='(f15.7,1x,a,2(1x,f10.6,a,f10.6))',JD,filter,toppoint,' +/- ',toppoint_sig,med,' +/- ',med_sig
return
end

PRO get_source_andBSsky_using_mask,raw,BSsource,skyhalotofit,x0,y0,radius
 l=size(raw,/dimensions)
 ncols=l(0)
 nrows=l(1)
 ; find the BS
 BSsource=raw
 idx=where(raw lt max(raw)/100.)
 BSsource(idx)=0.0d0
 ; set up the mask
 skyhalotofit=raw
 edge=10
 radius2=(radius+edge)^2
 for icol=0,ncols-1,1 do begin
     for irow=0,nrows-1,1 do begin
         r2=((x0-icol)^2+(y0-irow)^2)
         if (r2 lt radius2) then skyhalotofit(icol,irow)=0.0d0
         endfor
     endfor
 return
 end
 
 PRO getlamda0fromfiltername,filter,lamda0
 contrast=-1e22
 if (filter eq 'B') then lamda0= 445.
 if (filter eq 'V') then lamda0= 534.
 if (filter eq 'VE1') then lamda0= 569.
 if (filter eq 'VE2') then lamda0= 708.
 if (filter eq 'IRCUT') then lamda0= 560.
 return
 end
 
 PRO buildim,im1,im2,obs,im1replaced,im2replaced
 ; will replace the BS in im1 and im2 with the obs BS
 im1replaced=im1
 im2replaced=im2
 idx=where(obs gt max(obs)/100.)
 ;
 print,'Before:'
 print,total(im1replaced(idx))
 print,total(im2replaced(idx))
 print,'Observed idx:',total(obs(idx))
 ;
 factor1=total(im1replaced(idx),/double)/total(obs(idx),/double)
 factor2=total(im2replaced(idx),/double)/total(obs(idx),/double)
 im1replaced(idx)=obs(idx)*factor1
 im2replaced(idx)=obs(idx)*factor2
 print,'After:'
 print,total(im1replaced(idx))
 print,total(im2replaced(idx))
 return
 end
 
 PRO findcuspanglefromimage,im,x0,y0,radius,cangle
 l=size(im,/dimensions)
 ;
 radii=fltarr(l)
 theta=fltarr(l)
 xline=intarr(l)
 yline=intarr(l)
 for icol=0,l(0)-1,1 do begin
     for irow=0,l(1)-1,1 do begin
         xline(icol,irow)=icol
         yline(icol,irow)=irow
         radii(icol,irow)=sqrt((icol-x0)^2+(irow-y0)^2)
         theta(icol,irow)=atan((irow-y0)/(icol-x0))/!dtor
         endfor
     endfor
 idx=where(xline le x0)
 theta(idx)=180+theta(idx)
 idx=where(yline le y0 and xline ge x0)
 theta(idx)=360+theta(idx)
 w=2
 ic=0
 for angle=0,360-w,w do begin
     idx=where(radii gt radius-5 and radii le radius+5 and theta ge angle and theta lt angle+w)
     ;    print,angle,mean(im(idx))
     if (ic eq 0) then liste=[angle+w/2.,mean(im(idx))]
     if (ic gt 0) then liste=[[liste],[angle+w/2.,mean(im(idx))]]
     ;    help,liste
     ic=ic+1
     endfor
 ;plot_io,liste(0,*),liste(1,*)
 minval=min(liste(1,*))
 maxval=max(liste(1,*))
 idx=where(liste(1,*) lt (maxval-minval)/500.)
 minangle=min(liste(0,idx))
 maxangle=max(liste(0,idx))
 print,'minangle,maxangle: ',minangle,maxangle
 ;oplot,[minangle,minangle],[1,1e4],linestyle=2
 ;oplot,[maxangle,maxangle],[1,1e4],linestyle=2
 cangle=(minangle+maxangle)/2.
 return
 end
 
 
 FUNCTION get_filter_from_filename,name 
 if (strpos(name,'_B_') ne -1) then begin
     value='B'
     return,value
     endif
 if (strpos(name,'_V_') ne -1) then begin
     value='V'
     return,value
     endif
 if (strpos(name,'_VE1_') ne -1) then begin
     value='VE1'
     return,value
     endif
 if (strpos(name,'_VE2_') ne -1) then begin
     value='VE2'
     return,value
     endif
 if (strpos(name,'_IRCUT_') ne -1) then begin
     value='IRCUT'
     return,value
     endif
 print,'No filtername in the file name: ',name
 stop
 end
 
 PRO use_cusp_angle_fan_DS_BS,im,x0,y0,radius,rad,line,err_line,imethod,w1,w2,w3,w4
 common ifviz,ifviz
 common thetaflags,iflag_theta,radii,theta,xline,yline
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl,imnum
 common cuspanglestuff,iflagcuspangle,cangle
 l=size(im,/dimensions)
 ;
 ;if(iflag_theta ne 314) then begin
 radii=fltarr(l)
 theta=fltarr(l)
 xline=intarr(l)
 yline=intarr(l)
 print,'Here x0,y0,radius:',x0,y0,radius
 for icol=0,l(0)-1,1 do begin
     for irow=0,l(1)-1,1 do begin
         xline(icol,irow)=icol
         yline(icol,irow)=irow
         radii(icol,irow)=sqrt((icol-x0)^2+(irow-y0)^2)
         theta(icol,irow)=atan((irow-y0)/(icol-x0))/!dtor
         endfor
     endfor
 idx=where(xline le x0)
 theta(idx)=180+theta(idx)
 idx=where(yline le y0 and xline ge x0)
 theta(idx)=360+theta(idx)
 ;findcuspanglefromimage,im,x0,y0,radius(0),cangle
 print,'Found cusp angle: ',cangle
 left=avg(im(0:x0,*))
 right=avg(im(x0:511,*))
 print,'left,right:',left,right
 ipntr=1
 if (left lt right) then ipntr=-1
 print,'ipntr: ',ipntr
 if (ipntr eq  1) then stop
 ;....
 r_step=4
 w=20.0d0; 1.168547654d0	; half-width of fan in degrees degrees
 num1=cangle(0)+w
 num2=cangle(0)-w
 num3=num1+180
 num4=num2+180
 print,'determined num1,num2: ',num1,num2
 print,'determined num3,num4: ',num3,num4
 if (ipntr eq -1) then begin
     ; DS fan
     idx=where(xline lt x0 and (theta gt num2 and theta le num1))
     ; BS fan
     if (num3 gt 360) then jdx=where(xline ge x0 and (theta gt num4  or theta le (num3 mod 360)))
     if (num3 le 360) then jdx=where(xline ge x0 and (theta gt num4  and theta le num3))
     endif
 help,idx,jdx
 openw,66,'temporary.dat'
 markedupimage=im
 markedupimage(idx)=max(markedupimage)
;tvscl,markedupimage
 for r=max([0,radius-w1]),min([511,radius+w2]),r_step do begin
     kdx=where(radii(idx) ge r and radii(idx) lt r+r_step)
     markedupimage(idx(kdx))=0
;    tvscl,markedupimage
     if (kdx(0) ne -1) then printf,66,-mean(radii(idx(kdx))),median(im(idx(kdx))),stddev(im(idx(kdx)))
     endfor
 markedupimage=im
 markedupimage(jdx)=max(markedupimage)
 ;tvscl,markedupimage
 if (w3 ne w4) then begin
     for r=radius+w3,radius+w4,r_step do begin
         kdx=where(radii(jdx) ge r and radii(jdx) lt r+r_step)
         markedupimage(jdx(kdx))=0
         ;tvscl,markedupimage
         nfan=n_elements(kdx)
         if (nfan gt 30) then printf,66,mean(radii(jdx(kdx))),median(im(jdx(kdx))),stddev(im(jdx(kdx)))
         endfor
     endif
 close,66
 data=get_data('temporary.dat')
 rad=reform(data(0,*))
 line=reform(data(1,*))
 err_line=reform(data(2,*)) 
 idx=where(rad lt 0 and abs(rad) lt radius+5 and abs(rad) gt radius-5)
 if (idx(0) ne -1) then begin
     err_line(idx)=err_line(idx)*5
     endif else begin
     stop
     endelse
 idx=where(rad lt 0 and abs(rad) ge radius+5)
 if (idx(0) ne -1) then begin
     err_line(idx)=err_line(idx)/10
     endif else begin
     stop
     endelse
 ploterr,rad,line,err_line,psym=7
 ; modified err_line is now returned to calling routine
 return
 end
 
 
 FUNCTION get_JD_from_filename,name
 print,'In get_JD_from_filename, trying to convert this name to a JD: ',name
 liste=strsplit(name,'/',/extract)
 idx=strpos(liste,'24')
 ipoint=where(idx ne -1)
 JD=double(liste(ipoint))
 return,JD
 end
 
 
 PRO determineFLIP2,ideal_in,raw_in,x0,y0,refimFLIPneeded,refimFLOPneeded
 raw=raw_in/max(raw_in)
 ideal=ideal_in/max(ideal_in)
 ;window,1,xsize=1024,ysize=512
 ;...........................
 ; no flip or flop
 ; shift ideal to same position as observed
 ideal=shift(ideal,x0-256,y0-256)
 r1=correlate(raw,ideal)
 ;..........................
 ; just a flip
 ideal=ideal_in/max(ideal_in)
 ideal=reverse(ideal,1)
 ideal=shift(ideal,x0-256,y0-256)
 r2=correlate(raw,ideal)
 ;..........................
 ; just a flop
 ideal=ideal_in/max(ideal_in)
 ideal=reverse(ideal,2)
 ideal=shift(ideal,x0-256,y0-256)
 r3=correlate(raw,ideal)
 ;..........................
 ; a flip and a flop
 ideal=ideal_in/max(ideal_in)
 ideal=reverse(reverse(ideal,1),2)
 ideal=shift(ideal,x0-256,y0-256)
 r4=correlate(raw,ideal)
 ;..........................
 r=[r1,r2,r3,r4]
 idx=where(r eq max(r))
 if (idx eq 0) then begin
     refimFLIPneeded=0
     refimFLOPneeded=0
     return
     endif
 if (idx eq 1) then begin
     refimFLIPneeded=1
     refimFLOPneeded=0
     return
     endif
 if (idx eq 2) then begin
     refimFLIPneeded=0
     refimFLOPneeded=1
     return
     endif
 if (idx eq 3) then begin
     refimFLIPneeded=1
     refimFLOPneeded=1
     return
     endif
 end
 
 FUNCTION convolve, X, Y, P
common ifviz,ifviz
 ; must return an array from the model 
 common stuff117,name,use1,use2,source,target,raw,RMSE,x0,y0,radius,nbands,w1,w2,w3,w4
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl,imnum
 common headerstuff,mixedimageheader,header
 common Y, Yobs
 common fanstuff,rad_raw,line_raw,rad_folded,line_folded
 common erry,erry
 common residualimage,residuals
 nparms=n_elements(p)
 nparms=nparms-3
 ;print,format='(a,10(1x,f9.3))','In convolve, p=',p
 lll=size(target,/dimensions)
 rawncols=lll(0)
 rawnrows=lll(1)
 pedestal=p(nparms)
 zodi=p(nparms+1)
 SLcounts=p(nparms+2)
 print,'pedestal,zodi and SLcounts: ',pedestal,zodi,SLcounts
 writefits,'mixed117.fits',source,mixedimageheader
 str='./justconvolve_PSFn_forcallextrernal mixed117.fits trialout117.fits '
;str='./justconvolve_PSFn mixed117.fits trialout117.fits '
 for kl=0,nparms-1,1 do str=str+string(p(kl))
 spawn,str
 folded=readfits('trialout117.fits',/silent)+pedestal
 writefits,strcompress('folded_'+string(imnum)+'.fits',/remove_all),folded
 ; now add the ZL+SL correction 
 jdx=where(target gt 0)
 folded(jdx)=folded(jdx)+zodi+SLcounts
 value=target-folded
 imnumstr=string(imnum)
 residuals=raw-folded
 writefits,strcompress('residuals_'+imnumstr+'.fits',/remove_all),residuals
 idx=where(target eq 0.0)
 value(idx)=0.0
 ; also mask out panels above and below centre
 rows=findgen(rawnrows)
 hdx=where((rows lt y0-radius*0.75) or (rows gt y0+radius*0.75))
 value(*,hdx)=0.0
 RMSE=sqrt(total(value^2))
 print,'RMSE= ',RMSE
 ;---------------------
 ;tvscl,hist_equal(value)
 if (ifviz eq 1) then plot,value(*,y0),xstyle=3,ystyle=3
 return,value
 END
 
 PRO gofitBSsky,BSsource,skyhalotofit,nparms,parms,sigs
 ; does a fit of a collapsed 'fan' symmetric wrt cusps
 common stuff117,name,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,nbands,w1,w2,w3,w4
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl,imnum
 common Y, Y
 common fanstuff,rad_raw,line_raw,rad_folded,line_folded
 common thetaflags,iflag_theta,radii,theta,xline,yline
 common backgroundcounts,zodi,SLcounts
 common erry,erry
 common ifremoveZLandSL,ifremoveZLandSL,exptime
 common filterstuff,filter,if_want_replacedBS
 nparms=14
 parms=dblarr(nparms+3)
 if (file_exist('lastfit_v15') eq 1) then begin
	 get_lun,xyz 
	 openr,xyz,'lastfit_v15' 
	 liste=[]
	 x=0.0d0
	 while not eof(xyz) do begin
		 readf,xyz,x
		 liste=[liste,x]
	 endwhile
	 close,xyz 
	 free_lun,xyz
	 parms=liste
 endif else begin
	parms=findgen(nparms)*0+2.9
 pedestal=0.0
 zodi=0.0
 SLcounts=0.0
 if (ifremoveZLandSL eq 1) then begin
     get_zodiacal_smk,jd,zdflux
     zodi=zdflux*exptime
     getstarlight,jd,starlight
     SLcounts=starlight*exptime
     endif
 parms(nparms-3)=pedestal
 parms(nparms-2)=zodi
 parms(nparms-1)=SLcounts
 endelse
 p=parms
 print,'p read or set to:',p
 ; Find best parameters using MPFIT2DFUN method
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, limited:[1,1], limits:[0.D,7.0d0],step:1d-6}, nparms)
 parinfo[nparms-1-2].fixed = 0	; pedestal
 parinfo[nparms-1-1].fixed = 1	; ZL
 parinfo[nparms-1  ].fixed = 1	; SL
 ; first exponent
 parinfo[0].limited(0) = 1
 parinfo[0].limits(0)  = 0.
 parinfo[0].limited(1) = 1
 parinfo[0].limits(1)  = 7.0
 ; first exponent
 parinfo[1].limited(0) = 1
 parinfo[1].limits(0)  = 0.
 parinfo[1].limited(1) = 1
 parinfo[1].limits(1)  = 7.0
 ; first exponent
 parinfo[2].limited(0) = 1
 parinfo[2].limits(0)  = 0.
 parinfo[2].limited(1) = 1
 parinfo[2].limits(1)  = 7.0
 ; first exponent
 parinfo[3].limited(0) = 1
 parinfo[3].limits(0)  = 0.
 parinfo[3].limited(1) = 1
 parinfo[3].limits(1)  = 7.0
 ; first exponent
 parinfo[4].limited(0) = 1
 parinfo[4].limits(0)  = 0.
 parinfo[4].limited(1) = 1
 parinfo[4].limits(1)  = 7.0
 ; pedestal
 parinfo[nparms-1-1].limited(0) = 0
 parinfo[nparms-1-1].limits(0)  = 0
 parinfo[nparms-1-1].limited(1) = 0
 parinfo[nparms-1-1].limits(1)  = 0
 ; zodiacal counts
 parinfo[nparms-1-2].limited(0) = 0. ; 1
 parinfo[nparms-1-2].limits(0)  = 0.
 parinfo[nparms-1-2].limited(1) = 0
 parinfo[nparms-1-2].limits(1)  = 0.
 ; starlight counts
 parinfo[nparms-1-3].limited(0) = 0. ; 1
 parinfo[nparms-1-3].limits(0)  = 0.
 parinfo[nparms-1-3].limited(1) = 0
 parinfo[nparms-1-3].limits(1)  = 0.
 ;
 ;
 parinfo[*].value = p
 print,parinfo
 ;
 ;  now minimze on the sky by convolving the disk with the PSF
 l=size(raw,/dimensions)
 XR=indgen(l(0))
 YC=indgen(l(1))
 X = XR # (YC*0 + 1)
 Y = (XR*0 + 1) # YC
 niter=25
 Z=raw*0.0	; target is a zero plane
 print,' Before mp: ',p
 parms = MPFIT2dFUN('convolve', X, Y, Z, 0.1*sqrt(abs(raw)+max(raw)/10000.), p, yfit=yfit, $
 PARINFO=parinfo, PERROR=sigs,niter=niter,covar=covariance)
 print,'After, parms: ',parms
 ;To compute the correlation matrix, PCOR, use this example:
 nparameters=n_elements(sigs)
 PCOR = covariance* 0
 FOR i = 0, nparameters-1 DO FOR j = 0, nparameters-1 DO PCOR[i,j] = COVariance[i,j]/sqrt(COVariance[i,i]*COVariance[j,j])
 get_lun,xyz 
 openw,xyz,'lastfit_v15' 
 for igs=0,nparameters-1,1 do printf,xyz,parms(igs) 
 close,xyz 
 free_lun,xyz
 print,'Solution:'
 for kl=0,nparms-1,1 do begin
     print,'power ',kl,' :',parms(kl),' +/- ',sigs(kl)
     endfor
 print,'pedestal    :',parms(nparms-3),' +/- ',sigs(nparms-3)
;print,'Zodiacal    :',zodi,' +/- ',sigs(8)
;print,'Starlight   :',SLcounts,' +/- ',sigs(9)
 print,format='('+string(n_elements(parms))+'(1x,g8.2))',PCOR
 openw,38,'correlation_matrix.dat'
 print,'     alfa   bwpr  pedestal  albedo   xshift   corefac lamda0  yshifta     ZL       SL'
 printf,38,format='('+string(n_elements(parms))+'(1x,g8.2))',PCOR
 close,38
 return
 end
 
 
 PRO get_two_synthetic_images,JD,im1,im2,mixedimageheader,if_want_LRO
 ; Generate two FITS images of the Moon for the given JD with Earth albedo 0 and 1
 get_lun,hjkl
 openw,hjkl,'JDtouseforSYNTH_117'
 printf,hjkl,format='(f15.7)',JD
 close,hjkl
 free_lun,hjkl
 ; set up albedo 0
 get_lun,hjkl
 openw,hjkl,'single_scattering_albedo.dat'
 printf,hjkl,0.0
 close,hjkl
 free_lun,hjkl
 ;...get the image
 spawn,'idl go_get_particular_synthimage_227.pro'
 im1=readfits('ItellYOUwantTHISimage.fits',/silent)
 writefits,'im1_justaftercreation.fits',im1
 ; set up for albedo 1.0
 get_lun,hjkl
 openw,hjkl,'single_scattering_albedo.dat'
 printf,hjkl,1.0
 close,hjkl
 free_lun,hjkl
 ;...get the image
 spawn,'idl go_get_particular_synthimage_227.pro'
 im2=readfits('ItellYOUwantTHISimage.fits',/silent,mixedimageheader)
 writefits,'im2_justaftercreation.fits',im2
 return
 end
 
 
 
 
 
 ;........................................................................................
 ; Version 1 of code that finds the polynomial PSF by fitting to BS sky only
 ; using the EMF idea and masking out the lunar disc
 ;........................................................................................
 common stuff117,name,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,nbands,w1,w2,w3,w4
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl,imnum
 common fanstuff,rad_raw,line_raw,rad_folded,line_folded
 common headerstuff,mixedimageheader,header
 common thetaflags,iflag_theta,radii,theta,xline,yline
 common backgroundcounts,zodi,SLcounts
 common zodiacal,zflag,zoddata,delta_lon,delta_lat
 common sukminkwoon,iflagSMK,delta_lonSMK,delta_latSMK,zoddataSMK
 common ifremoveZLandSL,ifremoveZLandSL,exptime
 common eclipticcorrdsforMoon,jdCOMMON,raCOMMON,decCOMMON,moonECLlonCOMMON,moonECLlatCOMMON
 common filterstuff,filter,if_want_replacedBS
 common cuspanglestuff,iflagcuspangle,cangle
 common residualimage,residuals
common ifviz,ifviz
 ifviz=0
 
 
 iflagSMK=1	; seems to be a dead flag?
 zflag=1
 ifremoveZLandSL=1
 if_want_replacedBS=0	; want model BS replaced by scaled observed BS?
 if_want_LRO=1
 openw,56,'DOyouWantLROorClementine.txt'
 printf,56,if_want_LRO
 close,56
 if_smoo=0
 !P.MULTI=[0,1,1]
 !P.thick=2
 !P.CHARSIZE=1.4
 !P.thick=2
 !x.thick=2
 !y.thick=2
 lowpath='PEN/'; '/data/pth/CUBES/'
 ;.....................
 openr,3,'listtodo_fn.fitHALO'
 while not eof(3) do begin
     imnum=long(randomu(seed)*100000L)
     imnumstr=string(imnum)
     iflag_theta=1
     gump=''
     readf,3,gump
	print,'read: ',gump
     bits=strsplit(gump,' ',/extract)
     name=bits(0)
     filter=bits(1)
     JD=get_JD_from_filename(name)
     print,'JD: ',jd
     ;    filter=get_filter_from_filename(name)
     print,'Filter: ',filter
     openw,73,'FILTER.txt'
     printf,73,filter
     close,73
     mphase,jd,illfrac
     print,'Illuminated fraction: ',illfrac
     if (name eq 'STOP' or name eq 'stop') then stop
     if (illfrac lt 0.5) then begin
         file=lowpath+name
         im=readfits(file,header,/silent)
         writefits,strcompress('observed_image_JD'+string(jd,format='(f15.7)')+'_'+imnumstr+'.fits',/remove_all),im,header 
         markedupimage=im
         ;tvscl,markedupimage
         get_info_from_header,header,'EXPOSURE',exptime
         get_info_from_header,header,'DISCX0',x0
         get_info_from_header,header,'DISCY0',y0
         get_info_from_header,header,'RADIUS',radius
         print,'X0,Y0,RADIUS: ',x0,y0,radius
         if (x0 eq 0 and y0 eq 0) then begin
             print,'Second go at getting X0,Y0 ...'
             get_info_from_header,header,'X0',x0
             get_info_from_header,header,'Y0',y0
             get_info_from_header,header,'RADIUS',radius
             endif
         print,'X0,Y0,RADIUS: ',x0,y0,radius
         
         raw=im;reform(im(*,*,0))
         lll=size(raw,/dimensions)
         rawncols=lll(0)
         rawnrows=lll(1)
         labelstr=' '+'experimental'
         if (x0-radius gt 31 and rawncols-1-(x0+radius) gt 31 ) then begin
             ; ------ getthe BS touse as source
             get_source_andBSsky_using_mask,raw,BSsource,skyhalotofit,x0,y0,radius
             im1=BSsource
             im2=skyhalotofit
             ;..........................................
             gofitBSsky,BSsource,skyhalotofit,nparms,parms,sigs
             get_two_synthetic_images,JD,im1,im2,mixedimageheader,if_want_LRO
             gogetalbedoformresidualsim1im2,im1,im2,raw,residuals,x0,y0,radius,imnum,filter,JD
 openw,23,'parms_fitted.dat',/append
             printf,23,format='(f15.7,20(1x,f10.6))',JD,RMSE,parms(*)
 close,23
             print,'RMSE: ',RMSE
             endif
         endif
     endwhile
 end
