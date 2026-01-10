; saves a normalized bias-subtracted, linear-surface-removed flat field
flat=readfits('Ahmad_Lab_Flat_field.fits')
print,'Mean flat:',mean(flat)
bias=readfits('DAVE_BIAS.fits')
flat=flat-bias
print,'Mean flat:',mean(flat)
; calculatethe mean value
mnflat=mean(flat)
print,'mnflat: ',mnflat
fitflat=sfit(flat,1)
; subtract the linear surface (like not due to CCD but rather illumination)
;flat=flat-fitflat
print,'Mean flat:',mean(flat)
; and the mean back in
;flat=flat+mnflat
print,'Mean flat:',mean(flat)
; normalize
flat=flat/mean(flat)
print,'Mean flat:',mean(flat)
writefits,'Flattened_FF.fits',flat
end
