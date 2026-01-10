PRO getpwr,im,pwr
z=fft(im,-1,/double)
zz=z*conj(z)
pwr=sqrt(zz)
end

im=readfits('usethisidealimage.fits')
sim=shift(im,12,30)
;
!P.CHARSIZE=2
getpwr,im,pwr1
getpwr,sim,pwr2
surface,pwr1/pwr2
im_restored=fft(pwr1,1)
tvscl,im_restored
end
