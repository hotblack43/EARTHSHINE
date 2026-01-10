PRO blind,ideal,observed,correctedim,k
; Blind deconvolution, follows  Zuo, Zhang and Zhao in IEEE (2009).
;
CapG=FFT(observed,-1,/double)
CapFprime=FFT(ideal,-1,/double)
l=size(ideal,/dimensions)
n=l(0)
;
moduluCapG=modulu(CapG)
nsmoo=13
smoothmoduluCapG=smooth(moduluCapG,nsmoo)
smoothmoduluCapFprime=smooth(modulu(CapFprime),nsmoo)
;
KG=1.0d0/max(smoothmoduluCapG)
KFprime=1.0d0/max(smoothmoduluCapFprime)
alpha=(alog(KG*smoothmoduluCapG)-alog(KFprime*smoothmoduluCapFprime))/alog(KG*smoothmoduluCapG)
print,'min max of alpha :',min(alpha),max(alpha)
;KG=KG/7.1
;alpha=(alog(KG*smoothmoduluCapG)-alog(KFprime*smoothmoduluCapFprime))/alog(KG*smoothmoduluCapG)
;print,'min max of alpha :',min(alpha),max(alpha)
CapH=(KG*moduluCapG)^alpha
CapF=CapG*conj(CapH)/((modulu(CapH))^2+K)
correctedim=double(FFT(CapF,1,/double))
; 
return
end
