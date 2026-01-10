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
 spawn,'idl go_get_particular_synthimage_227.pro';,/NOSHELL
 im1=readfits('ItellYOUwantTHISimage.fits',/silent)
;writefits,'im1_justaftercreation.fits',im1
 ; set up for albedo 1.0
 get_lun,hjkl
 openw,hjkl,'single_scattering_albedo.dat'
 printf,hjkl,1.0
 close,hjkl
 free_lun,hjkl
 ;...get the image
 spawn,'idl go_get_particular_synthimage_227.pro';,/NOSHELL
 im2=readfits('ItellYOUwantTHISimage.fits',/silent,mixedimageheader)
;writefits,'im2_justaftercreation.fits',im2
 return
 end

jd1=julday(11,11,2011,11,11,11.0d0)
get_two_synthetic_images,JD1,im1,im2,mixedimageheader
end
