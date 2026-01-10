PRO go_contrast_im2,im2,im2contrasted,contrast
; will scale the contrast of im2s DS
im2contrasted=im2
jdx=where(im2 eq 0.0)
idx=where(im2 lt max(im2)/500. and im2 ne 0.0)
mv=median(im2(idx))
im2contrasted(idx)=(im2(idx)-mv)*contrast+mv
print,'Contrasted lunar albedo image with factor ',contrast
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

 FUNCTION foldnstuff, X, P
; must return the folded model averaged over rows 246:266
 common stuff117,name,nx,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,iband
 common namingstuff,JD
 if (iband lt 0) then bandstr='A_'
 if (iband eq 0) then bandstr='B_'
 if (iband gt 0) then bandstr='C_'
 alfa1=p(0)
 rlimit=p(1)
 pedestal=p(2)
 albedo=p(3)
 xshift=p(4)
 corefactor=p(5)
 contrast=p(6)
 go_contrast_im2,im2,im2contrasted,contrast
 mixedimage=im1*(1.0-albedo)+im2contrasted*albedo;+pedestal
; fold first time - for the 'core'
 writefits,'mixed117.fits',mixedimage
 str='./justconvolve_scwc mixed117.fits trialout117.fits '+string(alfa1)+' '+string(corefactor)+' '+string(rlimit)
 spawn,str
 folded=readfits('trialout117.fits',/silent)
 folded=shift_sub(folded,xshift,0)+pedestal
 folded=folded/total(folded,/double)*total(raw,/double)
tvscl,folded
 value=avg(folded(use1:use2,y0-10+iband*10:y0+10+iband*10),1)
set_plot,'X'
!P.MULTI=[0,1,1]
ladder_plot,x,avg(raw(use1:use2,y0-10+iband*10:y0+10+iband*10),1),value,'Columns','Observed and fitted counts',bandstr+name
 print,'Back from ladder plot'
 line=avg(raw(*,y0-10+iband*10:y0+10+iband*10),1)
 y=line(use1:use2)*1.0d0
 RMSE=sqrt(total((y-value)^2)/n_elements(y))
 resids=(y-value)
 print,'SD on residuals on DS sky: ',stddev(resids(10:40))
;---------legend
ystart=!Y.crange(1)
ystep=(!Y.crange(1)-!Y.crange(0))/20.
xyouts,10,ystart-1.*ystep,'!7a!d1!n!3 = '+string(alfa1,format='(f7.4)')
xyouts,10,ystart-2.*ystep,'r!dlim!n   = '+string(rlimit,format='(f7.4)')
xyouts,10,ystart-3.*ystep,'pedestal   = '+string(pedestal,format='(f8.3)')
xyouts,10,ystart-4.*ystep,'!7D!3      = '+string(xshift,format='(f7.4)')
xyouts,10,ystart-5.*ystep,'f!dcore!n  = '+string(corefactor,format='(f7.4)')
xyouts,10,ystart-6.*ystep,'contrast   = '+string(contrast,format='(f7.4)')
xyouts,10,ystart-7.*ystep,'RMSE = '+string(RMSE,format='(f7.4)')
xyouts,10,ystart-8.*ystep,'A* = '+string(albedo,format='(f7.4)')
WRITE_JPEG,strcompress(bandstr+string(JD,format='(f15.7)')+'.jpg',/remove_all),tvrd(true=1),true=1
;---------------------
 return,value
 END

 PRO gofit117thway,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,corefactor,contrast
 common stuff117,name,nx,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,iband
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
 alfa1=1.9d0
 rlimit=4
 pedestal=+0.3d0
 albedo=0.29d0
 xshift=0.0d0
 corefactor=1.0d0
 contrast=1.0d0
 p = [alfa1,rlimit,pedestal,albedo,xshift,corefactor,contrast]
if (file_exist('lastfit') eq 1) then begin
get_lun,xyz
       pp=p
       openr,xyz,'lastfit'
       readf,xyz,pp
       close,xyz
       free_lun,xyz
	p=pp
endif
 ; Find best parameters using MPFIT2DFUN method
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, limited:[0,0], limits:[0.D,0],step:1d-3}, 7)
 parinfo[0].fixed = 0
 parinfo[1].fixed = 0
 parinfo[2].fixed = 0
 parinfo[3].fixed = 0
 parinfo[4].fixed = 0
 parinfo[5].fixed = 0
 parinfo[6].fixed = 0
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
 parinfo[5].limits(0)  = 0
 parinfo[5].limited(1) = 0
 parinfo[5].limits(1)  = 3
 ; contrast on lunar surface
 parinfo[6].limited(0) = 1
 parinfo[6].limits(0)  = 0.2
 parinfo[6].limited(1) = 1
 parinfo[6].limits(1)  = 1.4
 ;
 parinfo[*].value = p
 ;
 w1=50
 w2=100
 use1=max([0,fix(x0-radius-w1)])
 use2=min([511,fix(use1+w2+w1)])
 print,'Use1 use2: ',use1,use2
 nx=abs(use2-use1)+1
 x=findgen(nx)
 line=avg(raw(*,y0-10+iband*10:y0+10+iband*10),1)
 y=line(use1:use2)*1.0d0
 erry=y*0+0.05d0
 niter=1000
 parms = MPFITFUN('foldnstuff', X, Y, erry, p, yfit=yfit, $
                PARINFO=parinfo, $
                PERROR=sigs,niter=niter)
 alfa1=parms(0)
 rlimit=parms(1)
 pedestal=parms(2)
 albedo=parms(3)
 xshift=parms(4)
 corefactor=parms(5)
 contrast=parms(6)
 get_lun,xyz & openw,xyz,'lastfit' &printf,xyz,format='(10(1x,f15.9))',parms & close,xyz & free_lun,xyz
 print,'Solution:'
 print,'alfa1       :',alfa1,' +/- ',sigs(0)
 print,'rlimit      :',rlimit,' +/- ',sigs(1)
 print,'pedestal    :',pedestal,' +/- ',sigs(2)
 print,'albedo      :',albedo,' +/- ',sigs(3)
 print,'xshift      :',xshift,' +/- ',sigs(4)
 print,'corefactor  :',corefactor,' +/- ',sigs(5)
 print,'contrast    :',contrast,' +/- ',sigs(6)
 erralbedo=sigs(3)
 return
 end


PRO get_two_synethic_images,JD,im1,im2
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
im2=readfits('ItellYOUwantTHISimage.fits',/silent)
tvscl,im2
return
end





;........................................................
; Version 3 of code that finds albedo by model-fitting
; Scales also lunar albedo-map (contrast)
 common stuff117,name,nx,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,iband
 common namingstuff,JD
!P.MULTI=[0,1,1]
!P.thick=2
!P.CHARSIZE=1.3
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
tvscl,im
print,file
get_info_from_header,header,'DISCX0',x0
get_info_from_header,header,'DISCY0',y0
get_info_from_header,header,'RADIUS',radius
print,x0,y0,radius
if (x0-radius gt 40 and 511-(x0+radius) gt 40) then begin
raw=im;reform(im(*,*,0))
;.......get the two synthetic ideal images
JD=get_JD_from_filename(name)
print,'JD: ',jd
; loop over 'bands' on the disc
get_two_synethic_images,JD,im1_good,im2_good
for iband=-1,1,1 do begin
im1=im1_good
im2=im2_good
;..........................................
gofit117thway,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,corefactor,contrast
print,'iband: ',iband
print,'RMSE: ',RMSE
print,'Albedo:',albedo,' +/- ',erralbedo
totfl=total(raw-pedestal,/double)
fmtstr44='(f15.7,8(1x,f8.4),1x,f10.3,1x,f15.3,1x,a)'
openw,63,'NEW_TEST_CONTINUED.CLEM.profiles_fitted_results_April_24_2013.txt',/append
printf,63,format=fmtstr44,JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,corefactor,contrast,RMSE,totfl,name
close,63
endfor
endif
endwhile; end of image loop
close,3
end
