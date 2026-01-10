;
Nstar=1500.
npix=40
Ns=4.
Nd=0.1
Nr=1.
nb=100.
G=3.78
Go=G
vardigi=1.0
;
SNR=Nstar/sqrt(Nstar+npix*(Ns+Nd+nr^2))
print,'SNR:',SNR
print,'Noise in % of signal is: ',100./SNR
end

