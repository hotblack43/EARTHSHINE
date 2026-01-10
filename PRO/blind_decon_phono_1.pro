FUNCTION modulu,X
modulu=sqrt(float(X)^2+imaginary(X)^2)
return,modulu
end

;small_g=read_wav('loffa_mc.wav',rate)
small_g=read_wav('DQ_sample_in.wav',rate)
mn1=mean(small_g)
small_g=small_g-mn1
;---
small_fprime=read_wav('DQ_sample.wav',rate2)
small_fprime=reform(small_fprime(0,*))	; use just one channel
;... make them same length
n_req=n_elements(small_fprime)
n_in=n_elements(small_g)
ll=min([n_in,n_req])
small_g=small_g(0:ll-1)
small_fprime=small_fprime(0:ll-1)
n_req=n_elements(small_fprime)
n_in=n_elements(small_g)
;---  calculate frequency scales for the two series
freqs2=(findgen(n_req))/(n_req/rate2)
freqs=(findgen(n_in))/(n_in/rate)
;---
mn2=mean(small_fprime)
small_fprime=small_fprime-mn2
print,'Sample rates: ',rate,rate2
print,'Mean, STD of DQ is:',mn1,stddev(small_fprime)
print,'Mean, STD of Loffa  is:',mn2,stddev(small_g)
; FFT
large_G=FFT(small_g,-1,/double)
large_Fprime=FFT(small_fprime,-1,/double)
; constants
nsmoo=1111	; Guesswork!
SG=median(modulu(large_G),nsmoo)
SFprime=smooth(modulu(large_Fprime),nsmoo,/edge_truncate)
KG=1./max(SG)
KFprime=1./max(SFprime)
; alpha
alpha=1.0 -  alog(KFprime*SFprime) / alog(KG*SG)
idx=where(finite(alpha) eq 0)
if (idx(0) ne -1) then alpha(idx)=0.0
; bigD
bigD= (KG*SG) ^alpha
; bigF
for C2factor=0.,10.,1.0 do begin
C2=1./(10^(C2factor/2.))
bigF=(large_G*conj(complex(bigD,0.0*findgen(n_elements(bigD)))))/(modulu(bigD)^2+C2)
little_f=fft(bigF,1,/double)
;-----------------------------  PLOTTING
!P.MULTI=[0,1,3]
plot,small_g
plot,little_f
write_wav,strcompress('out_'+string(fix(C2factor))+'.wav',/remove_all),float(little_f),8000
plot,modulu(bigD)
 !P.MULTI=[0,1,4]
pow1=large_G*conj(Large_G)
plot_oo,freqs,pow1,charsize=2,xrange=[1,1e5],title='Input sample spectrum',xtitle='f (Hz)'
;...
F=FFT(float(little_f),-1)
pow2=F*conj(F)
pow3=large_Fprime*conj(large_Fprime)
plot_oo,freqs2,pow3,charsize=2,xrange=[1,1e5],title='Required power spectrum',xtitle='f (Hz)'
plot_oo,freqs,pow2,charsize=2,xrange=[1,1e5],title='Recon power spectrum',xtitle='f (Hz))'
plot_oo,freqs,pow2/pow1,charsize=2,xrange=[1,1e5],title='Recon/Input power spectrum',xtitle='f (Hz)'
plots,[1,1e5],[1,1]
endfor	; end of C2factor loop
end