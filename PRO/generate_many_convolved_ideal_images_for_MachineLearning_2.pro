PRO get_a_synthetic_image,JD,im1,par1,par2
albedo = par1
; Generate one FITS images of the Moon for the given JD with PSF and Earth's albedo in par1
; the swithc to be put into file moon_BRDF.txt is in par2
get_lun,hjkl
openw,hjkl,'JDtouseforSYNTH'
printf,hjkl,format='(f15.7)',JD
close,hjkl
free_lun,hjkl
;=================================================
; set up albedo 
get_lun,hjkl
openw,hjkl,'single_scattering_albedo.dat'
printf,hjkl,par1
close,hjkl
free_lun,hjkl
;=================================================
; set up moon_BRDF
get_lun,hjkl
openw,hjkl,'moon_BRDF.txt'
printf,hjkl,par2
close,hjkl
free_lun,hjkl
;================================================
spawn,'gdl go_get_particular_synthimage_16_for_ML.pro'
get_lun,iuhgyuygf
openr,iuhgyuygf,'nameofparticularsynthimage.txt'
thename=''
readf,iuhgyuygf,thename
close,iuhgyuygf
im1=readfits(thename,/silent)
;================================================
return
end

; Moon reflectance specification
moon_albedo  = 1     ; 0=uniform (0.0720) , 1=Clementine albedos from file
moon_BRDF    = 1     ; 0=uniform (Lambert), 1=uniform(Hapke), 2=from file
JD=2455852.8772108d0
nalbedo=1000
corefactor = 2
rlimit = 9
for ialbedo=1,nalbedo,1 do begin
	close,/all
	albedo=randomu(seed)*0.8+0.1
	get_a_synthetic_image,JD,im1,albedo,301
	; convolve it
	writefits,'mixed117.fits',im1,mixedimageheader
        alfa1 = randomu(seed)*0.2+1.7
 	str='./justconvolve_scwc mixed117.fits trialout117.fits '+string(alfa1)+' '+string(corefactor)+' '+string(rlimit)
 	spawn,str
 	folded=readfits('trialout117.fits',/silent)
	; Dimensionaly reduce that image
	n=8
	blocked = REBIN(folded, n,n)
	;writefits,'OUTPUT/MLIMAGES/testim.fits',blocked
	openw, 73, 'data_8x8_for_ML_convolved_different_alfa.dat', /append
	printf,73,[rebin(blocked,n*n),albedo],FORMAT='(65(F12.7,1X))'
	close,73
endfor
end
