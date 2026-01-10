PRO putinsomePOISSONnoise,x
help,x
l=size(x,/dimensions)
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
value=x(i,j)
if (x(i,j) gt 1) then value=randomn(seed,1,POISSON=x(i,j))
x(i,j)=value
endfor
endfor
return
end

PRO get_kernel,kernel,n,peakval,widthfactor
data=get_data('TOMSTONE/nozeros_ROLO_765nm_Vega_psf.dat')
x=reform(data(0,*))
y=reform(data(1,*))
r=dblarr(n,n)
kernel=dblarr(n,n)
for i=0,n-1,1 do begin
for j=0,n-1,1 do begin
r(i,j)=sqrt((i-n/2.)^2+(j-n/2.)^2)
endfor
endfor
fillval=5e-4
print,'Fill value=',fillval
kernel=INTERPOL(y,x,r*widthfactor)
idx=where(kernel lt fillval)
if (idx(0) ne -1) then kernel(idx)=fillval
kernel(n/2.,n/2.)=kernel(n/2.,n/2.)*peakval
kernel=kernel/total(kernel)*float(n*n)
kernel=shift(kernel,n/2.,n/2.)
return
end


; read in the images to be convolved
path='OUTPUT/IDEAL/'
filenames=FILE_SEARCH(path,'ideal_Lu*',count=nfiles)
names=strmid(filenames(*),13,strlen(filenames(2))-1)
for ifile=0,nfiles-1,1 do begin
imin=double(readfits(filenames(ifile),header))
imin=congrid(imin,512,512)
imin=imin/max(imin)*45000.0+100.0	; scale for 16 bits, add sky background
outname=strcompress(path+'InSpace_'+names(ifile),/remove_all)
print,outname
writefits,outname,imin,header
l=size(imin,/dimensions)
n=l(0)
; read in the kernel to convolve with
p=1000.0d0	; factoron delta function
w=1.0d0	; width factor
get_kernel,kernel,n,p,w
writefits,'kernel.fit',kernel
; convolve
imout=double(fft(fft(kernel,-1)*fft(imin,-1),1))
; add some POISSON noise
putinsomePOISSONnoise,imout
; write out the results
outname=strcompress(path+'ModObserved_'+names(ifile),/remove_all)
print,outname
writefits,outname,imout,header
print,'Done!'
endfor
end
