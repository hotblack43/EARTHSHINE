FUNCTION newtfunc, X
common values,e
m=x(0)
h=x(1)
s=x(2)
RETURN, [2.65d0 - sqrt(e+m+s),2.65d0-sqrt(e+h+s),4.927d0-m+h]
END


common values,e
for e=0.,1.,0.01 do begin	; variance due to electronics
; Provide an initial guess as the algorithm's starting point:
X = [0.29112691,     0.76270026,    0.030970859]

; Compute the solution:
result = NEWTON(X, 'newtfunc',/double,check=checkit,itmax=2000)

; Print the result:
PRINT, e,' result = ', result,' check: ',checkit
endfor
END
