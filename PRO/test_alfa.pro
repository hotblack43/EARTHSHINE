 ;---------------------------------------------------------------------------
 ; Code that studies the relationship between alfa and the scatter on DS/BS
 ;---------------------------------------------------------------------------
 CPU, TPOOL_MIN_ELTS=10000, TPOOL_NTHREADS=2
 ;---------------------------------------------------------------------------
 ideal=readfits('ideal.fits')	; 1536x1536
 PSForig=readfits('PSF_fromHalo_1536.fits')	; 1536x1536
 ;........................
 ; generate two simulated images with slightly diffent alfa's
 alfa=1.2
 PSF=PSForig^alfa
 PSF=PSF/total(PSF)
 im1=float(fft(fft(ideal,-1)*ffT(PSF,-1),1))
 PSF=PSForig^(alfa*1.01)
 PSF=PSF/total(PSF)
 im2=float(fft(fft(ideal,-1)*ffT(PSF,-1),1))
 ; find the difference
 diff=(im2-im1)/((im1+im2)/2.)*100.
	writefits,'difim.fits',diff
 print,'DS change:',diff(807,783),' %'
 print,'BS change:',diff(982,780),' %'
 print,'alfa ch: ',((alfa*1.01)-alfa)/((alfa+(alfa*1.01))/2.)*100.,' %'
end
