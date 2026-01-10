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
if (idx(0) ne -1) then kernel(idx)=filval
kernel(n/2.,n/2.)=kernel(n/2.,n/2.)*peakval
kernel=kernel/total(kernel)
kernel=shift(kernel,n/2.,n/2.)
return
end


; read in the image to be convolved
imin=double(readfits('REALFLOAT_ideal_LunarImg_0471.fit'))
imin=congrid(imin,512,512)
writefits,'imin.fit',imin
l=size(imin,/dimensions)
n=l(0)/3.
; read in the kernel to convolve with
p=100.0d0	; factoron delta function
w=1.0d0	; width factor
get_kernel,kernel,n,p,w
;surface,kernel,/zlog
writefits,'kernel.fit',kernel
; convolve
imout=CONVOL(imin,kernel,/NaN)
; write out the results
writefits,'imout.fit',imout
print,'Done!'
end
