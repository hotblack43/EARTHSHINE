FUNCTION go_unpad,imout
l=size(imout,/dimensions)
n=l(0)/3.
out=imout(n:2*n-1,n:2*n-1)
return, out
end

FUNCTION go_pad_image,imin
pad=imin*0.0d0
;minval=min(imin(where(imin gt 0)))
;pad=pad*1.0d0+minval
row1=[pad,pad,pad]
row2=[pad,imin,pad]
row3=[pad,pad,pad]
out=[[row1],[row2],[row3]]
return,out
end

 ;---------------------------------------------------------------------------
 ; Code that sets up the necessary files for the Cray to run its forward model code on
 ; Version 3 - 
 ;---------------------------------------------------------------------------
 CPU, TPOOL_MIN_ELTS=10000, TPOOL_NTHREADS=2
 common im,viz
	viz=1
 ;---------------------------------------------------------------------------
 input=readfits('SPECIAL/ideal_LunarImg_0019.fit')
 input_original=input
 input=input/max(input)*55000.0d0
 PSForig=readfits('TTAURI/PSF_fromHalo_1536.fits')	; 1536x1536
 ;........................
     input=go_pad_image(input)+400.0d0
     alfa=1.7
     PSF=PSForig^alfa
     l=size(PSF,/dimensions)
     PSF=PSF/total(PSF,/double)*float(l(0)*l(1))
     convolved=float((fft(fft(input,-1)*fft(PSF,-1),1)))
     middle=go_unpad(convolved)
     writefits,'SPECIAL/convolved.fits',middle
     writefits,'SPECIAL/idealused.fits',input_original
  end

