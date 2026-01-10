 PRO get_two_synthetic_images_usedisk,JD,im1,im2,mixedimageheader,if_want_LRO
 ; Generate two FITS images of the Moon for the given JD with Earth albedo 0 and 1
 str='/data/pth/UNIVERSALSETOFMODELS/newH-63_HIRESscaled_LA/*'+jd+'*'
 res=file_search(str,count=n)
 yesondiskflag=314
 goseeksuccess,res,yesondiskflag,file0,file1
 if (yesondiskflag eq 314) then begin
	get_two_synthetic_images,JD,im1,im2,mixedimageheader,if_want_LRO
 	return
 endif else begin
	im1=readfits(file0)	; the 0p0 file
	im2=readfits(file1)	; the 1p0 file
        if (n_elements(size(im1,/dimensions)) ne 2) then stop
        if (n_elements(size(im2,/dimensions)) ne 2) then im2=reform(im2(*,*,0))
 endelse
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
