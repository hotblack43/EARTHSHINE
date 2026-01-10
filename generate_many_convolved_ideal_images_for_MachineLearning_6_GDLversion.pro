@PoiDev.pro
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
im1=readfits(thename)
;================================================
return
end




;---------------------------------------------------------
; Code to generate random realistic lunar images.
; JD is random
; terrestrial albedo is random
; PSF parameter is random
;---------------------------------------------------------
; Moon reflectance specification
moon_albedo  = 1     ; 0=uniform (0.0720) , 1=Clementine albedos from file
moon_BRDF    = 1     ; 0=uniform (Lambert), 1=uniform(Hapke), 2=from file
Ntogenerate=3000
corefactor = 2
rlimit = 9
n_coadd = 100 ; the number of copies of the original pure images to be coadded once Poisson noise has been generated in each one
for itrial=1,Ntogenerate,1 do begin
	close,/all
        JD=2455852.8772108d0+28.0*(randomu(seed)-0.5)
        mphase,JD,illfrac
        if illfrac LT 0.6 then begin
	albedo=randomu(seed)*0.5+0.1
	get_a_synthetic_image,JD,im1,albedo,301
	; convolve it
	writefits,'mixed117.fits',im1,mixedimageheader
        alfa1 = randomu(seed)*0.2+1.7
 	str='./justconvolve_scwc mixed117.fits trialout117.fits '+string(alfa1)+' '+string(corefactor)+' '+string(rlimit)
 	spawn,str
 	folded=readfits('trialout117.fits')
        actual_max = max(folded)
 	folded = folded/actual_max*50000.0d0
        org_folded=folded
;	writefits,strcompress('OUTPUT/MLIMAGES_100SUMMED/testim_unnoisy_'+string(albedo)+'_'+string(illfrac)+'_.fits',/remove_all),folded
; scale to suitable number to avoid excessive rounding when the integer random numbers are calculated
;	sumim = dblarr(512,512)
;	sumim = sumim + replicate(0., 512, 512)
;	for icoadd=1,n_coadd,1 do begin
; generate Poisson noise - it then represent the 'noisied image'
;		PoissonNoise = PoiDev(folded)
;		sumim = sumim + PoissonNoise    
;	endfor
;	folded = sumim/n_coadd
;        actual_max = max(folded)
; 	folded = folded/actual_max*50000.0d0
;
;	writefits,strcompress('OUTPUT/MLIMAGES_100SUMMED/noise_'+string(albedo)+'_'+string(illfrac)+'_.fits',/remove_all),PoissonNoise
;	writefits,strcompress('OUTPUT/MLIMAGES_100SUMMED/testim_'+string(albedo)+'_'+string(illfrac)+'_.fits',/remove_all),folded
	writefits,strcompress('OUTPUT/MLIMAGES_100SUMMED/org_folded_'+string(albedo)+'_'+string(illfrac)+'_.fits',/remove_all),org_folded
;	writefits,strcompress('OUTPUT/MLIMAGES_100SUMMED/ratio_'+string(albedo)+'_'+string(illfrac)+'_.fits',/remove_all),org_folded/PoissonNoise
;
	endif
endfor
end

