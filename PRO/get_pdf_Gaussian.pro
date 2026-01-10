PRO get_pdf_Gaussian,l,pdf,sigma
pdf=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2=(i-l(0)/2)^2+(j-l(1)/2.)^2
		pdf(i,j)=exp(-r2/abs(sigma))
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
return
end
