; calculate the ratio of two complex arrays using division and arithmetic
a=readfits('cleaned.fit')
b=readfits('voigt_cleaned.fit')
;
FTA=fft(a,-1,/double)
FTB=fft(b,-1,/double)
RATIO_DIV=FTA/FTB
; arithmetic way
aa=double(FTA)
bb=imaginary(FTA)
cc=double(FTB)
dd=imaginary(FTB)
ratio_arith=complex(aa*cc+bb*dd,(bb*cc-aa*dd))/(cc*cc+dd*dd)
diff_real=double(RATIO_DIV)-double(ratio_arith)
diff_imag=imaginary(RATIO_DIV)-imaginary(ratio_arith)
!P.MULTI=[0,1,2]
surface,diff_real/double(RATIO_DIV)*100.0,title='Difference between / and arithmetic, Real part'
surface,diff_imag/imaginary(ratio_arith)*100.0,title='Difference between / and arithmetic, Imag part'
print,mean(abs(diff_real/double(RATIO_DIV)*100.0)),' % error on real part'
print,mean(abs(diff_imag/imaginary(RATIO_DIV)*100.0)),' % error on imag part'
end

