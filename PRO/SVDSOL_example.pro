

dat=get_data('safe.scaled_array.dat')
l=size(dat,/dimensions)
print,l
a=dat(1:l(0)-2,*)
b=reform(dat(l(0)-1,*))
SVDC, A, W, U, V,/double
; Compute the solution and print the result:
PRINT, SVSOL(U, W, V, B,/double)
end
