PRO blind2,ideal,observed,correctedim,hh,k
; Blind deconvolution, follows  Zuo, Zhang and Zhao in IEEE (2009).
;
CapG=FFT(observed,-1,/double)
CapFprime=FFT(ideal,-1,/double)
l=size(ideal,/dimensions)
n=l(0)
;
moduluCapG=modulu(CapG)
nsmoo=7
smoothmoduluCapG=smooth(moduluCapG,nsmoo)
smoothmoduluCapFprime=smooth(modulu(CapFprime),nsmoo)
;
KG=1.0d0/max(smoothmoduluCapG)
KFprime=1.0d0/max(smoothmoduluCapFprime)
alpha=(alog(KG*smoothmoduluCapG)-alog(KFprime*smoothmoduluCapFprime))/alog(KG*smoothmoduluCapG)
CapH=(KG*moduluCapG)^alpha
CapF=CapG*conj(CapH)/((modulu(CapH))^2+K)
correctedim=double(FFT(CapF,1,/double))
h=fft(CapH,1,/double) & hh=double(h*conj(h)) & hh=shift(hh,n/2.,n/2.)
; 
return
end
