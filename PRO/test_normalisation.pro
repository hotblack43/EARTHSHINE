; regular way
a=readfits('cleaned.fit')
b=readfits('voigt_cleaned.fit')
b=b/mean(b)
astarb=fft(fft(a,-1,/double)*fft(b,-1,/double),1,/double)
adeconvolved=(fft(fft(astarb,-1,/double)/fft(b,-1,/double),1,/double))
adeconvolved=double(sqrt(adeconvolved*conj(adeconvolved)))
; arithmetic way
FTA=fft(a,-1,/double)
FTB=fft(b,-1,/double)
aa=double(FTA)
bb=imaginary(FTA)
cc=double(FTB)
dd=imaginary(FTB)
ratio_arith=complex(aa*cc+bb*dd,(bb*cc-aa*dd))/(cc*cc+dd*dd)
adeconvolved_arith=fft(ratio_arith,1)
adeconvolved_arith=double(sqrt(adeconvolved_arith*conj(adeconvolved_arith)))
;
diff=(adeconvolved-adeconvolved_arith)/adeconvolved*100.0
surface,diff,charsize=3
end

