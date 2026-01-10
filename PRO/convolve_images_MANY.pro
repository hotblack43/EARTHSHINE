FUNCTION putinsomePOISSONnoise,x_in
x=x_in
l=size(x,/dimensions)
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
value=x(i,j)
if (value gt 1) then value=randomn(seed,1,POISSON=value)
x(i,j)=value
endfor
endfor
return,x
end

PRO get_kernel,kernel,peakval,widthfactor
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
 data=get_data('TOMSTONE/nozeros_ROLO_765nm_Vega_psf.dat')
 x=reform(data(0,*))
 y=reform(data(1,*))
 kernel=dblarr(n,n)
 fillval=min(y(where(y gt 0)))
 kernel=INTERPOL(y,x,r*widthfactor)
 kdx=(where(kernel lt fillval))
 if (kdx(0) ne -1) then kernel(kdx)=fillval
 ;put a variable-height spike in the centre
 kernel(n/2.,n/2.)=kernel(n/2.,n/2.)*peakval
 ; and normalize
 kernel=kernel/total(kernel)*float(n*n)
 ;surface,kernel
 return
 end

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
 ;temp=double(ffT(FFTideal*FFT(congrid(paddedkernel,fastfactor,fastfactor),-1,/double),1,/double))
 arrayout=go_unpad(congrid(temp,m,m))
 return
end

CPU, TPOOL_MIN_ELTS=10000, TPOOL_NTHREADS=2
common stuff,FFTideal,observed,imin,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
common flags,iflag,iflag2
; read in the images to be convolved
path='/home/pth/SCIENCEPROJECTS/EARTHSHINE/OUTPUT/IDEAL/'
filenames=FILE_SEARCH(path,'ideal_Lu*',count=nfiles)
names=strmid(filenames(*),strlen(filenames(2))-9,10)
for ifile=0,nfiles-1,1 do begin
iflag=-911	;must reset flag each time
print,'Reading :',filenames(ifile)
imin=double(readfits(filenames(ifile),header))
imin=congrid(imin,512,512)
l=size(imin,/dimensions) & n=l(0)
; set up the arrayfor the PSF
r=dblarr(n,n)
 for i=0,n-1,1 do begin
     for j=0,n-1,1 do begin
         r(i,j)=sqrt((i-n/2.)^2+(j-n/2.)^2)
         endfor
     endfor
imin=imin/max(imin)*45000.0	; scale for 16 bits
outname=strcompress(path+'InSpace_'+names(ifile),/remove_all)
print,'Writing :',outname
writefits,outname,imin,header
l=size(imin,/dimensions)
n=l(0)
; read in the kernel to convolve with
p=10000.0d0	; factor on delta function
w=.5d0	; width factor in units (pixels per arcsecond)
get_kernel,kernel,p,w
writefits,'kernel.fit',kernel
; convolve
paddedFFT,kernel,imout
; add some POISSON noise
imout_orig=imout
imout=putinsomePOISSONnoise(imout_orig)
if_add_several=1
if (if_add_several eq 1) then begin
	nseveral=36
	sum=imout
	for isev=0,nseveral-1,1 do begin
		print,isev
		sum=sum+imout
	endfor
	imout=sum/double(nseveral)
endif
; write out the results
outname=strcompress(path+'Observed_'+names(ifile),/remove_all)
sxaddpar, header, 'CONVOLUTION', 'VEGA', 'This artificial image convolved with a parametrised VEGA profile.'
sxaddpar, header, 'PEAKVALUE',string(double(p),format='(d20.8)'), ' VEGA peak delta fct'
sxaddpar, header, 'WIDTH',string(double(w),format='(d20.8)'), ' VEGA peak width factor'
print,'Writing :',outname
writefits,outname,imout,header
print,'Done!'
endfor
end
