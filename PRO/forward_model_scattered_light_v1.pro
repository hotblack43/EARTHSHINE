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
fillval=9e-4
print,'Fill value=',fillval
kernel=INTERPOL(y,x,r*widthfactor)
;jdx=where(r gt 190*widthfactor)
;kernel(jdx)=fillval
;put a variable-height spike in the centre
kernel(n/2.,n/2.)=kernel(n/2.,n/2.)*peakval
; and normalize
kernel=kernel/total(kernel)*float(n*n)
kernel=shift(kernel,n/2.,n/2.)
return
end


CPU, TPOOL_MIN_ELTS=1000, TPOOL_NTHREADS=2
; read in the image to be convolved
observed=readfits('TOMSTONE/2709_ROLO_rotatedm90.fit')
ideal=readfits('rotatedandscaled.fit')
FFTideal=FFT(ideal,-1)
l=size(observed,/dimensions)
if (l(0) ne l(1)) then stop
n=l(0)
writefits,'imin.fit',observed
writefits,'ideal.fit',ideal
maxerr=1e33
; 290     0.665324
; 184     0.700000
; 180     0.730000 
;  191     0.750000
for p=180,200,1 do  begin
for w=0.7,0.8,0.01 do begin	; width factor
get_kernel,kernel,n,p,w
;surface,kernel,/zlog
writefits,'kernel.fit',kernel
; convolve
imout=double(FFT(FFTideal*fft(kernel,-1),1))
;imout=CONVOL(ideal,kernel,/NaN)
; write out the results
writefits,'imout.fit',imout
scattered=imout-ideal
writefits,'scattered.fit',scattered
writefits,'cleaned.fit',observed-scattered
diff=observed-imout
err=total(diff(0:200,*)^2)
if (err lt maxerr) then begin
maxerr=err
tvscl,[observed,imout,diff]
print,p,w,err
endif
endfor
endfor
print,'Done!'
end
