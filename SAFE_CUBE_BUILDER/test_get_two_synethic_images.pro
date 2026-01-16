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
spawn,'rm -f ItellYOUwantTHISimage.fits'
spawn,'gdl go_get_particular_synthimage_118_assigningIMAGEparametersinfiles.pro'
im1=readfits('ItellYOUwantTHISimage.fits',/silent)
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
spawn,'gdl go_get_particular_synthimage_118_assigningIMAGEparametersinfiles.pro'
im2=readfits('ItellYOUwantTHISimage.fits',/silent)
return
end

get_lun,hjkl
openr,hjkl,'JDtouseforSYNTH'
for j=0,1000000,1 do begin
	readf,hjkl,JD
	mphase,jd,k
	print,JD,' Illuminated fraction: ',k
	get_two_synethic_images,JD,im1,im2
	print,format='(f15.7,a)',jd,'  ----------------------------------------------'
        stop
	im3 = [[[im1]],[[im2]]]
	im3 = im3/max(im3)
	writefits,'twosynths_'+STRING(JD,FORMAT='(F15.7)')+'.fits',im3
endfor
close,hjkl
free_lun,hjkl
end

