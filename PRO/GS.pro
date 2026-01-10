FUNCTION AMP,X
AMP=abs(X)
return,AMP
end

FUNCTION PHASE,Z
x=float(Z)
Y=imaginary(Z)
;PHASE= 0.5*atan(2.*x, 1 - x^2 - y^2) + 0.25*Complex(0,1)*alog((x^2 + (y+1)^2)/(x^2 + (y-1)^2))
PHASE=ATAN(Y/X)
RETURN,PHASE
end
;------------------- test for zeros in FFT(psf)
power=2.0
l=[256,256]
power=2.0
get_pdf_King,l,pdf,power
source=pdf
target=randomn(seed,l(0),l(1))*source
A=FFT(target,1,/double)
!P.MULTI=[0,2,4]
for i=0,10,1 do begin
	surface,float(a),charsize=3,title='A'
	surface,imaginary(a),charsize=3
	b=AMP(source)*exp(complex(0,1)*phase(a))
	surface,float(b),charsize=3,title='B'
	surface,imaginary(b),charsize=3
	c=FFT(B,-1,/double)
	surface,float(c),charsize=3,title='C'
	surface,imaginary(c),charsize=3
	d=amp(target)*exp(complex(0,1)*phase(c))
	surface,float(d),charsize=3,title='D'
	surface,imaginary(d),charsize=3
	A=fft(d,1,/double)
endfor
retrieved_phase=phase(A)
end
	
