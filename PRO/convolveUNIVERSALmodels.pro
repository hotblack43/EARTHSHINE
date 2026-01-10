;============================================================
 ; convolves ideal images so that a final realistic image with
 ; halo is produced
 ; Terrestrial albedo is held fixed 
 ;============================================================
 close,/all
 path='/data/pth/UNIVERSALSETOFMODELS/newH-63_HIRESscaled_LA/'
 albedo=0.31
 alfa1=1.715d0;1.76d0;1.80d0;1.85d0;1.70d0;1.76d0
 acoeff=0.0	; these are fixed in the 'just_...' fortran code anyway
 bwpr=0.0	; these are fixed in the 'just_...' fortran code anyway
 openr,1,'allfirstnames.txt'
 while not eof (1) do begin
     str2=''
     readf,1,str2
     name1=strcompress(path+str2+'0p0.fits',/remove_all)
     name2=strcompress(path+str2+'1p0.fits',/remove_all)
; file named name2 also has lon/lat images inside
     
     im1=readfits(name1)
     im2=readfits(name2,mixedimageheader)
     mixedimage=im1*(1.0-albedo)+im2(*,*,0)*albedo
     ; fold 
     writefits,'mixed117.fits',mixedimage,mixedimageheader
     str='./justconvolve_spPFS_special mixed117.fits trialout117.fits '+string(alfa1,format='(f4.2)')+' '+string(acoeff,format='(f4.2)')+' '+string(bwpr,format='(f4.2)')
     spawn,str;,/NOSHELL
     folded=readfits('trialout117.fits',hdr)
     folded=folded/total(folded,/double)
     outname=strcompress('/data/pth/UNIVERSALSETOFMODELS/newH-63_HIRESscaled_LA/convolved_albedo0p31/halo_model_'+str2+'.fits',/remove_all)
     folded_lonlataugmented=[[[folded]],[[mixedimage/total(mixedimage,/double)]],[[im2(*,*,1:2)]]]
     writefits,outname,folded_lonlataugmented,mixedimageheader
     print,'Write ',outname
     endwhile
 close,1
 end
