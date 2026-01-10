imin=readfits('OUTPUT/IDEAL/ideal_LunarImg_0069.fit')   


PSF=readfits('Vega_PSF.fit')
l=size(PSF,/dimensions)
PSF=PSF*l(0)*l(1)

PSF = PSF > 0.1

step1=fft(imin,-1)*fft(psf,-1)	
step2=fft(step1,1)

imin_folded=double(sqrt(step2*conj(step2)))

end

