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
         outarr(i,j)=total(small,/double)
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
 
 close,/all
 nbins=4
 nstr=string(4+nbins*nbins)
 fmt='('+nstr+'(1x,f17.5))'
 JD=systime(/utc,/julian)
 JD=2456104.0d0-3.0d0
 get_two_synthetic_images,JD,im1,im2,mixedimageheader,if_want_LRO
 if_want_training_set=1
 if (if_want_training_set eq 1) then begin
     openw,18,strcompress('binned_images'+string(nbins)+'x'+string(nbins)+'.dat',/remove_all)
     nims=10000
     for iim=0,nims-1,1 do begin
	 albedo=(randomn(seed))*0.07+0.3
;        albedo=2.0*(randomu(seed)-0.5)*0.1+0.3
         mixedimage=im1*(1.0-albedo)+im2*albedo
         writefits,'mixedimage.fits',mixedimage
         alfa1=(randomu(seed)-0.5)+1.4
         acoeff=(randomu(seed)-0.5)+1.4
         bpwr=(randomu(seed)-0.5)+1.4
         str='./justconvolve_spPFS_PLS mixedimage.fits out.fits '+string(alfa1)+' '+string(acoeff)+' '+string(bpwr)
         print,str
         spawn,str
         folded=readfits('out.fits')
 ;       folded=folded/total(folded)
         dx=randomn(seed)*0.6
         dy=randomn(seed)*0.6
         im=shift_sub(folded,dx,dy)
         imout=pth_rebin(im,nbins,nbins)
         folded=pth_rebin(imout,nbins,nbins)
         print,'SUM: ',total(folded)
         printf,18,format=fmt,albedo,alfa1,acoeff,bpwr,reform(folded,nbins*nbins,1)
         print,format=fmt,albedo,alfa1,acoeff,bpwr,reform(folded,nbins*nbins,1)
         endfor
     close,18
     endif
 ; That was the training set, nowmake the test set
 ; this time, the test is if image jitter can be modelled
 end
