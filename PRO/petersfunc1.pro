FUNCTION petersfunc1,a
;
;	A circle is fitted
;
 peakval=a(0)
 widthfactor=a(1)
get_kernel,PSF,peakval,widthfactor
ratio=FFT(observed,-1,/double)/FFT(PSF,-1,/ideal)
result=FFT(ratio,1,/double)
negs=n_elements(where(result lt 0.0))
return,negs
end
