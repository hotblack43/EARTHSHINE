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
 common thetaflags,iflag_theta,radii,theta,xline,yline
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl
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
 tvscl,markedupimage
 for r=max([0,radius-w1]),min([511,radius+w2]),r_step do begin
     kdx=where(radii(idx) ge r and radii(idx) lt r+r_step)
     markedupimage(idx(kdx))=0
     tvscl,markedupimage
     if (kdx(0) ne -1) then printf,66,-mean(radii(idx(kdx))),median(im(idx(kdx))),stddev(im(idx(kdx)))
     endfor
 markedupimage=im
 markedupimage(jdx)=max(markedupimage)
 tvscl,markedupimage
 for r=radius+w3,radius+w4,r_step do begin
     kdx=where(radii(jdx) ge r and radii(jdx) lt r+r_step)
     markedupimage(jdx(kdx))=0
     tvscl,markedupimage
     nfan=n_elements(kdx)
     if (nfan gt 30) then printf,66,mean(radii(jdx(kdx))),median(im(jdx(kdx))),stddev(im(jdx(kdx)))
     endfor
 close,66
 data=get_data('temporary.dat')
 rad=reform(data(0,*))
 line=reform(data(1,*))
 err_line=reform(data(2,*)) 
 ploterr,rad,line,err_line,psym=7
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
 
 FUNCTION foldnFAN, X, P
 ; must return an array from the model 
 common stuff117,name,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,nbands,w1,w2,w3,w4
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl
 common headerstuff,mixedimageheader
 common rndstr,rnd_str
 common Y, Yobs
 common fanstuff,rad_raw,line_raw,rad_folded,line_folded
 common erry,erry
 print,format='(a,10(1x,f9.3))','In foldnFAN, p=',p
;a=get_kbrd()
 lll=size(raw,/dimensions)
 rawncols=lll(0)
 rawnrows=lll(1)
 alfa1=p(0)
 rlimit=p(1)
 pedestal=p(2)
 albedo=p(3)
 xshift=p(4)
 corefactor=p(5)
 lamda0=p(6)
 print,'lamda0: ',lamda0
  get_lun,hgjfrte & openw,hgjfrte,'LAMDA0.txt'
  	printf,hgjfrte,lamda0
  close,hgjfrte & free_lun,hgjfrte
 yshift=p(7)
 zodi=p(8)
 SLcounts=p(9)
 print,'zodi and SLcounts: ',zodi,SLcounts
 mixedimage=im1*(1.0-albedo)+im2*albedo
 ; identify the pixel that should have added Zodial light corrections
 idx=where(mixedimage eq 0.0)
 ; fold 
 writefits,'mixed117.fits',mixedimage,mixedimageheader
 str='./justconvolve_scwc mixed117.fits trialout117.fits '+string(alfa1)+' '+string(corefactor)+' '+string(rlimit)
 spawn,str
 folded=readfits('trialout117.fits',/silent)
 folded=shift_sub(folded,xshift,yshift)+pedestal
 folded=folded/total(folded,/double)*total(raw,/double)
 ; now add the ZL+SL correction to the sky-only pixels
 folded(idx)=folded(idx)+zodi+SLcounts
 tvscl,folded
 writefits,strcompress('OUTPUT/IDEAL/synth_folded_scaled_shifted_JD'+string(JD,format='(f15.7)')+'.fits',/remove_all),folded
 writefits,'foldedYES.fits',folded
 ;==================folded image now read for use=============================
 imethod=3
 ; get the 'fan' for the folded image
 use_cusp_angle_fan_DS_BS,folded,x0,y0,radius,rad_folded,line_folded,dummy,imethod,w1,w2,w3,w4
 if (if_smoo eq 1) then line_folded=smooth(line_folded,11,/edge_truncate)
 ;ldx=where(rad_folded gt radius-w2 and rad_folded le radius+w1)
 ;value=line_folded(ldx)
 ;x=rad_folded(ldx)
 value=line_folded
 x=rad_folded
 rad_folded=x
 ;=============================================PLOT AFTER THIS===================
 set_plot,'X'
 !P.MULTI=[0,1,1]
 ladder_plot,x,Yobs,value,'Columns','Observed and fitted counts',labelstr+name
 line=Yobs
 resids=(line-value)
 w=1./erry
 RMSE=sqrt(total(resids^2)/n_elements(resids))
 ;---------legend
 ystart=!Y.crange(1)
 ystep=(!Y.crange(1)-!Y.crange(0))/20.
 q=!x.crange(0)+(!x.crange(1)-!x.crange(0))/10.
 xyouts,q,ystart-1.*ystep,'!7a!d1!n!3 = '+string(alfa1,format='(f7.4)')
 xyouts,q,ystart-2.*ystep,'r!dlim!n   = '+string(rlimit,format='(f7.4)')
 xyouts,q,ystart-3.*ystep,'pedestal   = '+string(pedestal,format='(f8.3)')
 xyouts,q,ystart-4.*ystep,'!7D!3x     = '+string(xshift,format='(f7.4)')
 xyouts,q,ystart-5.*ystep,'!7D!3y     = '+string(yshift,format='(f7.4)')
 xyouts,q,ystart-6.*ystep,'f!dcore!n  = '+string(corefactor,format='(f7.4)')
 xyouts,q,ystart-7.*ystep,'lamda0   = '+string(lamda0,format='(f7.2)')
 xyouts,q,ystart-8.*ystep,'RMSE = '+string(RMSE,format='(f7.4)')
 xyouts,q,ystart-9.*ystep,'A* = '+string(albedo,format='(f7.4)')
 xyouts,q,ystart-10.*ystep,'ZL = '+string(zodi,format='(f7.4)')
 xyouts,q,ystart-11.*ystep,'SL = '+string(SLcounts,format='(f7.4)')
 WRITE_JPEG,strcompress('OUTPUT/'+string(JD,format='(f15.7)')+labelstr+'_'+rnd_str+'.jpg',/remove_all),tvrd(true=1),true=1
 ;---------------------
 return,value
 END
 
 PRO gofitFAN,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,lamda0
 ; does a fit of a collapsed 'fan' symmetric wrt cusps
 common stuff117,name,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,nbands,w1,w2,w3,w4
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl
 common Y, Y
 common fanstuff,rad_raw,line_raw,rad_folded,line_folded
 common thetaflags,iflag_theta,radii,theta,xline,yline
 common backgroundcounts,zodi,SLcounts
 common erry,erry
 common ifremoveZLandSL,ifremoveZLandSL,exptime
 common filterstuff,filter,if_want_replacedBS
 lll=size(raw,/dimensions)
 rawncols=lll(0)
 rawnrows=lll(1)
 ; determine if flip of ideals are needed
 idelatester=im1+im2
 determineFLIP2,idelatester,raw,x0,y0,flipneed,flopneeded
 if (flipneed eq 1) then begin
     im1=reverse(im1,1)
     im2=reverse(im2,1)
     endif
 if (flopneeded eq 1) then begin
     im1=reverse(im1,2)
     im2=reverse(im2,2)
     endif
 ; then shift to match observed image c entre
 im1=shift(im1,x0-256,y0-256)
 im2=shift(im2,x0-256,y0-256)
 writefits,'im1.fits',im1
 writefits,'im2.fits',im2
 ; now go and rebuild im1 and im2 by replacing their BSs by the observed BS
 if (if_want_replacedBS eq 1) then begin
 buildim,im1,im2,raw,im1replaced,im2replaced
 im1=im1replaced
 im2=im2replaced
writefits,'im1replaced.fits',im1
writefits,'im2replaced.fits',im2
 print,'The model BS has been replaced by the scaled observed BS'
 endif
 ; Define the starting point:
 alfa1=1.75
 rlimit=3.0
 pedestal=0.00
 albedo=0.280219730
 xshift=0.0
 corefactor=1.000
 lamda0=456.0
     getlamda0fromfiltername,filter,lamda0
 yshift=0.0;47131281
 zodi=0.0
 SLcounts=0.0
 p = [alfa1,rlimit,pedestal,albedo,xshift,corefactor,lamda0,yshift,zodi,SLcounts]
;if (file_exist('lastfit_v14') eq 1) then begin
;    get_lun,xyz
;    pp=p
;    openr,xyz,'lastfit_v14'
;    readf,xyz,pp
;    close,xyz
;    free_lun,xyz
;    p=pp
;    endif
 zodi=0.0
 SLcounts=0.0
 if (ifremoveZLandSL eq 1) then begin
     get_zodiacal_smk,jd,zdflux
     zodi=zdflux*exptime
     getstarlight,jd,starlight
     SLcounts=starlight*exptime
     p(8)=zodi
     p(9)=SLcounts
     endif
 ; Find best parameters using MPFIT2DFUN method
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, limited:[0,0], limits:[0.D,0],step:1d-4}, 10)
 parinfo[0].fixed = 0	; alfa1
 parinfo[1].fixed = 1	; rlimit
 parinfo[2].fixed = 0	; pedestal
 parinfo[3].fixed = 0	; albedo
 parinfo[4].fixed = 0	; xshift
 parinfo[5].fixed = 0	; corefactor
 parinfo[6].fixed = 1	; lamda0
 parinfo[7].fixed = 1	; yshift
 parinfo[8].fixed = 1	; ZL always fixed
 parinfo[9].fixed = 1	; SL always fixed
 ; alfa1 - the 'wing alfa'
 parinfo[0].limited(0) = 1
 parinfo[0].limits(0)  = 1.1
 parinfo[0].limited(1) = 1
 parinfo[0].limits(1)  = 3.1
 ; rlimit 
 parinfo[1].limited(0) = 1
 parinfo[1].limits(0)  = 2
 parinfo[1].limited(1) = 1
 parinfo[1].limits(1)  = 10
 ; pedestal
 parinfo[2].limited(0) = 1
 parinfo[2].limits(0)  = -200.0
 parinfo[2].limited(1) = 1
 parinfo[2].limits(1)  =900.0 
 ; albedo
 parinfo[3].limited(0) = 1
 parinfo[3].limits(0)  = 0.0
 parinfo[3].limited(1) = 1
 parinfo[3].limits(1)  = 1.0
 ; xshift
 parinfo[4].limited(0) = 1
 parinfo[4].limits(0)  = -3
 parinfo[4].limited(1) = 1
 parinfo[4].limits(1)  = 3
 ; core factor
 parinfo[5].limited(0) = 1
 parinfo[5].limits(0)  = 0.1
 parinfo[5].limited(1) = 0
 parinfo[5].limits(1)  = 3
 ; lamda0 of LRO map
 parinfo[6].limited(0) = 1
 parinfo[6].limits(0)  = 302
 parinfo[6].limited(1) = 1
 parinfo[6].limits(1)  = 709
 ; y-shift
 parinfo[7].limited(0) = 1
 parinfo[7].limits(0)  = -6.
 parinfo[7].limited(1) = 1
 parinfo[7].limits(1)  = 6.
 ; zodiacal counts
 parinfo[8].limited(0) = 0. ; 1
 parinfo[8].limits(0)  = 0.
 parinfo[8].limited(1) = 0
 parinfo[8].limits(1)  = 0.
 ; starlight counts
 parinfo[9].limited(0) = 0. ; 1
 parinfo[9].limits(0)  = 0.
 parinfo[9].limited(1) = 0
 parinfo[9].limits(1)  = 0.
 ;
 p(4)=0.0	; xshift
;p(6)=1.0	; B lamda0
 ;
 parinfo[*].value = p
 ;
 w1=80	; inside edge on DS sky
 w2=100	; outside disc edge on DS disc
 w3=40	; beyond edge on BS sky
 w4=100  ; beyond egde  on BS sky
 ; get the 'fan' for observations
 kmethod=3       ; i.e. mean halfmedian of annulus-segments
 use_cusp_angle_fan_DS_BS,raw,x0(0),y0(0),radius,rad_raw,line_raw,erry,kmethod,w1,w2,w3,w4
 y=line_raw
 if (if_smoo eq 1) then y=smooth(y,11,/edge_truncate)
 ;ldx=where(rad_raw gt radius-w2 and rad_raw le radius+w1)
 ;y=y(ldx)
 ;erry=erry(ldx)
 x=randomu(seed,n_elements(y))	; dummy assignemnt - x is not used later
 niter=500
 parms = MPFITFUN('foldnFAN', X, Y, 0.43*erry/sqrt(8.1), p, yfit=yfit, $
 PARINFO=parinfo, $
 PERROR=sigs,niter=niter,covar=covariance)
 ;To compute the correlation matrix, PCOR, use this example:
 nparameters=n_elements(sigs)
 PCOR = covariance* 0
 FOR i = 0, nparameters-1 DO FOR j = 0, nparameters-1 DO PCOR[i,j] = COVariance[i,j]/sqrt(COVariance[i,i]*COVariance[j,j])
 
 alfa1=parms(0)
 rlimit=parms(1)
 pedestal=parms(2)
 albedo=parms(3)
 xshift=parms(4)
 corefactor=parms(5)
 lamda0=parms(6)
 yshift=parms(7)
 get_lun,xyz & openw,xyz,'lastfit_v14' &printf,xyz,format='(10(1x,f15.9))',parms & close,xyz & free_lun,xyz
 print,'Solution:'
 print,'alfa1       :',alfa1,' +/- ',sigs(0)
 print,'rlimit      :',rlimit,' +/- ',sigs(1)
 print,'pedestal    :',pedestal,' +/- ',sigs(2)
 print,'Zodiacal    :',zodi,' +/- ',sigs(8)
 print,'Starlight   :',SLcounts,' +/- ',sigs(9)
 print,'xshift      :',xshift,' +/- ',sigs(4)
 print,'yshift      :',yshift,' +/- ',sigs(7)
 print,'corefactor  :',corefactor,' +/- ',sigs(5)
 print,'lamda0    :',lamda0,' +/- ',sigs(6)
 print,'albedo      :',albedo,' +/- ',sigs(3)
 print,format='('+string(n_elements(parms))+'(1x,g8.2))',PCOR
 openw,38,'correlation_matrix.dat'
print,'     alfa   rlimit  pedestal  albedo   xshift   corefac lamda0  yshifta     ZL       SL'
 printf,38,format='('+string(n_elements(parms))+'(1x,g8.2))',PCOR
 close,38
 erralbedo=sigs(3)
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
 ; Version 13 of code that finds albedo by model-fitting
 ; Like version 12, but uses LRO lunar albedo maps with Clementine infill above 70 deg lat
 ;........................................................................................
 common stuff117,name,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,nbands,w1,w2,w3,w4
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl
 common fanstuff,rad_raw,line_raw,rad_folded,line_folded
 common headerstuff,mixedimageheader
 common thetaflags,iflag_theta,radii,theta,xline,yline
 common backgroundcounts,zodi,SLcounts
 common zodiacal,zflag,zoddata,delta_lon,delta_lat
 common sukminkwoon,iflagSMK,delta_lonSMK,delta_latSMK,zoddataSMK
 common ifremoveZLandSL,ifremoveZLandSL,exptime
 common rndstr,rnd_str
 common eclipticcorrdsforMoon,jdCOMMON,raCOMMON,decCOMMON,moonECLlonCOMMON,moonECLlatCOMMON
 common filterstuff,filter,if_want_replacedBS
 common cuspanglestuff,iflagcuspangle,cangle

 
 iflagSMK=1	; seems to be a dead flag?
 zflag=1
 ifremoveZLandSL=1
 if_want_replacedBS=0	; want model BS replaced by scaled observed BS?
 if_want_LRO=1
 openw,56,'DOyouWantLROorClementine.txt'
 printf,56,if_want_LRO
 close,56
 bandnames=['A','B','C','D','E','F','G','H','J','K','L','M','N']
 if_smoo=0
 !P.MULTI=[0,1,1]
 !P.thick=2
 !P.CHARSIZE=1.4
 !P.thick=2
 !x.thick=2
 !y.thick=2
 lowpath=''; '/data/pth/CUBES/'
;.....................
 openr,3,'listtodo.txt'
 while not eof(3) do begin
     rnd_str=string(long(randomu(seed)*100000L))
     iflag_theta=1
     name=''
     readf,3,name
     JD=get_JD_from_filename(name)
     print,'JD: ',jd
     filter=get_filter_from_filename(name)
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
         writefits,'observed_image_JD'+string(jd,format='(f15.7)')+'.fits',im,header 
         markedupimage=im
         tvscl,markedupimage
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
         findcuspanglefromimage,im,x0,y0,radius(0),cangle
openw,91,'cuspangle.txt',/append
         print,jd,' cangle: ',cangle
         printf,91,format='(f15.7,a,f9.3)',jd,' cangle: ',cangle
close,91

         raw=im;reform(im(*,*,0))
         lll=size(raw,/dimensions)
         rawncols=lll(0)
         rawnrows=lll(1)
         if (x0-radius gt 31 and rawncols-1-(x0+radius) gt 31 ) then begin
             ;.......get the two synthetic ideal images
             
             ; loop over 'bands' on the disc
             get_two_synthetic_images,JD,im1_good,im2_good,mixedimageheader,if_want_LRO
             labelstr=' '+'LRO_scaled'
             im1=im1_good
             im2=im2_good
             ;..........................................
             gofitFAN,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,lamda0
             print,'RMSE: ',RMSE
             print,'Albedo:',albedo,' +/- ',erralbedo
             totfl=total(raw-pedestal,/double)
             fmtstr44='(f15.7,9(1x,f9.5),1x,f10.3,1x,f15.3,2(1x,f10.7),1x,g15.6,2(1x,a))'
             openw,63,'CLEM.testing_OCT24_2014.txt',/append
             flux=totfl/exptime
             printf,63,format=fmtstr44,JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,lamda0,RMSE,totfl,zodi,SLcounts,flux,name,labelstr
             close,63
             writefits,'markedupimage.fits',markedupimage,header
             endif else begin
             print,'Not glad about your x0,y0: ',x0-radius,rawncols-1-(x0+radius),' lt 31?'
             endelse
         endif
         fmt16='(f15.7,4(1x,f10.4))'
 if (ifremoveZLandSL eq 1) then begin
 get_lun,hgcffdgr
 openw,hgcffdgr,'Moons_coordinates.dat',/append
         printf,hgcffdgr,format=fmt16,jdCOMMON,raCOMMON,decCOMMON,moonECLlonCOMMON,moonECLlatCOMMON
 close,hgcffdgr
 free_lun,hgcffdgr
 endif
     spawn,'./safekeep.scr '+string(jd,format='(f15.7)')
     endwhile; end of image loop
 close,3
 end
