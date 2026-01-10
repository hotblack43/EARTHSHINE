PRO go_contrast_im2,im2,im2contrasted,contrast
 ; will scale the contrast of im2s DS
 im2contrasted=im2
 jdx=where(im2 eq 0.0)
 idx=where(im2 lt max(im2)/500. and im2 ne 0.0)
 mv=mean(im2(idx),/double)
 ;mv=median(im2(idx))
 im2contrasted(idx)=(im2(idx)-mv)*contrast+mv
 ;print,'Contrasted lunar albedo image with factor ',contrast
 return
 end
 
 FUNCTION get_JD_from_filename,name
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
 ;tvscl,[raw,ideal] & j=get_kbrd()
 ;..........................
 ; just a flip
 ideal=ideal_in/max(ideal_in)
 ideal=reverse(ideal,1)
 ideal=shift(ideal,x0-256,y0-256)
 r2=correlate(raw,ideal)
 ;tvscl,[raw,ideal] & j=get_kbrd()
 ;..........................
 ; just a flop
 ideal=ideal_in/max(ideal_in)
 ideal=reverse(ideal,2)
 ideal=shift(ideal,x0-256,y0-256)
 r3=correlate(raw,ideal)
 ;tvscl,[raw,ideal] & j=get_kbrd()
 ;..........................
 ; a flip and a flop
 ideal=ideal_in/max(ideal_in)
 ideal=reverse(reverse(ideal,1),2)
 ideal=shift(ideal,x0-256,y0-256)
 r4=correlate(raw,ideal)
 ;tvscl,[raw,ideal] & j=get_kbrd()
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
 
 FUNCTION foldnPATCH, X, P
 ; must return the folded model averaged over rows 246:266
 common stuff117,name,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,nbands
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl
 common headerstuff,mixedimageheader
 common Y, Yobs
 lll=size(raw,/dimensions)
 rawncols=lll(0)
 rawnrows=lll(1)
 alfa1=p(0)
 rlimit=p(1)
 pedestal=p(2)
 albedo=p(3)
 xshift=p(4)
 corefactor=p(5)
 contrast=p(6)
 yshift=p(7)
 go_contrast_im2,im2,im2contrasted,contrast
 mixedimage=im1*(1.0-albedo)+im2contrasted*albedo;+pedestal
 ; fold first time - for the 'core'
 writefits,'mixed117.fits',mixedimage,mixedimageheader
 str='./justconvolve_scwc mixed117.fits trialout117.fits '+string(alfa1)+' '+string(corefactor)+' '+string(rlimit)
 spawn,str
 folded=readfits('trialout117.fits',/silent)
 folded=shift_sub(folded,xshift,yshift)+pedestal
 folded=folded/total(folded,/double)*total(raw,/double)
 tvscl,folded
;------------------------------------------
 w1=50
 w2=70
; set up the multipatch pointers
 for iband=-nbands,nbands,1 do begin
 	use1=max([0,fix(x0-sqrt(radius^2-(iband*10)^2)-w1)])
 	use2=min([rawncols-1,fix(use1+w2+w1)])
;	print,'Patch ',iband,': Use1 use2: ',use1,use2
 	row_from=y0-10+iband*10
 	row_to  =y0+10+iband*10
;	print,'From row, to row: ',row_from,row_to
 		value_band=avg(folded(use1:use2,row_from:row_to),1)
 		markedupimage(use1:use2,row_from:row_to)=max(markedupimage)
 		if (iband eq -nbands) then value=value_band
 		if (iband gt -nbands) then value=[value,value_band]
 endfor
 if (if_smoo eq 1) then value=smooth(value,11,/edge_truncate)
 x=findgen(n_elements(value))
;------------------------------------------
 set_plot,'X'
 !P.MULTI=[0,1,1]
 ladder_plot,x,Yobs,value,'Columns','Observed and fitted counts',labelstr+name
 ;print,'Back from ladder plot'
 line=Yobs
 RMSE=sqrt(total((line-value)^2)/n_elements(line))
 resids=(line-value)
 ;---------legend
 ystart=!Y.crange(1)
 ystep=(!Y.crange(1)-!Y.crange(0))/20.
 xyouts,10,ystart-1.*ystep,'!7a!d1!n!3 = '+string(alfa1,format='(f7.4)')
 xyouts,10,ystart-2.*ystep,'r!dlim!n   = '+string(rlimit,format='(f7.4)')
 xyouts,10,ystart-3.*ystep,'pedestal   = '+string(pedestal,format='(f8.3)')
 xyouts,10,ystart-4.*ystep,'!7D!3x     = '+string(xshift,format='(f7.4)')
 xyouts,10,ystart-5.*ystep,'!7D!3y     = '+string(yshift,format='(f7.4)')
 xyouts,10,ystart-6.*ystep,'f!dcore!n  = '+string(corefactor,format='(f7.4)')
 xyouts,10,ystart-7.*ystep,'contrast   = '+string(contrast,format='(f7.4)')
 xyouts,10,ystart-8.*ystep,'RMSE = '+string(RMSE,format='(f7.4)')
 xyouts,10,ystart-9.*ystep,'A* = '+string(albedo,format='(f7.4)')
 WRITE_JPEG,strcompress(labelstr+string(JD,format='(f15.7)')+'.jpg',/remove_all),tvrd(true=1),true=1
 ;---------------------
 return,value
 END
 
 PRO gofitMULTIpatches,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,contrast
 ; does a fit of several concatenated 'patches' - not individual bands as in gofit117...
 common stuff117,name,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,nbands
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl
 common Y, Y
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
 ; Define the starting point:
 alfa1=1.580444912
 rlimit=3.0
 pedestal=-0.054570004
 albedo=0.280219730
 xshift=-0.982808505
 corefactor=16.646281412
 contrast=0.785782418
 yshift=0.047131281
 p = [alfa1,rlimit,pedestal,albedo,xshift,corefactor,contrast,yshift]
 ;if (file_exist('lastfit') eq 1) then begin
 ;    get_lun,xyz
 ;    pp=p
 ;    openr,xyz,'lastfit'
 ;    readf,xyz,pp
 ;    close,xyz
 ;    free_lun,xyz
 ;    p=pp
 ;   endif
 if (if_jiggle eq 1) then p=p*(1.0+jiggle_ampl/100.0*randomn(seed,n_elements(p)))
 p(1)=3.0
 ; Find best parameters using MPFIT2DFUN method
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, limited:[0,0], limits:[0.D,0],step:1d-4}, 8)
 parinfo[0].fixed = 0
 parinfo[1].fixed = 1
 parinfo[2].fixed = 0
 parinfo[3].fixed = 0
 parinfo[4].fixed = 0
 parinfo[5].fixed = 0
 parinfo[6].fixed = 0
 parinfo[7].fixed = 0
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
 ; contrast on lunar surface
 parinfo[6].limited(0) = 1
 parinfo[6].limits(0)  = 0.2
 parinfo[6].limited(1) = 1
 parinfo[6].limits(1)  = 1.4
 ; y-shift
 parinfo[7].limited(0) = 1
 parinfo[7].limits(0)  = -6.
 parinfo[7].limited(1) = 1
 parinfo[7].limits(1)  = 6.
 ;
 parinfo[*].value = p
 ;
 w1=50
 w2=70
; set up the multipatch pointers
 for iband=-nbands,nbands,1 do begin
 	use1=max([0,fix(x0-sqrt(radius^2-(iband*10)^2)-w1)])
 	use2=min([rawncols-1,fix(use1+w2+w1)])
;	print,'Patch ',iband,': Use1 use2: ',use1,use2
 	row_from=y0-10+iband*10
 	row_to  =y0+10+iband*10
;	print,'From row, to row: ',row_from,row_to
 		yband=avg(raw(use1:use2,row_from:row_to),1)
 		if (iband eq -nbands) then y=yband
 		if (iband gt -nbands) then y=[y,yband]
 endfor
 x=findgen(n_elements(y))	; dummy assignemnt - x is not used later
 erry=sqrt(abs(y))/sqrt(21.*nbands*100.)/1.4;*4.28	; typically 21 rows per band in 100 images make up each 'band'
 niter=500
 if (if_smoo eq 1) then y=smooth(y,11,/edge_truncate)
 parms = MPFITFUN('foldnPATCH', X, Y, erry, p, yfit=yfit, $
 PARINFO=parinfo, $
 PERROR=sigs,niter=niter)
 alfa1=parms(0)
 rlimit=parms(1)
 pedestal=parms(2)
 albedo=parms(3)
 xshift=parms(4)
 corefactor=parms(5)
 contrast=parms(6)
 yshift=parms(7)
 get_lun,xyz & openw,xyz,'lastfit' &printf,xyz,format='(10(1x,f15.9))',parms & close,xyz & free_lun,xyz
 print,'Solution:'
 print,'alfa1       :',alfa1,' +/- ',sigs(0)
 print,'rlimit      :',rlimit,' +/- ',sigs(1)
 print,'pedestal    :',pedestal,' +/- ',sigs(2)
 print,'albedo      :',albedo,' +/- ',sigs(3)
 print,'xshift      :',xshift,' +/- ',sigs(4)
 print,'yshift      :',yshift,' +/- ',sigs(7)
 print,'corefactor  :',corefactor,' +/- ',sigs(5)
 print,'contrast    :',contrast,' +/- ',sigs(6)
 erralbedo=sigs(3)
 return
 end
 
 
 PRO get_two_synthetic_images,JD,im1,im2,mixedimageheader
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
 spawn,'idl go_get_particular_synthimage_117.pro'
 im1=readfits('ItellYOUwantTHISimage.fits',/silent)
 tvscl,im1
 ; set up for albedo 1.0
 get_lun,hjkl
 openw,hjkl,'single_scattering_albedo.dat'
 printf,hjkl,1.0
 close,hjkl
 free_lun,hjkl
 ;...get the image
 spawn,'idl go_get_particular_synthimage_117.pro'
 im2=readfits('ItellYOUwantTHISimage.fits',/silent,mixedimageheader)
 tvscl,im2
 return
 end
 
 
 
 
 
 ;........................................................
 ; Version 3 of code that finds albedo by model-fitting
 ; Scales also lunar albedo-map (contrast)
 common stuff117,name,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,nbands
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl
 common headerstuff,mixedimageheader
 bandnames=['A','B','C','D','E','F','G','H','J','K','L','M','N']
 if_smoo=1
 if_jiggle=1
 jiggle_ampl=3.0	;jiggle startimng guesses by this many percent	%
 !P.MULTI=[0,1,1]
 !P.thick=2
 !P.CHARSIZE=1.4
 !P.thick=2
 !x.thick=2
 !y.thick=2
 lowpath=''; '/data/pth/CUBES/'
 openr,3,'listtodo.txt'
 ;openr,3,'testlist.txt'
 while not eof(3) do begin
     name=''
     readf,3,name
     if (name eq 'STOP' or name eq 'stop') then stop
     file=lowpath+name
     im=readfits(file,header,/silent)
     writefits,'observed_image.fits',im,header 
     markedupimage=im
     tvscl,im
     print,file
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
     if (x0-radius gt 40 and rawncols-1-(x0+radius) gt 40) then begin
         ;.......get the two synthetic ideal images
         JD=get_JD_from_filename(name)
         print,'JD: ',jd
         ; loop over 'bands' on the disc
         get_two_synthetic_images,JD,im1_good,im2_good,mixedimageheader
         nbands=5
             labelstr=' '+strcompress('MP'+string(nbands),/remove_all)
             im1=im1_good
             im2=im2_good
             ;..........................................
             gofitMULTIpatches,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,contrast
             print,'RMSE: ',RMSE
             print,'Albedo:',albedo,' +/- ',erralbedo
             totfl=total(raw-pedestal,/double)
             fmtstr44='(f15.7,9(1x,f9.5),1x,f10.3,1x,f15.3,1x,a,1x,a)'
             openw,63,'CLEM.profiles_fitted_results_3treatments_multipatch_rlim_fixed_jiggled_smoo.txt',/append
             printf,63,format=fmtstr44,JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,contrast,RMSE,totfl,name,labelstr
             close,63
             writefits,'markedupimage.fits',markedupimage,header
         endif
     endwhile; end of image loop
 close,3
 end
