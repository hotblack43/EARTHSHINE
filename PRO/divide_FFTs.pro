KING=readfits('KINGimages/KING_0018.fit')
ideal=readfits('IDEAL/ideal_LunarImg_0018.fit')
KING_FFT=FFT(KING,-1,/double)
ideal_FFT=FFT(ideal,-1,/double)
PSF=FFT(KING_FFT/ideal_FFT,1,/double)
PSF=sqrt(PSF*conj(PSF))
surface,alog10(PSF),charsize=2
KING_dePSFd=FFT(KING_FFT/FFT(PSF,-1,/double),1,/double)
KING_dePSFd=sqrt(KING_dePSFd*conj(KING_dePSFd))
ratio=double(ideal/KING_dePSFd)
surface,ratio,charsize=2
end

