FUNCTION pth_rebin,arr2d,n,m
 ; like REBIN, will split an array into averaged bins xxm
 l=size(arr2d,/dimensions)
 ncols=l(0)
 nrows=l(1)
 wcols=fix(ncols/float(n))
 wrows=fix(nrows/float(m))
 nout=round(ncols/float(wcols))
 mout=round(nrows/float(wrows))
 outarr=fltarr(nout,mout)
 for i=0,nout-1,1 do begin
     for j=0,mout-1,1 do begin
         ileft=wcols*i
         iright=ileft+wcols-1
         jdown=wrows*j
         jup=jdown+wrows-1
         small=arr2d(ileft:iright,jdown:jup)
;        outarr(i,j)=mean(small)
;        print,i,j,mean(small),ileft,iright,jdown,jup
         outarr(i,j)=median(small)
;        print,i,j,mean(small),ileft,iright,jdown,jup
         endfor
     endfor
 return,outarr
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
 spawn,'idl go_get_particular_synthimage_227.pro';,/NOSHELL
 im1=readfits('ItellYOUwantTHISimage.fits')
 writefits,'im1_justaftercreation.fits',im1
 ; set up for albedo 1.0
 get_lun,hjkl
 openw,hjkl,'single_scattering_albedo.dat'
 printf,hjkl,1.0
 close,hjkl
 free_lun,hjkl
 ;...get the image
 spawn,'idl go_get_particular_synthimage_227.pro';,/NOSHELL
 im2=readfits('ItellYOUwantTHISimage.fits',mixedimageheader)
 writefits,'im2_justaftercreation.fits',im2
 return
 end
 
 ;================================================================
 ; Version 1. Code to produce image summaries suitable for PLS
 ;================================================================
 close,/all
 nbins=4
 nstr=string(4+nbins*nbins)
 fmt='('+nstr+'(1x,f15.9))'
 JD=systime(/utc,/julian)
 JD=2456104.0d0-3.0d0
 get_two_synthetic_images,JD,im1,im2,mixedimageheader,if_want_LRO
 if_want_training_set=1
 if (if_want_training_set eq 1) then begin
     openw,18,strcompress('binned_images'+string(nbins)+'x'+string(nbins)+'.dat',/remove_all)
     for albedo=0.1,0.4,0.01 do begin
         mixedimage=im1*(1.0-albedo)+im2*albedo
         writefits,'mixedimage.fits',mixedimage
         for alfa1=1.1,1.7,0.1 do begin
             for acoeff=0.8,1.4,0.1 do begin
                 for bpwr=0.8,1.4,0.1 do begin
                     str='./justconvolve_spPFS_PLS mixedimage.fits out.fits '+string(alfa1)+' '+string(acoeff)+' '+string(bpwr)
                     spawn,str
                     folded=readfits('out.fits')
                     folded=folded/total(folded)
                     folded=pth_rebin(folded,nbins,nbins)
                     print,'SUM: ',total(folded)
                     printf,18,format=fmt,albedo,alfa1,acoeff,bpwr,reform(folded,nbins*nbins,1)
                     print,format=fmt,albedo,alfa1,acoeff,bpwr,reform(folded,nbins*nbins,1)
                     endfor
                 endfor
             endfor
         endfor
     close,18
     endif
 ; That was the training set, nowmake the test set
 ; this time, the test is if image jitter can be modelled
 albedo=0.25
 mixedimage=im1*(1.0-albedo)+im2*albedo
 alfa1=1.4
 acoeff=1.1
 bpwr=1.1
 str='./justconvolve_spPFS_PLS mixedimage.fits out2.fits '+string(alfa1)+' '+string(acoeff)+' '+string(bpwr)
 spawn,str
 folded=readfits('out2.fits')
 folded=folded/total(folded)
 ; "folded" is now the image to jiggle and make a 'binned' file from
 openw,81,strcompress('jiggled_binned_images'+string(nbins)+'x'+string(nbins)+'.dat',/remove_all)
 for dx=-1.0,1.0,0.12 do begin
     for dy=-1.0,1.0,0.12 do begin
         im=shift_sub(folded,dx,dy)
         imout=pth_rebin(im,nbins,nbins)
                     print,'SUM jiggle: ',total(imout)
         printf,81,format=fmt,albedo,alfa1,acoeff,bpwr,reform(imout,nbins*nbins,1)
         print,dx,dy
         endfor
     endfor
 close,81
 end
