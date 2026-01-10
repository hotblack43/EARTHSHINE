x=randomu(seed,100)
alfa=2.0
for eps_pwr=-9.0d0,-1.0d0,1.0d0 do begin
eps=10^(eps_pwr)
base=fft(x^(alfa),-1)
direct=fft(x^(alfa+eps),-1)
fftx=fft(x,-1)
expansion=base*(1.0+eps)+eps*fftx
;
diff=direct-expansion
err=float(sqrt(total(diff*conj(diff)))/n_elements(x))
print,eps,' Error is:',err*100.,' %.'
print,eps,eps/err
endfor
end
