PRO paddedFFT,kernel,arrayout
common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
common flags,iflag,iflag2
 fastfactor=128*2
 if (iflag ne 314) then begin
 	paddedideal=go_pad_image(ideal)
 	FFTideal=FFT(paddedideal,-1,/double)
 	;FFTideal=FFT(congrid(paddedideal,fastfactor,fastfactor),-1,/double)
 	iflag=314
 endif
 paddedkernel=go_pad_image(kernel)
 l=size(paddedkernel,/dimensions)
 m=l(0)
 ; shift to origin
 paddedkernel=shift(paddedkernel,m/2.,m/2.)
; renormalize to new size
 paddedkernel=paddedkernel/total(paddedkernel)*double(m)*double(m)
 ; convolve with FFT on padded arrays
 temp=double(ffT(FFTideal*FFT(paddedkernel,-1,/double),1,/double))
 arrayout=go_unpad(congrid(temp,m,m))
 return
end
