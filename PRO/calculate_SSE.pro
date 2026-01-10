FUNCTION calculate_SSE,X,Y,A
common stuff,inputim,observed,subim,counter
y0=a(0)
x0=a(1)
rotangle=a(2)
scale=a(3)
factor=a(4)
print,'a:',a
	l=size(observed,/dimensions)
	rotim= ROT(inputim, rotangle, scale,/INTERP)
	subim= congrid(rotim,l(0),l(1))
	subim=shift_sub(subim, -x0, -y0)
	mask=subim
	idx=where(mask ne 0)
	mask(idx)=1.0
	resim=(subim/float(factor)-observed)*mask
	calculate_SSE=double(total(resim^2,/double)/(double(l(0)*l(1))))
	if (counter/25. eq fix(counter/25.)) then begin
		contour,subim/factor-observed,/cell_fill,xstyle=1,ystyle=1,/isotropic
	endif
	print,calculate_SSE
	counter=counter+1
return,calculate_SSE
end
