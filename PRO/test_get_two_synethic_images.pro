PRO get_two_synethic_images,JD,im1,im2
print,format='(a,1x,f15.7)','get_two_synethic_images has been given JD=',jd
; Generate two FITS images of the Moon for the given JD with Earth albedo 0 and 1
get_lun,hjkl
openw,hjkl,'usethisJD'
printf,hjkl,format='(f15.7)',JD(0)
close,hjkl
free_lun,hjkl
; set up albedo 0
get_lun,hjkl
openw,hjkl,'single_scattering_albedo.dat'
printf,hjkl,0.0
close,hjkl
spawn,'echo hej hej 1'
spawn,'cat single_scattering_albedo.dat'
free_lun,hjkl
;...get the image
spawn,'rm ItellYOUwantTHISimage.fits'
spawn,'idl go_get_particular_synthimage_118_assigningIMAGEparametersinfiles.pro'
im1=readfits('ItellYOUwantTHISimage.fits',/silent)
;tvscl,im1
; set up for albedo 1.0
get_lun,hjkl
openw,hjkl,'single_scattering_albedo.dat'
printf,hjkl,1.0
close,hjkl
free_lun,hjkl
spawn,'echo hej hej 2'
spawn,'cat single_scattering_albedo.dat'
;...get the image
spawn,'rm -f ItellYOUwantTHISimage.fits'
spawn,'idl go_get_particular_synthimage_118_assigningIMAGEparametersinfiles.pro'
im2=readfits('ItellYOUwantTHISimage.fits',/silent)
;tvscl,im2
return
end

;JD=2455945.176d0
;JD=julday(8,24,2018,15,43,04)
JD=julday(8,8,2017,11,20,20.8)
mphase,jd,k
print,'Illuminated fraction: ',k
get_two_synethic_images,JD,im1,im2
writefits,'im1_'+STRING(JD,FORMAT='(F15.7)')+'.fits',im1
writefits,'im2_'+STRING(JD,FORMAT='(F15.7)')+'.fits',im2
help
end

