; clean up
spawn,'rm BINfiles/*'
; do the mask file
mask=readfits('mask.fits')     ;       512x512 (allows only sky pixels)
openw,34,'BINfiles/mask.raw' & writeu,34,float(mask) & close,34
; do the observed file
observed=readfits('presentinput.fits') ; 512x512
openw,34,'BINfiles/target.raw' & writeu,34,float(observed) & close,34
; do the ideal file
ideal=readfits('ideal.fits')   ; 1536x1536
openw,34,'BINfiles/ideal.raw' & writeu,34,float(ideal) & close,34
; do the PSF 
PSForig=readfits('TTAURI/PSF_fromHalo_1536.fits')     ; 1536x1536
openw,34,'BINfiles/psf.raw' & writeu,34,double(PSForig) & close,34
end
