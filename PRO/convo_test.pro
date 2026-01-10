;------------------- test for zeros in FFT(psf)
power=2.0
l=[256,256]
get_pdf_King,l,pdf,power
; get the ideal version of the observed folded image
file_ideal='H:\aaRaw\ideal_LunarImg_0020.fit'
ideal=readfits(file_ideal)
ideal=congrid(ideal,l(0),l(0))
; construct a convolved image from pdf and ideal
convolved=float(FFT(FFT(pdf,-1,/double)*FFT(ideal,-1,/double),1,/double))
   	!P.MULTI=[0,2,2]
   	contour,convolved
   		contour,pdf
   			contour,ideal
	!P.MULTI=[0,1,1]
; loop over guesses for 'power' and deconvolve, calulate the residuals
openw,12,'dat.dat'
olderr=1e12
for power=1.5,2.5,0.005 do begin
	get_pdf_King,l,pdf,power
	cleaned=float(fft(fft(shift(convolved,0,0),-1,/double)/fft(pdf,-1,/double),1,/double))
	residuals=ideal-cleaned
	rmse=sqrt(total(residuals^2)/l(0)/l(1))
	print,rmse,power
	printf,12,rmse,power
	if (rmse lt olderr) then begin
	olderr=rmse
	;surface,residuals
	endif
endfor
close,12
data=get_data('dat.dat')
plot_io,data(1,*),data(0,*),xtitle='King profile exponent',ytitle='RMSE per pixel',charsize=2,psym=-4
end