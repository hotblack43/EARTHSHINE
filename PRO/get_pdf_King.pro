PRO get_pdf_King,l,pdf,power
pdf=dblarr(l(0),l(1))
pp=abs(power)
half_i=l(0)/2.
half_j=l(1)/2.
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2= (abs(i-half_i))^pp+(abs(j-half_j))^pp
		if (r2 gt 1.0) then pdf(i,j)=1.0d0/r2 else pdf(i,j)=1.0d0
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
return
end
